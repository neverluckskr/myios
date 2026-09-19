import SwiftUI

/// design_system_code: docQROrg
struct DiiaDocumentCardBack: View {
    let document: DiiaDocument

    private static let qrSidePadding: CGFloat = 40

    private var payload: String {
        let value = document.qrPayload ?? ""
        return value.isEmpty ? "https://diia.gov.ua/\(document.id.uuidString)" : value
    }

    var body: some View {
        qrCode
            .frame(width: DiiaLayout.cardWidth, height: DiiaLayout.cardHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
            .shadow(color: .white, radius: 23 / 2, y: 8)
    }

    @ViewBuilder
    private var qrCode: some View {
        let side = DiiaLayout.cardWidth - 2 * Self.qrSidePadding

        if let image = QRCodeGenerator.image(from: payload) {
            Image(uiImage: image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: side, height: side)
        } else {
            Color.clear.frame(width: side, height: side)
        }
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        DiiaDocumentCardBack(document: DiiaDocument.mocks[0])
    }
}
