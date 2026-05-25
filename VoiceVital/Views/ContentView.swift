import SwiftUI

struct ContentView: View {
    @State private var analyzer = VoiceAnalyzer()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            RecordingView(analyzer: analyzer)
                .tabItem {
                    Label("測定", systemImage: "waveform.circle.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("記録", systemImage: "chart.xyaxis.line")
                }
                .tag(1)

            InfoView()
                .tabItem {
                    Label("解説", systemImage: "book.closed.fill")
                }
                .tag(2)
        }
        .tint(.cyan)
    }
}
