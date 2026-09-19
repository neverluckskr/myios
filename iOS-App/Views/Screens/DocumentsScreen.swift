import SwiftUI

private let carouselSpace = "diia.carousel"

struct DocumentsScreen: View {
    @Environment(DocumentStore.self) private var store

    @State private var currentID: UUID?
    @State private var flippedID: UUID?
    @State private var menuID: UUID?
    @State private var isReordering = false
    @State private var detailsDocument: DiiaDocument?

    private var documents: [DiiaDocument] { store.documents }

    var body: some View {
        ZStack {
            carousel
                .blur(radius: menuID == nil ? 0 : 12)
                .disabled(menuID != nil)

            if menuID != nil {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture { menuID = nil }
                    .transition(.opacity)

                DiiaActionSheet(groups: menuGroups, onClose: { menuID = nil })
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: menuID)
        .onAppear {
            if currentID == nil { currentID = documents.first?.id }
        }
        .onChange(of: currentID) { _, _ in
            flippedID = nil
        }
        .fullScreenCover(isPresented: $isReordering) {
            DocumentsReorderScreen().environment(store)
        }
        .sheet(item: $detailsDocument) { document in
            DocumentDetailsScreen(document: document)
                .presentationDragIndicator(.visible)
        }
    }

    private var carousel: some View {
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
            // A flipping card grows past the scroll bounds; without this it gets
            // sliced off along the top and bottom edges.
            .scrollClipDisabled()

            pageDots
        }
    }

    private func card(for document: DiiaDocument) -> some View {
        DiiaFlipCard(progress: flippedID == document.id ? 1 : 0) {
            DiiaDocumentCard(
                document: document,
                contentVisible: document.id == currentID,
                onMoreTapped: { menuID = document.id }
            )
        } back: {
            DiiaDocumentCardBack(document: document)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            flippedID = flippedID == document.id ? nil : document.id
        }
        // Keep the flipping card above its neighbours as it swings out.
        .zIndex(flippedID == document.id ? 1 : 0)
        .animation(.spring(duration: 0.55, bounce: 0.25), value: flippedID)
        .animation(.easeInOut(duration: 0.3), value: currentID)
    }

    private var menuGroups: [[DiiaAction]] {
        // Captured now: the sheet clears menuID before running a handler.
        let target = menuID

        return [
            [
                DiiaAction(title: "Повна інформація", icon: "DS_docInfo") {
                    detailsDocument = documents.first { $0.id == target }
                },
                DiiaAction(title: "Код для перевірки", icon: "DS_qr") {
                    flippedID = target
                }
            ],
            [
                DiiaAction(title: "Змінити порядок документів", icon: "DS_reorder") {
                    isReordering = true
                },
                DiiaAction(title: "Оцінити документ", icon: "DS_rating"),
                DiiaAction(title: "Питання та відповіді", icon: "DS_faq")
            ]
        ]
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
        DocumentsScreen().environment(DocumentStore())
    }
}
