import SwiftUI

enum VerificationType: String, CaseIterable {
    case qr, barcode

    var title: String {
        switch self {
        case .qr: "QR-код"
        case .barcode: "Штрихкод"
        }
    }

    func iconName(active: Bool) -> String {
        switch self {
        case .qr: active ? "qrCodeActive" : "qrCodeInactive"
        case .barcode: active ? "barcodeActive" : "barcodeInactive"
        }
    }
}

/// design_system_code: btnToggleMlc
struct DiiaVerificationOption: View {
    let type: VerificationType
    let isActive: Bool
    let action: () -> Void

    private static let iconSize: CGFloat = 52
    private static let iconBottomInset: CGFloat = 12

    var body: some View {
        Button(action: action) {
            VStack(spacing: Self.iconBottomInset) {
                Image(type.iconName(active: isActive))
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.iconSize, height: Self.iconSize)

                Text(type.title)
                    .font(DiiaFont.bigText)
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(type.title)
    }
}

#Preview {
    HStack(spacing: 8) {
        DiiaVerificationOption(type: .qr, isActive: true) {}
        DiiaVerificationOption(type: .barcode, isActive: false) {}
    }
    .padding(40)
    .background(Color.white)
}
