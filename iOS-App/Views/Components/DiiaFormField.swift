import SwiftUI

/// A filled input that keeps its caption visible at all times, so a filled
/// field still says what it is.
struct DiiaFormField: View {
    let title: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var hint: String?
    var keyboard: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(DiiaFont.smallTitle)
                    .kerning(0.6)
                    .foregroundStyle(isFocused ? .black : DiiaColors.secondaryText)

                TextField("", text: $text, axis: axis)
                    .font(DiiaFont.bigText)
                    .foregroundStyle(.black)
                    .tint(.black)
                    .keyboardType(keyboard)
                    .focused($isFocused)
                    .lineLimit(axis == .vertical ? 1...6 : 1...1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(isFocused ? 1 : 0.75))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isFocused ? Color.black.opacity(0.55) : Color.black.opacity(0.08),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }

            if let hint, !hint.isEmpty {
                Text(hint)
                    .font(DiiaFont.smallTitle)
                    .foregroundStyle(DiiaColors.secondaryText)
                    .padding(.horizontal, 4)
            }
        }
        .animation(.easeOut(duration: 0.16), value: isFocused)
    }
}

/// A titled group of fields on a translucent panel.
struct DiiaFormSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(DiiaFont.smallHeading)
                .foregroundStyle(.black)
                .padding(.horizontal, 4)

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()

        ScrollView {
            DiiaFormSection(title: "Документ", icon: "doc.text") {
                DiiaFormField(title: "Назва", text: .constant("єДокумент"))
                DiiaFormField(
                    title: "Дані QR-коду",
                    text: .constant(""),
                    axis: .vertical,
                    hint: "Порожнє поле — код веде на diia.gov.ua"
                )
            }
            .padding(16)
        }
    }
}
