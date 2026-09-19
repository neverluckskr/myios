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
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 3) {
                Image(selectedTab == tab ? tab.selectedIconName : tab.iconName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
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
