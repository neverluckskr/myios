import SwiftUI
import UIKit
import CoreText

enum DiiaFont {
    /// UIAppFonts alone proved unreliable with the generated Info.plist, so the
    /// bundled faces are also registered at launch. Re-registering is a no-op.
    static func registerBundledFonts() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil) ?? []
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    enum Weight {
        case light, regular, medium, bold

        var mainName: String {
            switch self {
            case .light: "e-Ukraine-Light"
            case .regular: "e-Ukraine-Regular"
            case .medium: "e-Ukraine-Medium"
            case .bold: "e-Ukraine-Bold"
            }
        }

        var headingName: String {
            switch self {
            case .light: "e-UkraineHead-Light"
            default: "e-UkraineHead-Regular"
            }
        }
    }

    private enum ScreenSize {
        case big, medium, small
    }

    private static var screenSize: ScreenSize {
        switch UIScreen.main.bounds.width {
        case 414...: .big
        case 321..<414: .medium
        default: .small
        }
    }

    private static func scaled(big: CGFloat, medium: CGFloat, small: CGFloat) -> CGFloat {
        switch screenSize {
        case .big: big
        case .medium: medium
        case .small: small
        }
    }

    static func uiMain(_ weight: Weight = .regular, size: CGFloat) -> UIFont {
        UIFont(name: weight.mainName, size: size) ?? .systemFont(ofSize: size)
    }

    static func main(_ weight: Weight = .regular, size: CGFloat) -> Font {
        Font(uiMain(weight, size: size))
    }

    static func heading(_ weight: Weight = .regular, size: CGFloat) -> Font {
        .custom(weight.headingName, size: size)
    }

    /// tableItemVerticalMlc label/value, tickerAtm
    static var usualUIFont: UIFont { uiMain(size: scaled(big: 13, medium: 12, small: 10)) }
    static var usual: Font { Font(usualUIFont) }

    /// subtitleLabelMlc
    static var smallHeading: Font { main(size: scaled(big: 18, medium: 16, small: 14)) }

    /// docHeadingOrg title
    static var docHeading: Font {
        main(size: UIScreen.main.bounds.width < 414 ? 17 : 24)
    }

    /// tabBar item title
    static var tabBarTitle: Font { main(size: scaled(big: 11, medium: 10, small: 10)) }

    static var largeTitle: Font { main(size: scaled(big: 23, medium: 20, small: 17)) }

    static var title: Font { main(size: scaled(big: 22, medium: 19, small: 16)) }
}
