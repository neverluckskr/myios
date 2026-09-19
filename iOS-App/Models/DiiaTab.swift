import Foundation

enum DiiaTab: Int, CaseIterable {
    case feed
    case documents
    case diiaAI
    case services
    case menu

    enum Icon {
        case asset(String)
        case symbol(String)
    }

    var title: String {
        switch self {
        case .feed: "Стрічка"
        case .documents: "Документи"
        case .diiaAI: "Дія.AI"
        case .services: "Сервіси"
        case .menu: "Меню"
        }
    }

    /// The AI tab postdates the open-source release, so it has no bundled icon.
    func icon(selected: Bool) -> Icon {
        switch self {
        case .feed: .asset(selected ? "menuFeedActive" : "menuFeedInactive")
        case .documents: .asset(selected ? "menuDocumentsActive" : "menuDocumentsInactive")
        case .diiaAI: .symbol("sparkle")
        case .services: .asset(selected ? "menuServicesActive" : "menuServicesInactive")
        case .menu: .asset(selected ? "menuSettingsActive" : "menuSettingsInactive")
        }
    }
}
