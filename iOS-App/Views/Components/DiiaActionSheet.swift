import SwiftUI

struct DiiaAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var handler: (() -> Void)?
}

/// design_system_code: ActionSheetV2
///
/// Groups of white rows in a rounded panel, with a separate full-width Close
/// button beneath it. Tapping the dimmed backdrop closes it too.
struct DiiaActionSheet: View {
    let groups: [[DiiaAction]]
    let onClose: () -> Void

    private static let cornerRadius: CGFloat = 16
    private static let spacing: CGFloat = 20
    private static let closeButtonHeight: CGFloat = 58

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            panel
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
                .padding(.bottom, Self.spacing / 2)

            Button(action: onClose) {
                Text("Закрити")
                    .font(DiiaFont.smallHeading)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: Self.closeButtonHeight)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Self.spacing)
        .padding(.bottom, Self.spacing)
    }

    private var panel: some View {
        VStack(spacing: 0) {
            ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                if index > 0 {
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, Self.spacing)
                }

                ForEach(group) { action in
                    row(action)
                }
            }
        }
    }

    private func row(_ action: DiiaAction) -> some View {
        Button {
            onClose()
            action.handler?()
        } label: {
            HStack(spacing: Self.spacing) {
                Image(action.icon)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(action.title)
                    .font(DiiaFont.bigText)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Self.spacing)
            .padding(.vertical, Self.spacing)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action.handler == nil)
        .opacity(action.handler == nil ? 0.4 : 1)
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()

        DiiaActionSheet(
            groups: [
                [
                    DiiaAction(title: "Повна інформація", icon: "DS_docInfo", handler: {}),
                    DiiaAction(title: "Код для перевірки", icon: "DS_qr", handler: {})
                ],
                [
                    DiiaAction(title: "Змінити порядок документів", icon: "DS_reorder", handler: {}),
                    DiiaAction(title: "Оцінити документ", icon: "DS_rating"),
                    DiiaAction(title: "Питання та відповіді", icon: "DS_faq")
                ]
            ],
            onClose: {}
        )
    }
}
