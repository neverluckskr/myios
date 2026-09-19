import SwiftUI

enum DiiaColors {
    // Source: diia-open-source/ios-diia UIView+GradientAnimation.swift
    // RGB(116, 164, 247) alpha 0.68
    static let gradientBlue = Color(red: 116.0 / 255.0, green: 164.0 / 255.0, blue: 247.0 / 255.0)
    // RGB(223, 144, 222) alpha 0.68
    static let gradientPink = Color(red: 223.0 / 255.0, green: 144.0 / 255.0, blue: 222.0 / 255.0)
    // RGB(243, 190, 129) alpha 0.68
    static let gradientOrange = Color(red: 243.0 / 255.0, green: 190.0 / 255.0, blue: 129.0 / 255.0)

    // Source: DocumentDetailsCommonViewController.Constants.backgroundColor
    static let detailsBackground = Color(red: 0xF1 / 255, green: 0xF6 / 255, blue: 0xF6 / 255)

    // Source: AppConstants.swift → black540
    static let secondaryText = Color.black.opacity(0.54)

    // Source: AppConstants.swift → Colors.black = "#000000"
    static let tabBarBackground = Color.black

    // Source: Storyboard → label textColor white="1" alpha="1"
    static let tabBarItemActive = Color.white
    static let tabBarItemInactive = Color.white.opacity(0.4)
}
