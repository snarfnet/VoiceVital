import AVFoundation
import Accelerate

/// リアルタイム音声解析エンジン
/// AVAudioEngine + Accelerate (vDSP) による高速DSP処理
@Observable
final class VoiceAnalyzer {
    enum State { case idle, recording, analyzing, done }

    private(set) var state: State = .idle
    private(set) var currentLevel: Float = 0
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var latestMetrics: VoiceMetrics?

    private let engine = AVAudioEngine()
    private var audioBuffer: [Float] = []
    private var startTime: Date?
    private let sampleRate: Double = 44100
    private let recordDuration: TimeInterval = 5.0
    private var timer: Timer?

    /// 録音開始
    func startRecording() {
        audioBuffer.removeAll()
        audioBuffer.reserveCapacity(Int(sampleRate * recordDuration))

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        let actualSR = format.sampleRate

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self else { return }
            let frameCount = Int(buffer.frameLength)
            guard let channelData = buffer.floatChannelData?[0] else { return }

            // ダウンミックス（モノ）
            let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))

            // RMSレベル計算
            var rms: Float = 0
            vDSP_measqv(channelData, 1, &rms, vDSP_Length(frameCount))
            let level = sqrt(rms)

            DispatchQueue.main.async {
                self.currentLevel = level
                self.audioBuffer.append(contentsOf: samples)
                self.elapsedTime = Date().timeIntervalSince(self.startTime ?? Date())

                if self.elapsedTime >= self.recordDuration {
                    self.stopRecording(sampleRate: actualSR)
                }
            }
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)
            try engine.start()
            state = .recording
            startTime = Date()
            elapsedTime = 0

            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self, let start = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
            }
        } catch {
            print("Recording error: \(error)")
        }
    }

    /// 録音停止 & 解析
    private func stopRecording(sampleRate actualSR: Double) {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        timer?.invalidate()
        timer = nil
        state = .analyzing

        let samples = audioBuffer
        let sr = actualSR

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let metrics = self?.analyze(samples: samples, sampleRate: sr)
            DispatchQueue.main.async {
                self?.latestMetrics = metrics
                self?.state = .done

                // 保存
                if let m = metrics {
                    HistoryStore.shared.save(m)
                }
            }
        }
    }

    func reset() {
        state = .idle
        latestMetrics = nil
        elapsedTime = 0
        currentLevel = 0
    }

    // MARK: - DSP解析コア

    private func analyze(samples: [Float], sampleRate sr: Double) -> VoiceMetrics {
        let f0 = estimateF0(samples: samples, sampleRate: sr)
        let jitter = calculateJitter(samples: samples, sampleRate: sr, f0: f0)
        let shimmer = calculateShimmer(samples: samples, sampleRate: sr, f0: f0)
        let hnr = calculateHNR(samples: samples, sampleRate: sr, f0: f0)
        let cpp = calculateCPP(samples: samples, sampleRate: sr)
        let alpha = calculateAlphaRatio(samples: samples, sampleRate: sr)
        let rmsDB = calculateRMSdB(samples: samples)

        let stress = interpretStress(f0: f0, alphaRatio: alpha, jitter: jitter)
        let fatigue = interpretFatigue(shimmer: shimmer, hnr: hnr, cpp: cpp)
        let stability = interpretStability(jitter: jitter, shimmer: shimmer, f0: f0)
        let overall = max(0, min(100, (stress + fatigue + stability) / 3))

        return VoiceMetrics(
            id: UUID(), date: Date(),
            f0: f0, jitter: jitter, shimmer: shimmer,
            hnr: hnr, cpp: cpp, alphaRatio: alpha, rmsDB: rmsDB,
            stressScore: stress, fatigueScore: fatigue,
            stabilityScore: stability, overallScore: overall
        )
    }

    // ── F0推定: 自己相関法 (ACF) ──
    // Rabiner & Schafer (1978) "Digital Processing of Speech Signals"
    private func estimateF0(samples: [Float], sampleRate sr: Double) -> Double {
        let frameSize = min(samples.count, Int(sr * 0.04)) // 40ms窓
        let hopSize = frameSize / 2
        var f0Sum: Double = 0
        var f0Count = 0

        let minLag = Int(sr / 500) // 500Hz上限
        let maxLag = Int(sr / 60)  // 60Hz下限

        var frameStart = 0
        while frameStart + frameSize <= samples.count {
            let frame = Array(samples[frameStart..<frameStart + frameSize])

            // ハミング窓適用
            var windowed = [Float](repeating: 0, count: frameSize)
            var window = [Float](repeating: 0, count: frameSize)
            vDSP_hamm_window(&window, vDSP_Length(frameSize), 0)
            vDSP_vmul(frame, 1, window, 1, &windowed, 1, vDSP_Length(frameSize))

            // 自己相関
            let corrLen = maxLag + 1
            var correlation = [Float](repeating: 0, count: corrLen)
            vDSP_conv(windowed, 1, windowed, 1, &correlation, 1, vDSP_Length(corrLen), vDSP_Length(frameSize))

            // ピーク検出（minLag〜maxLag間）
            guard maxLag < corrLen else { break }
            var peakVal: Float = -Float.infinity
            var peakLag = minLag

            for lag in minLag...min(maxLag, corrLen - 1) {
                if correlation[lag] > peakVal {
                    peakVal = correlation[lag]
                    peakLag = lag
                }
            }

            // 信頼度チェック: ピークがゼロラグの40%以上
            if correlation[0] > 0 && peakVal / correlation[0] > 0.4 {
                f0Sum += sr / Double(peakLag)
                f0Count += 1
            }

            frameStart += hopSize
        }

        return f0Count > 0 ? f0Sum / Double(f0Count) : 120 // フォールバック
    }

    // ── ジッター: 周期間F0変動 ──
    // Lieberman (1961) "Perturbation in Vocal Pitch"
    private func calculateJitter(samples: [Float], sampleRate sr: Double, f0: Double) -> Double {
        let periods = extractPeriods(samples: samples, sampleRate: sr, f0: f0)
        guard periods.count > 1 else { return 0 }

        var diffSum: Double = 0
        for i in 1..<periods.count {
            diffSum += abs(periods[i] - periods[i - 1])
        }
        let meanPeriod = periods.reduce(0, +) / Double(periods.count)
        guard meanPeriod > 0 else { return 0 }

        return (diffSum / Double(periods.count - 1)) / meanPeriod * 100
    }

    // ── シマー: 周期間振幅変動 ──
    // Baken & Orlikoff (2000)
    private func calculateShimmer(samples: [Float], sampleRate sr: Double, f0: Double) -> Double {
        let periodLen = Int(sr / f0)
        guard periodLen > 0 else { return 0 }

        var amplitudes: [Double] = []
        var pos = 0
        while pos + periodLen <= samples.count {
            let segment = samples[pos..<pos + periodLen]
            let peak = Double(segment.max() ?? 0) - Double(segment.min() ?? 0)
            amplitudes.append(peak)
            pos += periodLen
        }

        guard amplitudes.count > 1 else { return 0 }
        var diffSum: Double = 0
        for i in 1..<amplitudes.count {
            diffSum += abs(amplitudes[i] - amplitudes[i - 1])
        }
        let meanAmp = amplitudes.reduce(0, +) / Double(amplitudes.count)
        guard meanAmp > 0 else { return 0 }

        return (diffSum / Double(amplitudes.count - 1)) / meanAmp * 100
    }

    // ── HNR: 調波対雑音比 ──
    // Yumoto, Gould & Baer (1982)
    private func calculateHNR(samples: [Float], sampleRate sr: Double, f0: Double) -> Double {
        let periodLen = Int(sr / f0)
        guard periodLen > 10 else { return 20 }

        // 複数周期の平均波形を計算（調波成分）
        var periods: [[Float]] = []
        var pos = 0
        while pos + periodLen <= samples.count && periods.count < 50 {
            periods.append(Array(samples[pos..<pos + periodLen]))
            pos += periodLen
        }
        guard periods.count > 2 else { return 20 }

        // 平均波形 = 調波成分
        var harmonic = [Float](repeating: 0, count: periodLen)
        for p in periods {
            for i in 0..<periodLen {
                harmonic[i] += p[i]
            }
        }
        let n = Float(periods.count)
        for i in 0..<periodLen { harmonic[i] /= n }

        // 雑音 = 各周期 - 平均波形
        var noiseEnergy: Double = 0
        var harmonicEnergy: Double = 0
        for p in periods {
            for i in 0..<periodLen {
                let noise = Double(p[i] - harmonic[i])
                noiseEnergy += noise * noise
                harmonicEnergy += Double(harmonic[i]) * Double(harmonic[i])
            }
        }

        guard noiseEnergy > 0 else { return 40 }
        return 10 * log10(harmonicEnergy / noiseEnergy)
    }

    // ── CPP: ケプストラムピーク突出度 ──
    // Hillenbrand, Cleveland & Erickson (1994)
    private func calculateCPP(samples: [Float], sampleRate sr: Double) -> Double {
        let n = 4096
        guard samples.count >= n else { return 5 }

        // 中央部分を使用
        let start = max(0, (samples.count - n) / 2)
        var frame = Array(samples[start..<start + n]).map { Double($0) }

        // パワースペクトル → 対数 → IFFT = ケプストラム
        var realp = [Double](repeating: 0, count: n / 2)
        var imagp = [Double](repeating: 0, count: n / 2)

        frame.withUnsafeMutableBufferPointer { buf in
            realp.withUnsafeMutableBufferPointer { rBuf in
                imagp.withUnsafeMutableBufferPointer { iBuf in
                    var split = DSPDoubleSplitComplex(realp: rBuf.baseAddress!, imagp: iBuf.baseAddress!)
                    buf.baseAddress!.withMemoryRebound(to: DSPDoubleComplex.self, capacity: n / 2) { ptr in
                        vDSP_ctozD(ptr, 2, &split, 1, vDSP_Length(n / 2))
                    }

                    let log2n = vDSP_Length(log2(Double(n)))
                    guard let fftSetup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) else { return }
                    vDSP_fft_zripD(fftSetup, &split, 1, log2n, FFTDirection(FFT_FORWARD))

                    // パワースペクトル（対数）
                    for i in 0..<n / 2 {
                        let power = rBuf[i] * rBuf[i] + iBuf[i] * iBuf[i]
                        rBuf[i] = log(max(power, 1e-10))
                        iBuf[i] = 0
                    }

                    // 逆FFT → ケプストラム
                    vDSP_fft_zripD(fftSetup, &split, 1, log2n, FFTDirection(FFT_INVERSE))
                    vDSP_destroy_fftsetupD(fftSetup)
                }
            }
        }

        // ケプストラムのピーク検出（音声帯域: 60-500Hz → quefrency 88-735サンプル @44.1kHz）
        let minQ = Int(sr / 500)
        let maxQ = min(Int(sr / 60), n / 2 - 1)

        var peak: Double = -Double.infinity
        for q in minQ...maxQ {
            if realp[q] > peak { peak = realp[q] }
        }

        // 回帰直線からの突出度
        var sum: Double = 0
        let count = maxQ - minQ + 1
        for q in minQ...maxQ { sum += realp[q] }
        let mean = sum / Double(count)

        return max(0, peak - mean)
    }

    // ── アルファ比: 高域/低域エネルギー ──
    // Laukkanen, Vilkman et al. (1997)
    // ストレス時に声門下圧が上がり高域エネルギーが増加
    private func calculateAlphaRatio(samples: [Float], sampleRate sr: Double) -> Double {
        let n = 4096
        guard samples.count >= n else { return 0 }

        let start = max(0, (samples.count - n) / 2)
        var frame = Array(samples[start..<start + n])

        // ハミング窓
        var window = [Float](repeating: 0, count: n)
        vDSP_hamm_window(&window, vDSP_Length(n), 0)
        vDSP_vmul(frame, 1, window, 1, &frame, 1, vDSP_Length(n))

        // FFT
        var realp = [Float](repeating: 0, count: n / 2)
        var imagp = [Float](repeating: 0, count: n / 2)

        realp.withUnsafeMutableBufferPointer { rBuf in
            imagp.withUnsafeMutableBufferPointer { iBuf in
                var split = DSPSplitComplex(realp: rBuf.baseAddress!, imagp: iBuf.baseAddress!)
                frame.withUnsafeBufferPointer { fBuf in
                    fBuf.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: n / 2) { ptr in
                        vDSP_ctoz(ptr, 2, &split, 1, vDSP_Length(n / 2))
                    }
                }
                let log2n = vDSP_Length(log2(Float(n)))
                guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return }
                vDSP_fft_zrip(fftSetup, &split, 1, log2n, FFTDirection(FFT_FORWARD))
                vDSP_destroy_fftsetup(fftSetup)
            }
        }

        // 1kHz境界
        let binAt1k = Int(1000.0 / (sr / Double(n)))
        var lowEnergy: Float = 0
        var highEnergy: Float = 0

        for i in 1..<n / 2 {
            let power = realp[i] * realp[i] + imagp[i] * imagp[i]
            if i <= binAt1k {
                lowEnergy += power
            } else {
                highEnergy += power
            }
        }

        guard lowEnergy > 0 else { return 0 }
        return Double(10 * log10(highEnergy / lowEnergy))
    }

    private func calculateRMSdB(samples: [Float]) -> Double {
        var rms: Float = 0
        vDSP_measqv(samples, 1, &rms, vDSP_Length(samples.count))
        let rmsVal = sqrt(rms)
        return 20 * log10(max(Double(rmsVal), 1e-10)) + 90 // 概算dB SPL
    }

    // ── 周期抽出ヘルパー ──
    private func extractPeriods(samples: [Float], sampleRate sr: Double, f0: Double) -> [Double] {
        let nominalPeriod = Int(sr / f0)
        guard nominalPeriod > 10 else { return [] }

        var periods: [Double] = []
        var pos = 0

        // ゼロクロッシング法で周期検出
        while pos + nominalPeriod * 2 < samples.count && periods.count < 100 {
            // 次の正方向ゼロクロスを探す
            var nextCross = pos + nominalPeriod / 2
            let searchEnd = min(pos + nominalPeriod * 2, samples.count - 1)

            while nextCross < searchEnd {
                if samples[nextCross] <= 0 && samples[nextCross + 1] > 0 {
                    break
                }
                nextCross += 1
            }

            if nextCross < searchEnd && pos > 0 {
                periods.append(Double(nextCross - pos) / sr)
            }
            pos = nextCross
        }

        return periods
    }

    // MARK: - 解釈エンジン

    /// ストレススコア (0=リラックス, 100=高ストレス)
    /// F0上昇 + アルファ比上昇 + ジッター上昇 = ストレス
    /// Scherer (1986) "Vocal affect expression"
    private func interpretStress(f0: Double, alphaRatio: Double, jitter: Double) -> Int {
        var score: Double = 50

        // F0: 平均的な値からの偏差（高いほどストレス）
        if f0 > 200 { score += (f0 - 200) * 0.3 }
        if f0 > 250 { score += (f0 - 250) * 0.5 }

        // アルファ比: 正の値が大きいほどストレス
        score += alphaRatio * 3

        // ジッター: 高いほど不安定
        score += (jitter - 1.0) * 10

        return max(0, min(100, Int(score)))
    }

    /// 疲労スコア (0=元気, 100=疲労困憊)
    /// シマー上昇 + HNR低下 + CPP低下 = 疲労
    /// Gelfer & Young (1997) "Comparisons of intensity measures"
    private func interpretFatigue(shimmer: Double, hnr: Double, cpp: Double) -> Int {
        var score: Double = 50

        // シマー: 3.81%超で疲労兆候
        score += (shimmer - 3.0) * 8

        // HNR: 20dB以下で疲労
        score += (20 - hnr) * 3

        // CPP: 低いほど疲労
        score += (5 - cpp) * 5

        return max(0, min(100, Int(score)))
    }

    /// 安定度スコア (0=不安定, 100=安定)
    private func interpretStability(jitter: Double, shimmer: Double, f0: Double) -> Int {
        var score: Double = 80

        // ジッター: 低いほど安定
        score -= jitter * 15

        // シマー: 低いほど安定
        score -= shimmer * 5

        // F0が極端に低い/高い場合は不安定
        if f0 < 80 || f0 > 300 { score -= 15 }

        return max(0, min(100, Int(score)))
    }
}
