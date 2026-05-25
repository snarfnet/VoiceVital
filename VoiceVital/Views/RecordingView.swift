import SwiftUI

struct RecordingView: View {
    @Bindable var analyzer: VoiceAnalyzer

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                switch analyzer.state {
                case .idle:
                    idleView
                case .recording:
                    recordingView
                case .analyzing:
                    analyzingView
                case .done:
                    if let m = analyzer.latestMetrics {
                        ResultView(metrics: m, onRetry: { analyzer.reset() })
                    }
                }
            }
            .navigationTitle("ボイスバイタル")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var idleView: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.cyan.opacity(0.08))
                    .frame(width: 220, height: 220)
                Circle()
                    .fill(.cyan.opacity(0.15))
                    .frame(width: 160, height: 160)
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.cyan)
            }

            VStack(spacing: 8) {
                Text("声で体調をチェック")
                    .font(.title2.bold())
                Text("「あー」と5秒間発声してください")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                analyzer.startRecording()
            } label: {
                Text("測定開始")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            .padding(.horizontal, 48)

            VStack(spacing: 4) {
                Text("静かな場所で測定してください")
                Text("マイクから20cm程度離して発声")
            }
            .font(.caption)
            .foregroundStyle(.tertiary)

            Spacer()
        }
    }

    private var recordingView: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                // パルスアニメーション
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(.cyan.opacity(0.3), lineWidth: 2)
                        .frame(width: 180 + CGFloat(i) * 40,
                               height: 180 + CGFloat(i) * 40)
                        .scaleEffect(1 + CGFloat(analyzer.currentLevel) * 2)
                        .animation(.easeInOut(duration: 0.3), value: analyzer.currentLevel)
                }

                Circle()
                    .fill(.cyan.gradient)
                    .frame(width: 160, height: 160)
                    .shadow(color: .cyan.opacity(0.5), radius: 20)

                VStack(spacing: 4) {
                    Text(String(format: "%.1f", analyzer.elapsedTime))
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    Text("/ 5.0 秒")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            // レベルメーター
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.cyan.gradient)
                        .frame(width: geo.size.width * CGFloat(min(analyzer.currentLevel * 5, 1.0)))
                        .animation(.easeOut(duration: 0.1), value: analyzer.currentLevel)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 40)

            Text("「あー」と声を出し続けてください")
                .font(.headline)
                .foregroundStyle(.cyan)

            // プログレスバー
            ProgressView(value: analyzer.elapsedTime / 5.0)
                .tint(.cyan)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var analyzingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.cyan)
            Text("音声を解析中...")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("F0 / ジッター / シマー / HNR / CPP / α比")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}
