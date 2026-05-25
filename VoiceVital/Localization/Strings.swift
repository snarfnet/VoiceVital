import Foundation

enum L {
    // MARK: - Tabs
    static let tabMeasure = String(localized: "tab_measure", defaultValue: "測定")
    static let tabHistory = String(localized: "tab_history", defaultValue: "記録")
    static let tabInfo = String(localized: "tab_info", defaultValue: "解説")

    // MARK: - Recording
    static let appTitle = String(localized: "app_title", defaultValue: "ボイスバイタル")
    static let checkWithVoice = String(localized: "check_with_voice", defaultValue: "声で体調をチェック")
    static let sayAh5sec = String(localized: "say_ah_5sec", defaultValue: "「あー」と5秒間発声してください")
    static let startMeasure = String(localized: "start_measure", defaultValue: "測定開始")
    static let quietPlace = String(localized: "quiet_place", defaultValue: "静かな場所で測定してください")
    static let micDistance = String(localized: "mic_distance", defaultValue: "マイクから20cm程度離して発声")
    static let keepSaying = String(localized: "keep_saying", defaultValue: "「あー」と声を出し続けてください")
    static let analyzing = String(localized: "analyzing", defaultValue: "音声を解析中...")
    static let analysisParams = String(localized: "analysis_params", defaultValue: "F0 / ジッター / シマー / HNR / CPP / α比")
    static let seconds = String(localized: "seconds", defaultValue: "秒")

    // MARK: - Result
    static let overallScore = String(localized: "overall_score", defaultValue: "総合スコア")
    static let stress = String(localized: "stress", defaultValue: "ストレス")
    static let fatigue = String(localized: "fatigue", defaultValue: "疲労")
    static let stability = String(localized: "stability", defaultValue: "安定度")
    static let acousticParams = String(localized: "acoustic_params", defaultValue: "音響パラメータ")
    static let normalValue = String(localized: "normal_value", defaultValue: "正常値")
    static let condition = String(localized: "condition", defaultValue: "コンディション")
    static let share = String(localized: "share", defaultValue: "共有")
    static let retry = String(localized: "retry", defaultValue: "再測定")
    static let disclaimer = String(localized: "disclaimer", defaultValue: "本アプリは医療機器ではありません。結果は参考値です。体調に不安がある場合は医療機関を受診してください。")

    // MARK: - Param names
    static let paramF0 = String(localized: "param_f0", defaultValue: "基本周波数 (F0)")
    static let paramJitter = String(localized: "param_jitter", defaultValue: "ジッター")
    static let paramShimmer = String(localized: "param_shimmer", defaultValue: "シマー")
    static let paramHNR = String(localized: "param_hnr", defaultValue: "HNR (調波対雑音比)")
    static let paramCPP = String(localized: "param_cpp", defaultValue: "CPP (ケプストラムピーク突出度)")
    static let paramAlpha = String(localized: "param_alpha", defaultValue: "α比 (Alpha Ratio)")
    static let paramRMS = String(localized: "param_rms", defaultValue: "音圧")

    // MARK: - Overall labels
    static let excellent = String(localized: "excellent", defaultValue: "絶好調")
    static let good = String(localized: "good", defaultValue: "良好")
    static let caution = String(localized: "caution", defaultValue: "やや注意")
    static let warning = String(localized: "warning", defaultValue: "要注意")
    static let restNeeded = String(localized: "rest_needed", defaultValue: "休息が必要")

    // MARK: - Advice
    static let adviceStress = String(localized: "advice_stress", defaultValue: "ストレスの兆候が見られます。F0の上昇とα比の増加は、声門下圧の上昇を示唆しています。深呼吸やストレッチで副交感神経を活性化させましょう。")
    static let adviceFatigue = String(localized: "advice_fatigue", defaultValue: "声帯疲労の兆候があります。シマーの上昇とHNRの低下は、声帯の閉鎖不全を示しています。水分を摂り、声を休ませてください。")
    static let adviceStability = String(localized: "advice_stability", defaultValue: "声の安定度が低下しています。ジッターの上昇は、声帯の規則的振動が乱れている状態です。十分な睡眠を取りましょう。")
    static let adviceGood = String(localized: "advice_good", defaultValue: "声の状態は良好です。各パラメータが正常範囲内に収まっています。この調子を維持しましょう。")

    // MARK: - History
    static let noRecords = String(localized: "no_records", defaultValue: "まだ記録がありません")
    static let noRecordsHint = String(localized: "no_records_hint", defaultValue: "「測定」タブで声を録音すると\nここにトレンドが表示されます")
    static let trend = String(localized: "trend", defaultValue: "トレンド")
    static let trendHint = String(localized: "trend_hint", defaultValue: "2日以上のデータが集まるとグラフが表示されます")
    static let recentRecords = String(localized: "recent_records", defaultValue: "最近の記録")
    static let overall = String(localized: "overall", defaultValue: "総合")

    // MARK: - Info
    static let aboutTitle = String(localized: "about_title", defaultValue: "このアプリについて")
    static let aboutDesc1 = String(localized: "about_desc1", defaultValue: "ボイスバイタルは、5秒間の持続母音「あー」を音響解析し、声の状態からストレス・疲労の傾向を可視化するセルフモニタリングツールです。")
    static let aboutDesc2 = String(localized: "about_desc2", defaultValue: "音声病理学・心理音響学の学術研究に基づく6つの音響パラメータを計測します。")
    static let measuredParams = String(localized: "measured_params", defaultValue: "計測パラメータ")
    static let interpretation = String(localized: "interpretation", defaultValue: "解釈について")
    static let interpDesc1 = String(localized: "interp_desc1", defaultValue: "各パラメータの正常値は健常成人の大規模研究から導出されたものです。個人差（性別・年齢・喫煙歴等）により基準値は変動します。")
    static let interpDesc2 = String(localized: "interp_desc2", defaultValue: "毎日同じ時間・同じ条件で測定し、自分自身のベースラインからの変化を追跡することが最も有効な活用法です。")
    static let medicalDisclaimer = String(localized: "medical_disclaimer", defaultValue: "本アプリは医療機器ではありません。診断・治療を目的としたものではなく、結果は参考値です。")

    // Param descriptions
    static let descF0 = String(localized: "desc_f0", defaultValue: "声帯振動の基本ピッチ。ストレス下では交感神経の亢進により喉頭筋の緊張が増し、F0が上昇します。")
    static let descJitter = String(localized: "desc_jitter", defaultValue: "声帯振動の周期間変動率。神経筋制御の微細な乱れを反映します。疲労・睡眠不足・加齢で上昇。1.04%以下が正常。")
    static let descShimmer = String(localized: "desc_shimmer", defaultValue: "声帯振動の振幅変動率。声帯の質量非対称性や粘膜波の乱れを反映。声帯疲労・炎症の初期指標。3.81%以下が正常。")
    static let descHNR = String(localized: "desc_hnr", defaultValue: "声の周期成分と非周期成分の比率。声帯閉鎖不全による気息性嗄声の定量的指標。20dB以上が正常。")
    static let descCPP = String(localized: "desc_cpp", defaultValue: "ケプストラム解析による声質の客観的評価。発声障害の重症度との相関が最も高い単一指標として知られます。")
    static let descAlpha = String(localized: "desc_alpha", defaultValue: "1kHz境界での高域・低域スペクトルエネルギー比。心理的ストレス下では声門下圧の上昇に伴い高域成分が増加します。")

    // Share
    static func shareText(score: Int, stress: Int, fatigue: Int, stability: Int) -> String {
        String(localized: "share_text \(score) \(stress) \(fatigue) \(stability)",
               defaultValue: "ボイスバイタル結果: 総合\(score)点 | ストレス\(stress) | 疲労\(fatigue) | 安定\(stability) #ボイスバイタル")
    }
}
