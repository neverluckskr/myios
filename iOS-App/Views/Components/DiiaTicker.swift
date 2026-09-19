import SwiftUI

/// design_system_code: tickerAtm
struct DiiaTicker: View {
    let text: String

    private static let leadingPadding: CGFloat = 16
    private static let pointsPerSecond: Double = 30

    @State private var offset: CGFloat = 0

    private var segment: String { text + "   •   " }

    private var segmentWidth: CGFloat {
        max((segment as NSString).size(withAttributes: [.font: DiiaFont.usualUIFont]).width, 1)
    }

    var body: some View {
        GeometryReader { geo in
            let copies = max(Int(ceil(geo.size.width / segmentWidth)) + 1, 1)
            let loopWidth = segmentWidth * CGFloat(copies)

            HStack(spacing: 0) {
                ForEach(0..<(copies * 2), id: \.self) { _ in
                    Text(segment)
                        .font(DiiaFont.usual)
                        .foregroundStyle(.black)
                        .fixedSize()
                }
            }
            .offset(x: Self.leadingPadding + offset)
            .frame(height: geo.size.height, alignment: .center)
            .onAppear { startScrolling(loopWidth) }
            .onChange(of: loopWidth) { _, width in startScrolling(width) }
        }
        .frame(height: DiiaLayout.tickerHeight)
        .background(
            Image("tickerGreen")
                .resizable()
                .scaledToFill()
        )
        .clipped()
    }

    private func startScrolling(_ width: CGFloat) {
        offset = 0
        withAnimation(
            .linear(duration: Double(width) / Self.pointsPerSecond)
            .repeatForever(autoreverses: false)
        ) {
            offset = -width
        }
    }
}

#Preview {
    DiiaTicker(text: "Ця копія дійсна для пред'явлення")
        .padding(.vertical, 40)
        .background(Color.gray)
}
