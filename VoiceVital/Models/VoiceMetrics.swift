import Foundation

/// 音声解析結果
/// 参考文献:
/// - Titze, I.R. (1994) "Principles of Voice Production" — F0基準値
/// - Baken & Orlikoff (2000) "Clinical Measurement of Speech and Voice" — Jitter/Shimmer正常値
/// - Yumoto et al. (1982) "Harmonics-to-Noise Ratio as an Index of Hoarseness" — HNR基準
/// - Hillenbrand et al. (1994) "Acoustic correlates of breathy vocal quality" — CPP
/// - Laukkanen et al. (1997) — Alpha Ratio（ストレス時の高域エネルギー上昇）
struct VoiceMetrics: Codable, Identifiable {
    let id: UUID
    let date: Date

    // ── 基本音響パラメータ ──
    /// 基本周波数 (Hz) — 声帯振動の基本ピッチ
    /// 男性正常値: 85-180Hz, 女性正常値: 165-255Hz (Titze 1994)
    let f0: Double

    /// ジッター (%) — F0の周期変動率
    /// 正常値: < 1.04% (Baken & Orlikoff 2000)
    /// 疲労・ストレスで上昇
    let jitter: Double

    /// シマー (%) — 振幅の周期変動率
    /// 正常値: < 3.81% (Baken & Orlikoff 2000)
    /// 声帯疲労・炎症で上昇
    let shimmer: Double

    /// 調波対雑音比 (dB) — 声の透明度
    /// 正常値: > 20dB (Yumoto et al. 1982)
    /// 低下 = 嗄声・気息性
    let hnr: Double

    /// ケプストラムピーク突出度 (dB) — 発声障害の最強単一予測因子
    /// 正常値: > 4.0dB (Hillenbrand 1994)
    let cpp: Double

    /// アルファ比 (dB) — 1kHz境界の高域/低域エネルギー比
    /// ストレス下で上昇 (Laukkanen 1997)
    let alphaRatio: Double

    /// RMS振幅 (dB SPL相当)
    let rmsDB: Double

    // ── 解釈スコア (0-100) ──
    let stressScore: Int
    let fatigueScore: Int
    let stabilityScore: Int
    let overallScore: Int
}

struct DailyTrend: Identifiable {
    let id = UUID()
    let date: Date
    let overallScore: Int
    let stressScore: Int
    let fatigueScore: Int
}
