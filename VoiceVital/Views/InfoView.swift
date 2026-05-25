import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section(L.aboutTitle) {
                        Text(L.aboutDesc1)
                        Text(L.aboutDesc2)
                    }

                    section(L.measuredParams) {
                        paramInfo(L.paramF0, desc: L.descF0,
                                  ref: "Titze, I.R. (1994) Principles of Voice Production. Prentice Hall.")
                        paramInfo(L.paramJitter, desc: L.descJitter,
                                  ref: "Baken, R.J. & Orlikoff, R.F. (2000) Clinical Measurement of Speech and Voice. Singular.")
                        paramInfo(L.paramShimmer, desc: L.descShimmer,
                                  ref: "Baken, R.J. & Orlikoff, R.F. (2000)")
                        paramInfo(L.paramHNR, desc: L.descHNR,
                                  ref: "Yumoto, E., Gould, W.J. & Baer, T. (1982) JASA, 71(6), 1544-1550.")
                        paramInfo(L.paramCPP, desc: L.descCPP,
                                  ref: "Hillenbrand, J. et al. (1994) JSLHR, 37, 769-778.")
                        paramInfo(L.paramAlpha, desc: L.descAlpha,
                                  ref: "Laukkanen, A.M. et al. (1997) Folia Phoniatrica et Logopaedica, 49, 37-47.")
                    }

                    section(L.interpretation) {
                        Text(L.interpDesc1)
                        Text(L.interpDesc2)

                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(L.medicalDisclaimer)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L.tabInfo)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3.bold())
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
