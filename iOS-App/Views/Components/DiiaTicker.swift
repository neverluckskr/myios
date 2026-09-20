import SwiftUI

/// design_system_code: tickerAtm
///
/// Driven off a clock rather than a repeating animation: a card flip tears the
/// front face down and rebuilds it, and an in-flight `repeatForever` does not
/// survive that intact.
struct DiiaTicker: View {
    let text: String

    private static let leadingPadding: CGFloat = 16
    /// Roughly two and a half characters a second.
    private static let charactersPerSecond: Double = 2.5

    @State private var startedAt = Date()

    private var segment: String { text + "    " }

    private var segmentWidth: CGFloat {
        max((segment as NSString).size(withAttributes: [.font: DiiaFont.usualUIFont]).width, 1)
    }

    private var secondsPerSegment: Double {
        max(Double(segment.count) / Self.charactersPerSecond, 1)
    }

    var body: some View {
        GeometryReader { geo in
            let copies = max(Int(ceil(geo.size.width / segmentWidth)) + 1, 1)
            let loopWidth = segmentWidth * CGFloat(copies)
            let loopDuration = secondsPerSegment * Double(copies)

            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSince(startedAt)
                let phase = elapsed.truncatingRemainder(dividingBy: loopDuration) / loopDuration

                HStack(spacing: 0) {
                    ForEach(0..<(copies * 2), id: \.self) { _ in
                        Text(segment)
                            .font(DiiaFont.usual)
                            .foregroundStyle(.black)
                            .fixedSize()
                    }
                }
                .offset(x: Self.leadingPadding - loopWidth * phase)
                .frame(height: geo.size.height, alignment: .center)
            }
        }
        .frame(height: DiiaLayout.tickerHeight)
        .background(
            Image("tickerGreen")
                .resizable()
                .scaledToFill()
        )
        .clipped()
        .onAppear { startedAt = Date() }
    }
}

#Preview {
    DiiaTicker(text: "Ця копія дійсна для пред'явлення")
        .padding(.vertical, 40)
        .background(Color.gray)
}
