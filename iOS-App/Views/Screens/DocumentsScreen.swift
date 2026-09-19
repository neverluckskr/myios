import SwiftUI

struct DocumentsScreen: View {
    let documents: [DiiaDocument]

    @State private var currentID: UUID?

    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: DiiaLayout.cardInteritemSpacing) {
                    ForEach(documents) { document in
                        DiiaDocumentCard(document: document)
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
