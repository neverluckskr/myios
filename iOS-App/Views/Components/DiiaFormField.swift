import SwiftUI

enum FormPalette {
    static let surface = Color.white
    static let canvas = Color(white: 0.94)
    static let inputIdle = Color.black.opacity(0.05)
    static let inputActive = Color.white
    static let caption = Color.black.opacity(0.45)
    static let ring = Color.black
}

/// The caption sits outside the control, so the input itself stays a clean
/// rounded shape and a filled field still says what it is.
struct DiiaFormField: View {
    let title: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var hint: String?
    var keyboard: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    private var radius: CGFloat { axis == .horizontal ? 26 : 20 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .kerning(0.8)
                .foregroundStyle(isFocused ? FormPalette.ring : FormPalette.caption)
                .padding(.leading, 4)

            TextField("", text: $text, axis: axis)
                .font(.system(size: 17))
                .foregroundStyle(.black)
                .tint(.black)
                .keyboardType(keyboard)
                .focused($isFocused)
                .lineLimit(axis == .vertical ? 1...6 : 1...1)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(minHeight: 54, alignment: .leading)
                .background(isFocused ? FormPalette.inputActive : FormPalette.inputIdle)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(
                            isFocused ? FormPalette.ring : .clear,
                            lineWidth: 1.5
                        )
                }

            if let hint, !hint.isEmpty {
                Text(hint)
                    .font(.system(size: 12))
                    .foregroundStyle(FormPalette.caption)
                    .padding(.leading, 4)
            }
        }
        .animation(.easeOut(duration: 0.16), value: isFocused)
    }
}

/// A titled group of fields on a white panel.
struct DiiaFormSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.black)
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.black)
            }

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FormPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

/// Full-width pill used for the form's own actions.
struct DiiaFormButton: View {
    let title: String
    var icon: String?
    var filled = false
    var destructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 17, weight: filled ? .semibold : .regular))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(filled ? Color.black : FormPalette.inputIdle)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        if filled { return .white }
        return destructive ? .red : .black
    }
}

#Preview {
    ZStack {
        FormPalette.canvas.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 16) {
                DiiaFormSection(title: "Документ", icon: "doc.text") {
                    DiiaFormField(title: "Назва", text: .constant("єДокумент"))
                    DiiaFormField(
                        title: "Дані QR-коду",
                        text: .constant(""),
                        axis: .vertical,
                        hint: "Порожнє поле — код веде на diia.gov.ua"
                    )
                    DiiaFormButton(title: "Додати поле", icon: "plus") {}
                }
            }
            .padding(16)
        }
    }
}
