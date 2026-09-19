import SwiftUI

extension View {
    func centerInParent() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
