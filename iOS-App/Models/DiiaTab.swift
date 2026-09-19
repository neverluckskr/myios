import Foundation

enum DiiaTab: Int, CaseIterable {
    case feed
    case documents
    case diiaAI
    case services
    case menu

    var title: String {
        switch self {
        case .feed: "Стрічка"
        case .documents: "Документи"
        case .diiaAI: "Дія.AI"
        case .services: "Сервіси"
        case .menu: "Меню"
        }
    }

    var iconName: String {
        switch self {
        case .feed: "menuFeedInactive"
        case .documents: "menuDocumentsInactive"
        case .diiaAI: "menuServicesInactive"
        case .services: "menuServicesInactive"
        case .menu: "menuSettingsInactive"
        }
    }

    var selectedIconName: String {
        switch self {
        case .feed: "menuFeedActive"
        case .documents: "menuDocumentsActive"
        case .diiaAI: "menuServicesActive"
        case .services: "menuServicesActive"
        case .menu: "menuSettingsActive"
        }
    }
}
