import SwiftUI

/// design_system_code: docQROrg
struct DiiaDocumentCardBack: View {
    let document: DiiaDocument

    private static let qrSidePadding: CGFloat = 40
    /// Diia encodes a signed sharing token, which is what makes its code so dense.
    private static let tokenLength = 400

    private var payload: String {
        if let custom = document.qrPayload, !custom.isEmpty { return custom }
        return "https://diia.app/api/v1/documents/share?token=" + Self.token(for: document.id)
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

    /// Deterministic per document, so the code stays put across launches.
    private static func token(for id: UUID) -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")

        var state: UInt64 = 0xcbf2_9ce4_8422_2325
        withUnsafeBytes(of: id.uuid) { bytes in
            for byte in bytes {
                state = (state ^ UInt64(byte)) &* 0x100_0000_01b3
            }
        }

        return String((0..<tokenLength).map { _ in
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return alphabet[Int((state >> 33) % UInt64(alphabet.count))]
        })
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        DiiaDocumentCardBack(document: DiiaDocument.mocks[0])
    }
}
