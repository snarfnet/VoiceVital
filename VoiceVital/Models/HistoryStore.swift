import Foundation

@Observable
final class HistoryStore {
    static let shared = HistoryStore()
    private(set) var records: [VoiceMetrics] = []

    private let key = "voice_history"

    private init() { load() }

    func save(_ metrics: VoiceMetrics) {
        records.insert(metrics, at: 0)
        // 最大90日分保持
        if records.count > 90 { records = Array(records.prefix(90)) }
        persist()
    }

    func trends(days: Int = 30) -> [DailyTrend] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { m in
            calendar.startOfDay(for: m.date)
        }
        return grouped.map { date, metrics in
            let avg = metrics.reduce(0) { $0 + $1.overallScore } / metrics.count
            let stress = metrics.reduce(0) { $0 + $1.stressScore } / metrics.count
            let fatigue = metrics.reduce(0) { $0 + $1.fatigueScore } / metrics.count
            return DailyTrend(date: date, overallScore: avg, stressScore: stress, fatigueScore: fatigue)
        }
        .sorted { $0.date < $1.date }
        .suffix(days)
        .map { $0 }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([VoiceMetrics].self, from: data) else { return }
        records = decoded
    }
}
