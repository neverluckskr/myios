import SwiftUI

private let carouselSpace = "diia.carousel"

struct DocumentsScreen: View {
    let documents: [DiiaDocument]

    @State private var currentID: UUID?
    @State private var flippedID: UUID?

    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: DiiaLayout.cardInteritemSpacing) {
                    ForEach(documents) { document in
                        card(for: document)
                            .zoomedToCentre()
                            .id(document.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $currentID)
            .safeAreaPadding(.horizontal, 2 * DiiaLayout.cardInteritemSpacing)
            .coordinateSpace(.named(carouselSpace))
            .frame(height: DiiaLayout.cardHeight)

            pageDots
        }
        .onAppear {
            if currentID == nil { currentID = documents.first?.id }
        }
        .onChange(of: currentID) { _, _ in
            flippedID = nil
        }
    }

    private func card(for document: DiiaDocument) -> some View {
        DiiaFlipCard(progress: flippedID == document.id ? 1 : 0) {
            DiiaDocumentCard(document: document, contentVisible: document.id == currentID)
        } back: {
            DiiaDocumentCardBack(document: document)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            flippedID = flippedID == document.id ? nil : document.id
        }
        .animation(.easeInOut(duration: 0.4), value: flippedID)
        .animation(.easeInOut(duration: 0.3), value: currentID)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(documents) { document in
                Circle()
                    .fill(document.id == currentID ? Color.black : Color.black.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentID)
    }
}

private extension View {
    /// Port of ZoomAndSnapFlowLayout: cards scale down to 0.88 as they leave the
    /// centre, pulled back toward the edge so the gap between them stays put.
    func zoomedToCentre() -> some View {
        visualEffect { content, proxy in
            let viewportCentre = UIScreen.main.bounds.width / 2
            let distance = viewportCentre - proxy.frame(in: .named(carouselSpace)).midX
            let normalized = distance / DiiaLayout.carouselActiveDistance

            let zoom = abs(normalized) < 1
                ? 1 - DiiaLayout.carouselZoomFactor * abs(normalized)
                : 1 - DiiaLayout.carouselZoomFactor

            let offset = DiiaLayout.cardWidth * (1 - zoom) / 2 * (normalized > 0 ? 1 : -1)

            return content
                .scaleEffect(zoom)
                .offset(x: offset)
        }
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        DocumentsScreen(documents: DiiaDocument.mocks)
    }
}
