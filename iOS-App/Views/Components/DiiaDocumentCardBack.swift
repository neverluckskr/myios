import SwiftUI

/// Diia labels the code as good for three minutes, then issues a fresh one.
private let codeLifetime: TimeInterval = 180

/// design_system_code: docQROrg + verificationCodesOrg
struct DiiaDocumentCardBack: View {
    let document: DiiaDocument

    private enum Metrics {
        static let qrTop: CGFloat = 48
        static let barcodeTop: CGFloat = 100
        static let qrPadding: CGFloat = 40
        static let barcodePadding: CGFloat = 32
        static let stackSpacing: CGFloat = 16
        static let barcodeNumberSpacing: CGFloat = 12
        static let barcodeProportion: CGFloat = 0.4
        static let optionsSpacing: CGFloat = 8
    }

    @State private var selection: VerificationType = .qr
    @State private var startedAt = Date()
    @State private var originalBrightness: CGFloat?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: selection == .qr ? Metrics.qrTop : Metrics.barcodeTop)

            codeBlock
                .padding(.horizontal, selection == .qr ? Metrics.qrPadding : Metrics.barcodePadding)

            Spacer(minLength: Metrics.stackSpacing)

            options
                .padding(.horizontal, Metrics.qrPadding)
                .padding(.bottom, Metrics.qrPadding)
        }
        .frame(width: DiiaLayout.cardWidth, height: DiiaLayout.cardHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
        .onAppear { startedAt = Date() }
        .onDisappear(perform: restoreBrightness)
        .onChange(of: selection) { _, type in
            // Diia brightens the screen so scanners can read the barcode.
            if type == .barcode {
                boostBrightness()
            } else {
                restoreBrightness()
            }
        }
    }

    private var codeBlock: some View {
        VStack(spacing: Metrics.stackSpacing) {
            expirationLabel

            switch selection {
            case .qr:
                let side = DiiaLayout.cardWidth - 2 * Metrics.qrPadding
                code(CodeGenerator.qr(from: qrPayload), width: side, height: side)

            case .barcode:
                let width = DiiaLayout.cardWidth - 2 * Metrics.barcodePadding

                VStack(spacing: Metrics.barcodeNumberSpacing) {
                    code(
                        CodeGenerator.barcode(from: barcodeValue),
                        width: width,
                        height: width * Metrics.barcodeProportion
                    )

                    Text(Self.grouped(barcodeValue))
                        .font(DiiaFont.bigText)
                        .kerning(4)
                        .foregroundStyle(.black)
                }
            }
        }
    }

    private var expirationLabel: some View {
        TimelineView(.periodic(from: startedAt, by: 1)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startedAt)
            let remaining = codeLifetime - elapsed.truncatingRemainder(dividingBy: codeLifetime)

            Text(Self.caption(for: selection, remaining: remaining))
                .font(DiiaFont.expiration)
                .foregroundStyle(.black.opacity(0.5))
                .frame(maxWidth: .infinity)
        }
    }

    private var options: some View {
        HStack(spacing: Metrics.optionsSpacing) {
            ForEach(VerificationType.allCases, id: \.rawValue) { type in
                DiiaVerificationOption(type: type, isActive: selection == type) {
                    selection = type
                }
            }
        }
    }

    @ViewBuilder
    private func code(_ image: UIImage?, width: CGFloat, height: CGFloat) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .interpolation(.none)
                .frame(width: width, height: height)
        } else {
            Color.clear.frame(width: width, height: height)
        }
    }

    // MARK: - Content

    private var qrPayload: String {
        let custom = document.qrPayload ?? ""
        guard custom.isEmpty else { return custom }
        return "https://diia.gov.ua/?r=" + Self.filler(for: document.id, length: 400, digitsOnly: false)
    }

    private var barcodeValue: String {
        let custom = document.barcodeValue ?? ""
        guard custom.isEmpty else { return custom }
        return Self.filler(for: document.id, length: 13, digitsOnly: true)
    }

    private static func caption(for type: VerificationType, remaining: TimeInterval) -> String {
        let name = type == .qr ? "QR-КОД" : "ШТРИХКОД"
        let whole = Int(remaining.rounded(.up))
        return String(format: "%@ ДІЯТИМЕ %d:%02d", name, whole / 60, whole % 60)
    }

    /// Mirrors Diia's `separateBarcode`: two groups of four, then the remainder.
    private static func grouped(_ code: String) -> String {
        guard code.count > 8 else { return code }
        let characters = Array(code)
        return String(characters[0..<4]) + "  "
            + String(characters[4..<8]) + "  "
            + String(characters[8...])
    }

    /// Deterministic per document, so the codes stay put across launches.
    private static func filler(for id: UUID, length: Int, digitsOnly: Bool) -> String {
        let alphabet = Array(
            digitsOnly
                ? "0123456789"
                : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        )

        var state: UInt64 = 0xcbf2_9ce4_8422_2325
        withUnsafeBytes(of: id.uuid) { bytes in
            for byte in bytes {
                state = (state ^ UInt64(byte)) &* 0x100_0000_01b3
            }
        }

        return String((0..<length).map { _ in
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return alphabet[Int((state >> 33) % UInt64(alphabet.count))]
        })
    }

    // MARK: - Brightness

    private func boostBrightness() {
        if originalBrightness == nil { originalBrightness = UIScreen.main.brightness }
        UIScreen.main.brightness = 1
    }

    private func restoreBrightness() {
        guard let originalBrightness else { return }
        UIScreen.main.brightness = originalBrightness
        self.originalBrightness = nil
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        DiiaDocumentCardBack(document: DiiaDocument.mocks[0])
    }
}
