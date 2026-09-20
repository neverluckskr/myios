import SwiftUI

struct DiiaDocPhoto: View {
    let data: Data?
    /// Defaults to the card's column; the details sheet passes its own.
    var width: CGFloat = DiiaLayout.columnWidth

    var body: some View {
        RoundedRectangle(cornerRadius: DiiaLayout.photoCornerRadius, style: .continuous)
            .fill(Color.white.opacity(0.6))
            .overlay {
                if let data, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(width * 0.22)
                        .foregroundStyle(Color.black.opacity(0.18))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DiiaLayout.photoCornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DiiaLayout.photoCornerRadius, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
            }
            .frame(width: width, height: width * DiiaLayout.docPhotoProportion)
    }
}

#Preview {
    DiiaDocPhoto(data: nil)
        .padding()
        .background(Color.gray)
}
