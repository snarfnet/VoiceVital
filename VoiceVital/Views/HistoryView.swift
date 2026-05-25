import SwiftUI
import Charts

struct HistoryView: View {
    private let store = HistoryStore.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if store.records.isEmpty {
                        emptyState
                    } else {
                        trendChart
                        recentRecords
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("記録")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 80)
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            Text("まだ記録がありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("「測定」タブで声を録音すると\nここにトレンドが表示されます")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("トレンド")
                .font(.headline)

            let trends = store.trends(days: 14)

            if trends.count >= 2 {
                Chart {
                    ForEach(trends) { t in
                        LineMark(
                            x: .value("日", t.date, unit: .day),
                            y: .value("スコア", t.overallScore)
                        )
                        .foregroundStyle(.cyan)
                        .symbol(Circle())

                        LineMark(
                            x: .value("日", t.date, unit: .day),
                            y: .value("ストレス", t.stressScore)
                        )
                        .foregroundStyle(.red.opacity(0.6))
                        .lineStyle(StrokeStyle(dash: [5, 3]))

                        LineMark(
                            x: .value("日", t.date, unit: .day),
                            y: .value("疲労", t.fatigueScore)
                        )
                        .foregroundStyle(.orange.opacity(0.6))
                        .lineStyle(StrokeStyle(dash: [5, 3]))
                    }
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 25, 50, 75, 100])
                }
                .frame(height: 200)

                HStack(spacing: 16) {
                    legendDot("総合", color: .cyan)
                    legendDot("ストレス", color: .red.opacity(0.6))
                    legendDot("疲労", color: .orange.opacity(0.6))
                }
                .font(.caption2)
            } else {
                Text("2日以上のデータが集まるとグラフが表示されます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var recentRecords: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近の記録")
                .font(.headline)
                .padding(.horizontal)

            ForEach(store.records.prefix(20)) { r in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(r.date, style: .date)
                            .font(.subheadline)
                        Text(r.date, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        miniScore("S", value: r.stressScore, color: r.stressScore > 60 ? .red : .green)
                        miniScore("F", value: r.fatigueScore, color: r.fatigueScore > 60 ? .red : .green)
                        miniScore("安", value: r.stabilityScore, color: r.stabilityScore < 40 ? .red : .green)
                    }
                    Text("\(r.overallScore)")
                        .font(.title3.bold().monospacedDigit())
                        .foregroundStyle(.cyan)
                        .frame(width: 40, alignment: .trailing)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private func legendDot(_ label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }

    private func miniScore(_ label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 1) {
            Text("\(value)")
                .font(.caption.bold().monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
    }
}
