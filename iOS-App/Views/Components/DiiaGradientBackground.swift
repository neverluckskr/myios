import SwiftUI

/// Three coloured blobs drifting over white.
///
/// Built on Diia's palette and corner placement, but the timing is deliberately
/// far slower than the original's 1.2s pulse: opacity breathes on a sine rather
/// than the stock linear phases, and each blob wanders on its own period so the
/// motion never visibly loops.
struct DiiaGradientBackground: View {
    private struct Blob {
        let color: Color
        /// Resting centre as a fraction of the view's size.
        let center: CGPoint
        /// Radii as a fraction of the view's size.
        let radius: CGSize
        /// Offset into the breathing cycle, in turns.
        let phase: Double
        /// How far the centre wanders, as a fraction of the view's size.
        let drift: CGSize
        /// Seconds per full wander, horizontal and vertical.
        let driftPeriod: CGSize
    }

    private static let breathCycle: Double = 14
    private static let minAlpha: Double = 0.55
    private static let maxAlpha: Double = 1.0
    private static let tint: Double = 0.95

    private static let blobs: [Blob] = [
        Blob(
            color: DiiaColors.gradientBlue,
            center: CGPoint(x: 0, y: 0),
            radius: CGSize(width: 1.0, height: 1.0),
            phase: 0,
            drift: CGSize(width: 0.18, height: 0.12),
            driftPeriod: CGSize(width: 23, height: 31)
        ),
        Blob(
            color: DiiaColors.gradientPink,
            center: CGPoint(x: 1, y: 0),
            radius: CGSize(width: 0.85, height: 1.15),
            phase: 1.0 / 3.0,
            drift: CGSize(width: 0.15, height: 0.16),
            driftPeriod: CGSize(width: 29, height: 19)
        ),
        Blob(
            color: DiiaColors.gradientOrange,
            center: CGPoint(x: 1, y: 1),
            radius: CGSize(width: 0.9, height: 0.9),
            phase: 2.0 / 3.0,
            drift: CGSize(width: 0.2, height: 0.14),
            driftPeriod: CGSize(width: 17, height: 27)
        )
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))

                for blob in Self.blobs {
                    draw(blob, in: context, size: size, time: time)
                }
            }
        }
    }

    private func draw(_ blob: Blob, in context: GraphicsContext, size: CGSize, time: Double) {
        var layer = context
        layer.opacity = opacity(for: blob, at: time)

        let center = CGPoint(
            x: (blob.center.x + blob.drift.width * wave(time, period: blob.driftPeriod.width)) * size.width,
            y: (blob.center.y + blob.drift.height * wave(time, period: blob.driftPeriod.height)) * size.height
        )

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
                Gradient(colors: [
                    blob.color.opacity(Self.tint),
                    blob.color.opacity(0)
                ]),
                center: center,
                startRadius: 0,
                endRadius: radiusX
            )
        )
    }

    private func opacity(for blob: Blob, at time: Double) -> Double {
        let turns = time / Self.breathCycle + blob.phase
        let eased = 0.5 + 0.5 * sin(turns * 2 * .pi)
        return Self.minAlpha + (Self.maxAlpha - Self.minAlpha) * eased
    }

    /// Smooth −1…1 oscillation.
    private func wave(_ time: Double, period: Double) -> Double {
        sin(time / period * 2 * .pi)
    }
}

#Preview {
    DiiaGradientBackground().ignoresSafeArea()
}
