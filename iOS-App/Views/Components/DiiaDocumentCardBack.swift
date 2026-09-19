import SwiftUI

/// design_system_code: docQROrg
struct DiiaDocumentCardBack: View {
    let document: DiiaDocument

    @State private var previousBrightness: CGFloat?

    var body: some View {
        DocumentQRCode(document: document)
            .frame(width: DiiaLayout.cardWidth, height: DiiaLayout.cardHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
            .onAppear(perform: boostBrightness)
            .onDisappear(perform: restoreBrightness)
    }

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
