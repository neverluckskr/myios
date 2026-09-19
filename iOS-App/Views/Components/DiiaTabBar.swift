import SwiftUI

struct DiiaTabBar: View {
    @Binding var selectedTab: DiiaTab

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(DiiaTab.allCases, id: \.rawValue) { tab in
                    tabItem(tab)
                }
            }
            .frame(height: 70)
            .background(DiiaColors.tabBarBackground)
        }
        .background(DiiaColors.tabBarBackground)
    }

    private func tabItem(_ tab: DiiaTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: selectedTab == tab ? tab.selectedIconName : tab.iconName)
                    .font(.system(size: 24))
                    .frame(height: 24)

                Text(tab.title)
                    .font(.system(size: 10, weight: .regular))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.4))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }
}

#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()

        VStack {
            Spacer()
            DiiaTabBar(selectedTab: .constant(.feed))
        }
    }
}
