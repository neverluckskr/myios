import SwiftUI

@main
struct iOS_AppApp: App {
    init() {
        DiiaFont.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
