import SwiftUI

/// design_system_code: docQROrg
struct DiiaDocumentCardBack: View {
    let document: DiiaDocument

    private static let qrSidePadding: CGFloat = 40
    private static let defaultPayload = "https://diia.gov.ua/"

    private var payload: String {
        let custom = document.qrPayload ?? ""
        return custom.isEmpty ? Self.defaultPayload : custom
    }

    var body: some View {
        qrCode
            .frame(width: DiiaLayout.cardWidth, height: DiiaLayout.cardHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
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
