import SwiftUI

/// Port of Diia's `UIView.setRadialGradient()`.
///
/// Three elliptical radial layers over white. Each pulses its opacity between
/// 0.6 and 1.0 through three 0.4s phases, offset from one another so the tint
/// keeps travelling across the screen. Full cycle: 1.2s.
struct DiiaGradientBackground: View {
    private enum Phase {
        case delay, increase, decrease

        func opacity(at t: Double) -> Double {
            switch self {
            case .delay: Self.minAlpha
            case .increase: Self.minAlpha + (Self.maxAlpha - Self.minAlpha) * t
            case .decrease: Self.maxAlpha - (Self.maxAlpha - Self.minAlpha) * t
            }
        }

        static let minAlpha = 0.6
        static let maxAlpha = 1.0
    }

    private struct Blob {
        let color: Color
        /// Gradient centre as a fraction of the view's size.
        let center: CGPoint
        /// Radii as a fraction of the view's size, already scaled by finishLocation.
        let radius: CGSize
        let phases: [Phase]
    }

    private static let cycle: Double = 1.2

    /// Layer order matches `insertSublayer(at: 0)`: last inserted sits at the bottom.
    private static let blobs: [Blob] = [
        Blob(
            color: DiiaColors.gradientBlue,
            center: CGPoint(x: 0, y: 0),
            radius: CGSize(width: 1.5, height: 1.5),
            phases: [.increase, .decrease, .delay]
        ),
        Blob(
            color: DiiaColors.gradientPink,
            center: CGPoint(x: 1, y: 0),
            radius: CGSize(width: 1.2, height: 1.8),
            phases: [.decrease, .delay, .increase]
        ),
        Blob(
            color: DiiaColors.gradientOrange,
            center: CGPoint(x: 1, y: 1),
            radius: CGSize(width: 1.3, height: 1.3),
            phases: [.delay, .increase, .decrease]
        )
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let progress = timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: Self.cycle) / Self.cycle

            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))

                for blob in Self.blobs {
                    draw(blob, in: context, size: size, progress: progress)
                }
            }
        }
    }

    private func draw(_ blob: Blob, in context: GraphicsContext, size: CGSize, progress: Double) {
        let slot = min(Int(progress * 3), 2)
        let localT = progress * 3 - Double(slot)

        var layer = context
        layer.opacity = blob.phases[slot].opacity(at: localT)

        let center = CGPoint(x: blob.center.x * size.width, y: blob.center.y * size.height)
        let radiusX = blob.radius.width * size.width
        let radiusY = blob.radius.height * size.height

        // Draw a circle of radiusX, then squash vertically into the target ellipse.
        layer.translateBy(x: 0, y: center.y)
        layer.scaleBy(x: 1, y: radiusY / radiusX)
        layer.translateBy(x: 0, y: -center.y)

        let rect = CGRect(
            x: center.x - radiusX,
            y: center.y - radiusX,
            width: radiusX * 2,
            height: radiusX * 2
        )

        layer.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(
                Gradient(colors: [blob.color.opacity(0.68), blob.color.opacity(0)]),
                center: center,
                startRadius: 0,
                endRadius: radiusX
            )
        )
    }
}

#Preview {
    DiiaGradientBackground().ignoresSafeArea()
}
