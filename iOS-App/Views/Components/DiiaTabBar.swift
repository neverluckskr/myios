import SwiftUI

struct DiiaTabBar: View {
    @Binding var selectedTab: DiiaTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DiiaTab.allCases, id: \.rawValue) { tab in
                tabItem(tab)
            }
        }
        .frame(height: 70)
        .background(Color.black.ignoresSafeArea(edges: .bottom))
    }

    private func tabItem(_ tab: DiiaTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 3) {
                icon(for: tab, isSelected: isSelected)
                    .frame(width: 24, height: 24)

                Text(tab.title)
                    .font(DiiaFont.tabBarTitle)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }

    @ViewBuilder
    private func icon(for tab: DiiaTab, isSelected: Bool) -> some View {
        switch tab.icon(selected: isSelected) {
        case .asset(let name):
            Image(name)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()

        case .symbol(let name):
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        VStack {
            Spacer()
            DiiaTabBar(selectedTab: .constant(.feed))
        }
    }
}
