import SwiftUI

/// Diia labels the code as good for three minutes, then issues a fresh one.
private let codeLifetime: TimeInterval = 180

/// design_system_code: docQROrg
struct DiiaDocumentCardBack: View {
    let document: DiiaDocument

    private static let qrTop: CGFloat = 48
    private static let qrPadding: CGFloat = 40
    private static let stackSpacing: CGFloat = 16

    @State private var startedAt = Date()

    var body: some View {
        VStack(spacing: Self.stackSpacing) {
            expirationLabel
            qrCode
        }
        .padding(.horizontal, Self.qrPadding)
        .frame(width: DiiaLayout.cardWidth, height: DiiaLayout.cardHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
        .onAppear { startedAt = Date() }
    }

    private var expirationLabel: some View {
        TimelineView(.periodic(from: startedAt, by: 1)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startedAt)
            let remaining = codeLifetime - elapsed.truncatingRemainder(dividingBy: codeLifetime)
            let whole = Int(remaining.rounded(.up))

            Text(String(format: "QR-КОД ДІЯТИМЕ %d:%02d", whole / 60, whole % 60))
                .font(DiiaFont.expiration)
                .foregroundStyle(.black.opacity(0.5))
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var qrCode: some View {
        let side = DiiaLayout.cardWidth - 2 * Self.qrPadding

        if let image = CodeGenerator.qr(from: payload) {
            Image(uiImage: image)
                .resizable()
                .interpolation(.none)
                .frame(width: side, height: side)
        } else {
            Color.clear.frame(width: side, height: side)
        }
    }

    private var payload: String {
        let custom = document.qrPayload ?? ""
        guard custom.isEmpty else { return custom }
        return "https://diia.gov.ua/?r=" + Self.filler(for: document.id)
    }

    /// Deterministic per document, so the code stays put across launches.
    private static func filler(for id: UUID) -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")

        var state: UInt64 = 0xcbf2_9ce4_8422_2325
        withUnsafeBytes(of: id.uuid) { bytes in
            for byte in bytes {
                state = (state ^ UInt64(byte)) &* 0x100_0000_01b3
            }
        }

        return String((0..<400).map { _ in
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
