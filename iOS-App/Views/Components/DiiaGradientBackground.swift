import SwiftUI

struct DiiaGradientBackground: View {
    @State private var animatePhase: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))

            drawRadialBlob(
                in: &context, size: size,
                center: CGPoint(x: w * 0.85, y: h * 0.15),
                color: DiiaColors.gradientOrange,
                radius: max(w, h) * 0.7,
                phase: animatePhase
            )

            drawRadialBlob(
                in: &context, size: size,
                center: CGPoint(x: w * 0.9, y: h * 0.85),
                color: DiiaColors.gradientPink,
                radius: max(w, h) * 0.65,
                phase: animatePhase + .pi * 2 / 3
            )

            drawRadialBlob(
                in: &context, size: size,
                center: CGPoint(x: w * 0.1, y: h * 0.5),
                color: DiiaColors.gradientBlue,
                radius: max(w, h) * 0.6,
                phase: animatePhase + .pi * 4 / 3
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 3.6).repeatForever(autoreverses: false)) {
                animatePhase = .pi * 2
            }
        }
    }

    private func drawRadialBlob(
        in context: inout GraphicsContext,
        size: CGSize,
        center: CGPoint,
        color: Color,
        radius: CGFloat,
        phase: CGFloat
    ) {
        let opacity = 0.6 + 0.4 * ((sin(phase) + 1) / 2)
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        let gradient = Gradient(colors: [
            color.opacity(0.68),
            color.opacity(0)
        ])

        context.opacity = opacity
        context.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
        )
        context.opacity = 1
    }
}

#Preview {
    DiiaGradientBackground()
}
