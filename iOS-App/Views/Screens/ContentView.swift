import SwiftUI

struct ContentView: View {
    @State private var selectedTab: DiiaTab = .feed

    var body: some View {
        ZStack {
            DiiaGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                DiiaTabBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
