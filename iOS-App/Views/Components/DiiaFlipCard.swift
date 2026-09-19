import SwiftUI

/// Mirrors UIKit's `.transitionFlipFromLeft` used by Diia's DocumentCollectionCell:
/// the content swaps exactly when the card is edge-on at 90°.
struct DiiaFlipCard<Front: View, Back: View>: View, Animatable {
    var progress: Double
    @ViewBuilder var front: () -> Front
    @ViewBuilder var back: () -> Back

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Group {
            if progress < 0.5 {
                front()
            } else {
                back()
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .rotation3DEffect(
            .degrees(progress * 180),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.4
        )
    }
}
