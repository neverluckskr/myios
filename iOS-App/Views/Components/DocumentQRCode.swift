import SwiftUI

/// The code is reissued on this interval.
private let codeLifetime: TimeInterval = 30

struct DocumentQRCode: View {
    let document: DiiaDocument
    var side: CGFloat?

    @State private var startedAt = Date()

    var body: some View {
        TimelineView(.periodic(from: startedAt, by: codeLifetime)) { timeline in
            let generation = Int(timeline.date.timeIntervalSince(startedAt) / codeLifetime)
            image(generation: generation)
        }
        .onAppear { startedAt = Date() }
    }

    @ViewBuilder
    private func image(generation: Int) -> some View {
        let box = side ?? DiiaLayout.cardWidth - 80

        if let code = CodeGenerator.qr(from: payload(generation: generation)) {
            Image(uiImage: code)
                .resizable()
                .interpolation(.none)
                .frame(width: box, height: box)
        } else {
            Color.clear.frame(width: box, height: box)
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
}

#Preview {
    DocumentQRCode(document: DiiaDocument.mocks[0])
        .padding()
        .background(Color.white)
}
