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
        case .feed: "newspaper"
        case .documents: "doc.text"
        case .diiaAI: "sparkles"
        case .services: "square.grid.2x2"
        case .menu: "line.3.horizontal"
        }
    }

    var selectedIconName: String {
        switch self {
        case .feed: "newspaper.fill"
        case .documents: "doc.text.fill"
        case .diiaAI: "sparkles"
        case .services: "square.grid.2x2.fill"
        case .menu: "line.3.horizontal"
        }
    }
}
