import Foundation
import Observation

@Observable
final class AppRouter {
    var dashboardPath: [AppRoute] = []
    var mealPath: [AppRoute] = []
    var coachPath: [AppRoute] = []
    var historyPath: [AppRoute] = []
    var insightsPath: [AppRoute] = []
    var settingsPath: [AppRoute] = []

    func push(_ route: AppRoute, in tab: AppTab) {
        switch tab {
        case .dashboard:
            dashboardPath.append(route)
        case .meals:
            mealPath.append(route)
        case .coach:
            coachPath.append(route)
        case .history:
            historyPath.append(route)
        case .insights:
            insightsPath.append(route)
        case .settings:
            settingsPath.append(route)
        }
    }
}

enum AppRoute: Hashable {
    case mealEditor
    case aiMealParse
    case paywall
    case profile
    case privacy
    case premiumPack
}
