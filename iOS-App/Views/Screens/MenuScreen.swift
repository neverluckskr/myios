import SwiftUI

struct MenuScreen: View {
    @Environment(DocumentStore.self) private var store

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Меню")
                        .font(DiiaFont.main(size: 32))
                        .foregroundStyle(.black)

                    Spacer()

                    NavigationLink {
                        DocumentSettingsScreen()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44)
                    }
                }

                profileCard

                Spacer()
            }
            .padding(.horizontal, DiiaLayout.sideSpacing)
            .padding(.top, 16)
            .background(Color.clear)
        }
        .tint(.black)
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.black.opacity(0.25))

            VStack(alignment: .leading, spacing: 4) {
                Text(store.documents.first?.fullName.replacingOccurrences(of: "\n", with: " ") ?? "")
                    .font(DiiaFont.smallHeading)
                    .foregroundStyle(.black)
                Text("Профіль")
                    .font(DiiaFont.usual)
                    .foregroundStyle(Color.black.opacity(0.5))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        MenuScreen().environment(DocumentStore())
    }
}
