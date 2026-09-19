import SwiftUI

/// design_system_code: docQROrg
struct DiiaDocumentCardBack: View {
    let document: DiiaDocument

    /// The code is reissued on this interval.
    private static let lifetime: TimeInterval = 30
    private static let sidePadding: CGFloat = 40

    @State private var startedAt = Date()
    @State private var previousBrightness: CGFloat?

    var body: some View {
        TimelineView(.periodic(from: startedAt, by: Self.lifetime)) { timeline in
            let generation = Int(timeline.date.timeIntervalSince(startedAt) / Self.lifetime)
            qrCode(generation: generation)
        }
        .frame(width: DiiaLayout.cardWidth, height: DiiaLayout.cardHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
        .onAppear {
            startedAt = Date()
            boostBrightness()
        }
        .onDisappear(perform: restoreBrightness)
    }

    @ViewBuilder
    private func qrCode(generation: Int) -> some View {
        let side = DiiaLayout.cardWidth - 2 * Self.sidePadding

        if let image = CodeGenerator.qr(from: payload(generation: generation)) {
            Image(uiImage: image)
                .resizable()
                .interpolation(.none)
                .frame(width: side, height: side)
        } else {
            Color.clear.frame(width: side, height: side)
        }
    }

    /// A hand-written payload is left alone; the generated one is reissued so
    /// the code visibly changes when it expires.
    private func payload(generation: Int) -> String {
        let custom = document.qrPayload ?? ""
        guard custom.isEmpty else { return custom }
        return "https://diia.gov.ua/?r=" + Self.filler(for: document.id, generation: generation)
    }

    private static func filler(for id: UUID, generation: Int) -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")

        var state: UInt64 = 0xcbf2_9ce4_8422_2325
        withUnsafeBytes(of: id.uuid) { bytes in
            for byte in bytes {
                state = (state ^ UInt64(byte)) &* 0x100_0000_01b3
            }
        }
        state = (state ^ UInt64(bitPattern: Int64(generation))) &* 0x100_0000_01b3

        return String((0..<400).map { _ in
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return alphabet[Int((state >> 33) % UInt64(alphabet.count))]
        })
    }

    // MARK: - Brightness

    private func boostBrightness() {
        if previousBrightness == nil { previousBrightness = UIScreen.main.brightness }
        UIScreen.main.brightness = 1
    }

    private func restoreBrightness() {
        guard let previousBrightness else { return }
        UIScreen.main.brightness = previousBrightness
        self.previousBrightness = nil
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        DiiaDocumentCardBack(document: DiiaDocument.mocks[0])
    }
}
