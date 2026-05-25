import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section("このアプリについて") {
                        Text("ボイスバイタルは、5秒間の持続母音「あー」を音響解析し、声の状態からストレス・疲労の傾向を可視化するセルフモニタリングツールです。")
                        Text("音声病理学・心理音響学の学術研究に基づく6つの音響パラメータを計測します。")
                    }

                    section("計測パラメータ") {
                        paramInfo("基本周波数 (F0)",
                                  desc: "声帯振動の基本ピッチ。ストレス下では交感神経の亢進により喉頭筋の緊張が増し、F0が上昇します。",
                                  ref: "Titze, I.R. (1994) Principles of Voice Production. Prentice Hall.")

                        paramInfo("ジッター (Jitter)",
                                  desc: "声帯振動の周期間変動率。神経筋制御の微細な乱れを反映します。疲労・睡眠不足・加齢で上昇。1.04%以下が正常。",
                                  ref: "Baken, R.J. & Orlikoff, R.F. (2000) Clinical Measurement of Speech and Voice. Singular.")

                        paramInfo("シマー (Shimmer)",
                                  desc: "声帯振動の振幅変動率。声帯の質量非対称性や粘膜波の乱れを反映。声帯疲労・炎症の初期指標。3.81%以下が正常。",
                                  ref: "Baken, R.J. & Orlikoff, R.F. (2000)")

                        paramInfo("HNR (調波対雑音比)",
                                  desc: "声の周期成分と非周期成分の比率。声帯閉鎖不全による気息性嗄声の定量的指標。20dB以上が正常。",
                                  ref: "Yumoto, E., Gould, W.J. & Baer, T. (1982) JASA, 71(6), 1544-1550.")

                        paramInfo("CPP (ケプストラムピーク突出度)",
                                  desc: "ケプストラム解析による声質の客観的評価。発声障害の重症度との相関が最も高い単一指標として知られます。",
                                  ref: "Hillenbrand, J. et al. (1994) JSLHR, 37, 769-778.")

                        paramInfo("α比 (Alpha Ratio)",
                                  desc: "1kHz境界での高域・低域スペクトルエネルギー比。心理的ストレス下では声門下圧の上昇に伴い高域成分が増加します。",
                                  ref: "Laukkanen, A.M. et al. (1997) Folia Phoniatrica et Logopaedica, 49, 37-47.")
                    }

                    section("解釈について") {
                        Text("各パラメータの正常値は健常成人の大規模研究から導出されたものです。個人差（性別・年齢・喫煙歴等）により基準値は変動します。")
                        Text("毎日同じ時間・同じ条件で測定し、自分自身のベースラインからの変化を追跡することが最も有効な活用法です。")

                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("本アプリは医療機器ではありません。診断・治療を目的としたものではなく、結果は参考値です。")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("解説")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
            content()
        }
    }

    private func paramInfo(_ name: String, desc: String, ref: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.subheadline.bold())
                .foregroundStyle(.cyan)
            Text(desc)
                .font(.caption)
                .lineSpacing(3)
            Text(ref)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .italic()
            Divider()
        }
    }
}
