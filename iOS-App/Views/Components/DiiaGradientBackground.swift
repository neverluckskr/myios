import SwiftUI

struct DiiaGradientBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let cycle = t.truncatingRemainder(dividingBy: 3.6)
            let normalizedPhase = cycle / 3.6

            Canvas { context, size in
                let w = size.width
                let h = size.height

                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))

                drawBlob(
                    in: &context,
                    center: CGPoint(x: w, y: h),
                    endPoint: CGPoint(x: 0, y: 0),
                    color: DiiaColors.gradientOrange,
                    radius: max(w, h) * 1.3,
                    opacity: blobOpacity(normalizedPhase, phaseOffset: 0)
                )

                drawBlob(
                    in: &context,
                    center: CGPoint(x: w, y: 0),
                    endPoint: CGPoint(x: 0, y: h),
                    color: DiiaColors.gradientPink,
                    radius: max(w, h) * 1.2,
                    opacity: blobOpacity(normalizedPhase, phaseOffset: 1.0 / 3.0)
                )

                drawBlob(
                    in: &context,
                    center: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: w, y: h),
                    color: DiiaColors.gradientBlue,
                    radius: max(w, h) * 1.0,
                    opacity: blobOpacity(normalizedPhase, phaseOffset: 2.0 / 3.0)
                )
            }
        }
    }

    private func blobOpacity(_ phase: CGFloat, phaseOffset: CGFloat) -> Double {
        let shifted = (phase + phaseOffset).truncatingRemainder(dividingBy: 1.0)
        if shifted < 1.0 / 3.0 {
            return 0.6
        } else if shifted < 2.0 / 3.0 {
            let t = (shifted - 1.0 / 3.0) / (1.0 / 3.0)
            return 0.6 + 0.4 * t
        } else {
            let t = (shifted - 2.0 / 3.0) / (1.0 / 3.0)
            return 1.0 - 0.4 * t
        }
    }

    private func drawBlob(
        in context: inout GraphicsContext,
        center: CGPoint,
        endPoint: CGPoint,
        color: Color,
        radius: CGFloat,
        opacity: Double
    ) {
        let gradient = Gradient(colors: [
            color.opacity(0.68),
            color.opacity(0)
        ])

        context.opacity = opacity
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .radialGradient(
                gradient,
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
        context.opacity = 1
    }
}

#Preview {
    DiiaGradientBackground()
}
