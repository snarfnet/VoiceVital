import SwiftUI

struct ResultView: View {
    let metrics: VoiceMetrics
    let onRetry: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 12)

                // 総合スコア
                ZStack {
                    Circle()
                        .stroke(scoreColor(metrics.overallScore).opacity(0.2), lineWidth: 16)
                        .frame(width: 160, height: 160)
                    Circle()
                        .trim(from: 0, to: CGFloat(metrics.overallScore) / 100)
                        .stroke(scoreColor(metrics.overallScore), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(metrics.overallScore)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor(metrics.overallScore))
                        Text("総合スコア")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                    }
                }

                Text(overallLabel(metrics.overallScore))
                    .font(.title3.bold())

                // 3指標ゲージ
                HStack(spacing: 16) {
                    gaugeCard("ストレス", score: metrics.stressScore,
                              icon: "brain.head.profile", color: stressColor(metrics.stressScore))
                    gaugeCard("疲労", score: metrics.fatigueScore,
                              icon: "battery.25percent", color: fatigueColor(metrics.fatigueScore))
                    gaugeCard("安定度", score: metrics.stabilityScore,
                              icon: "waveform.path", color: stabilityColor(metrics.stabilityScore))
                }
                .padding(.horizontal)

                // 音響パラメータ詳細
                VStack(alignment: .leading, spacing: 12) {
                    Text("音響パラメータ")
                        .font(.headline)

                    paramRow("基本周波数 (F0)", value: String(format: "%.1f Hz", metrics.f0),
                             normal: "85-255 Hz", ref: "Titze 1994")
                    paramRow("ジッター", value: String(format: "%.2f %%", metrics.jitter),
                             normal: "< 1.04%", ref: "Baken & Orlikoff 2000")
                    paramRow("シマー", value: String(format: "%.2f %%", metrics.shimmer),
                             normal: "< 3.81%", ref: "Baken & Orlikoff 2000")
                    paramRow("HNR", value: String(format: "%.1f dB", metrics.hnr),
                             normal: "> 20 dB", ref: "Yumoto et al. 1982")
                    paramRow("CPP", value: String(format: "%.1f dB", metrics.cpp),
                             normal: "> 4.0 dB", ref: "Hillenbrand 1994")
                    paramRow("α比", value: String(format: "%.1f dB", metrics.alphaRatio),
                             normal: "-12 ~ -2 dB", ref: "Laukkanen 1997")
                    paramRow("音圧", value: String(format: "%.0f dB", metrics.rmsDB),
                             normal: "60-80 dB", ref: "—")
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // アドバイス
                VStack(alignment: .leading, spacing: 8) {
                    Label("コンディション", systemImage: "stethoscope")
                        .font(.headline)
                        .foregroundStyle(.cyan)

                    Text(advice(metrics))
                        .font(.subheadline)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cyan.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // 注意書き
                Text("本アプリは医療機器ではありません。結果は参考値です。体調に不安がある場合は医療機関を受診してください。")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // ボタン
                HStack(spacing: 16) {
                    ShareLink(item: shareText(metrics)) {
                        Label("共有", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)

                    Button(action: onRetry) {
                        Label("再測定", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Components

    private func gaugeCard(_ title: String, score: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            Text("\(score)")
                .font(.headline.monospacedDigit())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func paramRow(_ name: String, value: String, normal: String, ref: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text(value)
                    .font(.subheadline.bold().monospacedDigit())
            }
            HStack {
                Text("正常値: \(normal)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(ref)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Divider()
        }
    }

    // MARK: - Helpers

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0..<30: return .red
        case 30..<50: return .orange
        case 50..<70: return .yellow
        case 70..<85: return .mint
        default: return .green
        }
    }

    private func stressColor(_ s: Int) -> Color {
        s > 70 ? .red : s > 40 ? .orange : .green
    }
    private func fatigueColor(_ s: Int) -> Color {
        s > 70 ? .red : s > 40 ? .orange : .green
    }
    private func stabilityColor(_ s: Int) -> Color {
        s < 30 ? .red : s < 60 ? .orange : .green
    }

    private func overallLabel(_ score: Int) -> String {
        switch score {
        case 80...100: return "絶好調"
        case 65..<80: return "良好"
        case 50..<65: return "やや注意"
        case 35..<50: return "要注意"
        default: return "休息が必要"
        }
    }

    private func advice(_ m: VoiceMetrics) -> String {
        var lines: [String] = []

        if m.stressScore > 60 {
            lines.append("ストレスの兆候が見られます。F0の上昇とα比の増加は、声門下圧の上昇を示唆しています。深呼吸やストレッチで副交感神経を活性化させましょう。")
        }
        if m.fatigueScore > 60 {
            lines.append("声帯疲労の兆候があります。シマーの上昇とHNRの低下は、声帯の閉鎖不全を示しています。水分を摂り、声を休ませてください。")
        }
        if m.stabilityScore < 40 {
            lines.append("声の安定度が低下しています。ジッターの上昇は、声帯の規則的振動が乱れている状態です。十分な睡眠を取りましょう。")
        }
        if lines.isEmpty {
            lines.append("声の状態は良好です。各パラメータが正常範囲内に収まっています。この調子を維持しましょう。")
        }

        return lines.joined(separator: "\n\n")
    }

    private func shareText(_ m: VoiceMetrics) -> String {
        "ボイスバイタル結果: 総合\(m.overallScore)点 | ストレス\(m.stressScore) | 疲労\(m.fatigueScore) | 安定\(m.stabilityScore) #ボイスバイタル"
    }
}
