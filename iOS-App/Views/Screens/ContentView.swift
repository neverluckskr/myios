import SwiftUI

struct ContentView: View {
    @State private var selectedTab: DiiaTab = .documents
    @State private var store = DocumentStore()

    var body: some View {
        ZStack {
            DiiaGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                screen
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                DiiaTabBar(selectedTab: $selectedTab)
            }
        }
        .environment(store)
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private var screen: some View {
        switch selectedTab {
        case .documents:
            DocumentsScreen()
        case .menu:
            MenuScreen()
        default:
            Color.clear
        }
    }
}

#Preview {
    ContentView()
}
