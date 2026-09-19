import UIKit

/// Metrics taken from Diia's DocumentsLayoutProvider.
enum DiiaLayout {
    static var cardInteritemSpacing: CGFloat {
        switch UIScreen.main.bounds.width {
        case 414, 428, 430: 18
        default: 16
        }
    }

    static let cardHeightToWidthProportion: CGFloat = 1.528
    static let cardCornerRadius: CGFloat = 24
    static let columnProportion: CGFloat = 0.4308
    static let docPhotoProportion: CGFloat = 4 / 3
    static let sideSpacing: CGFloat = 16

    static var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 4 * cardInteritemSpacing
    }

    static var cardHeight: CGFloat {
        cardWidth * cardHeightToWidthProportion
    }

    /// DSDocumentWithPhotoView.Constants
    static let verticalPadding: CGFloat = 20
    static let verticalTickerPadding: CGFloat = 8
    static let bottomHeadingPadding: CGFloat = 28

    static var tableVerticalSpacing: CGFloat {
        UIScreen.main.bounds.width == 320 ? 6 : 16
    }

    /// Gap between the photo column and the fields column
    static let columnSpacing: CGFloat = 20
    static let photoCornerRadius: CGFloat = 16
    static let tickerHeight: CGFloat = 24

    /// Visible circle of the "more" button; its tap target stays 44pt.
    static var moreButtonIconSize: CGFloat {
        switch UIScreen.main.bounds.width {
        case 414...: 31
        case ...320: 24
        default: 28
        }
    }

    /// Photo and fields columns are distributed equally across the card width.
    static var columnWidth: CGFloat {
        (cardWidth - 2 * sideSpacing - columnSpacing) / 2
    }

    static var photoHeight: CGFloat {
        columnWidth * docPhotoProportion
    }
}
