import SwiftUI

struct ResultView: View {
    let metrics: VoiceMetrics
    let onRetry: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 12)

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
                        Text(L.overallScore)
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                    }
                }

                Text(overallLabel(metrics.overallScore))
                    .font(.title3.bold())

                HStack(spacing: 16) {
                    gaugeCard(L.stress, score: metrics.stressScore,
                              icon: "brain.head.profile", color: alertColor(metrics.stressScore))
                    gaugeCard(L.fatigue, score: metrics.fatigueScore,
                              icon: "battery.25percent", color: alertColor(metrics.fatigueScore))
                    gaugeCard(L.stability, score: metrics.stabilityScore,
                              icon: "waveform.path", color: stabilityColor(metrics.stabilityScore))
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text(L.acousticParams)
                        .font(.headline)

                    paramRow(L.paramF0, value: String(format: "%.1f Hz", metrics.f0),
                             normal: "85-255 Hz", ref: "Titze 1994")
                    paramRow(L.paramJitter, value: String(format: "%.2f %%", metrics.jitter),
                             normal: "< 1.04%", ref: "Baken & Orlikoff 2000")
                    paramRow(L.paramShimmer, value: String(format: "%.2f %%", metrics.shimmer),
                             normal: "< 3.81%", ref: "Baken & Orlikoff 2000")
                    paramRow(L.paramHNR, value: String(format: "%.1f dB", metrics.hnr),
                             normal: "> 20 dB", ref: "Yumoto et al. 1982")
                    paramRow(L.paramCPP, value: String(format: "%.1f dB", metrics.cpp),
                             normal: "> 4.0 dB", ref: "Hillenbrand 1994")
                    paramRow(L.paramAlpha, value: String(format: "%.1f dB", metrics.alphaRatio),
                             normal: "-12 ~ -2 dB", ref: "Laukkanen 1997")
                    paramRow(L.paramRMS, value: String(format: "%.0f dB", metrics.rmsDB),
                             normal: "60-80 dB", ref: "—")
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Label(L.condition, systemImage: "stethoscope")
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

                Text(L.disclaimer)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                HStack(spacing: 16) {
                    ShareLink(item: L.shareText(score: metrics.overallScore, stress: metrics.stressScore, fatigue: metrics.fatigueScore, stability: metrics.stabilityScore)) {
                        Label(L.share, systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)

                    Button(action: onRetry) {
                        Label(L.retry, systemImage: "arrow.counterclockwise")
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
                Text(name).font(.subheadline)
                Spacer()
                Text(value).font(.subheadline.bold().monospacedDigit())
            }
            HStack {
                Text("\(L.normalValue): \(normal)")
                    .font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text(ref).font(.caption2).foregroundStyle(.tertiary)
            }
            Divider()
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0..<30: return .red
        case 30..<50: return .orange
        case 50..<70: return .yellow
        case 70..<85: return .mint
        default: return .green
        }
    }

    private func alertColor(_ s: Int) -> Color {
        s > 70 ? .red : s > 40 ? .orange : .green
    }
    private func stabilityColor(_ s: Int) -> Color {
        s < 30 ? .red : s < 60 ? .orange : .green
    }

    private func overallLabel(_ score: Int) -> String {
        switch score {
        case 80...100: return L.excellent
        case 65..<80: return L.good
        case 50..<65: return L.caution
        case 35..<50: return L.warning
        default: return L.restNeeded
        }
    }

    private func advice(_ m: VoiceMetrics) -> String {
        var lines: [String] = []
        if m.stressScore > 60 { lines.append(L.adviceStress) }
        if m.fatigueScore > 60 { lines.append(L.adviceFatigue) }
        if m.stabilityScore < 40 { lines.append(L.adviceStability) }
        if lines.isEmpty { lines.append(L.adviceGood) }
        return lines.joined(separator: "\n\n")
    }
}
