import SwiftUI

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
                            .id(document.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $currentID)
            .safeAreaPadding(.horizontal, 2 * DiiaLayout.cardInteritemSpacing)
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
            DiiaDocumentCard(document: document)
        } back: {
            DiiaDocumentCardBack(document: document)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            flippedID = flippedID == document.id ? nil : document.id
        }
        .animation(.easeInOut(duration: 0.4), value: flippedID)
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

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        DocumentsScreen(documents: DiiaDocument.mocks)
    }
}
