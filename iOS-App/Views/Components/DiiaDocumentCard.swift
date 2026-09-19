import SwiftUI

/// design_system_code: docWithPhoto
struct DiiaDocumentCard: View {
    let document: DiiaDocument
    /// Diia blanks out everything but the frosted panel while a card is off-centre.
    var contentVisible: Bool = true
    var onMoreTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(document.title)
                .font(DiiaFont.docHeading)
                .foregroundStyle(.black)
                .padding(.horizontal, DiiaLayout.sideSpacing)
                .padding(.top, DiiaLayout.verticalPadding + 8)

            twoColumns
                .padding(.horizontal, DiiaLayout.sideSpacing)
                .padding(.top, DiiaLayout.verticalPadding)

            Spacer(minLength: DiiaLayout.verticalTickerPadding)

            DiiaTicker(text: document.tickerText)
                .padding(.bottom, DiiaLayout.verticalTickerPadding)

            bottomHeading
                .padding(.horizontal, DiiaLayout.sideSpacing)
                .padding(.bottom, DiiaLayout.bottomHeadingPadding)
        }
        .opacity(contentVisible ? 1 : 0)
        .frame(width: DiiaLayout.cardWidth, height: DiiaLayout.cardHeight, alignment: .top)
        .background(Color.white.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous))
    }

    private var twoColumns: some View {
        HStack(alignment: .top, spacing: DiiaLayout.columnSpacing) {
            DiiaDocPhoto(data: document.photoData)

            VStack(alignment: .leading, spacing: DiiaLayout.tableVerticalSpacing) {
                ForEach(document.fields) { field in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(field.label)
                            .font(DiiaFont.usual)
                            .foregroundStyle(.black)
                        Text(field.value)
                            .font(DiiaFont.usual)
                            .foregroundStyle(.black)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: DiiaLayout.columnWidth, alignment: .leading)
        }
    }

    private var bottomHeading: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Diia renders each name part on its own line.
            Text(document.fullName.replacingOccurrences(of: " ", with: "\n"))
                .font(DiiaFont.docHeading)
                .foregroundStyle(.black)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                onMoreTapped?()
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: DiiaLayout.moreButtonIconSize * 0.45, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: DiiaLayout.moreButtonIconSize, height: DiiaLayout.moreButtonIconSize)
                    .background(Circle().fill(.black))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        DiiaGradientBackground().ignoresSafeArea()
        DiiaDocumentCard(document: DiiaDocument.mocks[0])
    }
}
