import Foundation
import Observation

@Observable
final class AppState {
    var hasCompletedOnboarding: Bool
    var selectedTab: AppTab
    var showingPaywall: Bool
    var showingMealEditor: Bool
    var activeNotification: CalnoraBanner?

    init(
        hasCompletedOnboarding: Bool = false,
        selectedTab: AppTab = .dashboard,
        showingPaywall: Bool = false,
        showingMealEditor: Bool = false,
        activeNotification: CalnoraBanner? = nil
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.selectedTab = selectedTab
        self.showingPaywall = showingPaywall
        self.showingMealEditor = showingMealEditor
        self.activeNotification = activeNotification
    }
}

nonisolated enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case dashboard
    case meals
    case coach
    case history
    case insights
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Today"
        case .meals: "Meals"
        case .coach: "Coach"
        case .history: "History"
        case .insights: "Insights"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "heart.text.square"
        case .meals: "fork.knife.circle"
        case .coach: "sparkles"
        case .history: "calendar"
        case .insights: "chart.xyaxis.line"
        case .settings: "gearshape"
        }
    }
}

nonisolated struct CalnoraBanner: Identifiable, Equatable, Sendable {
    let id = UUID()
    var title: String
    var message: String
    var symbolName: String
}
