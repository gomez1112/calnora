import Foundation

nonisolated enum GoalType: String, CaseIterable, Codable, Identifiable, Sendable {
    case maintain
    case gentleDeficit
    case buildMuscle
    case improveHabits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .maintain: "Maintain"
        case .gentleDeficit: "Gentle deficit"
        case .buildMuscle: "Build muscle"
        case .improveHabits: "Improve habits"
        }
    }
}

nonisolated enum AgeRange: String, CaseIterable, Codable, Identifiable, Sendable {
    case under18
    case eighteenToTwentyFour
    case twentyFiveToThirtyFour
    case thirtyFiveToFortyFour
    case fortyFiveToFiftyFour
    case fiftyFivePlus

    var id: String { rawValue }
}

nonisolated enum ActivityLevel: String, CaseIterable, Codable, Identifiable, Sendable {
    case low
    case light
    case moderate
    case active
    case veryActive

    var id: String { rawValue }

    var multiplier: Double {
        switch self {
        case .low: 1.2
        case .light: 1.375
        case .moderate: 1.55
        case .active: 1.725
        case .veryActive: 1.9
        }
    }

    var title: String {
        switch self {
        case .low: "Low"
        case .light: "Light"
        case .moderate: "Moderate"
        case .active: "Active"
        case .veryActive: "Very active"
        }
    }
}

nonisolated enum DietaryPreference: String, CaseIterable, Codable, Identifiable, Sendable {
    case balanced
    case vegetarian
    case vegan
    case pescatarian
    case highProtein
    case lowerCarb

    var id: String { rawValue }
}

nonisolated enum PreferredUnits: String, CaseIterable, Codable, Identifiable, Sendable {
    case imperial
    case metric

    var id: String { rawValue }
}

nonisolated enum MealType: String, CaseIterable, Codable, Identifiable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breakfast: "Breakfast"
        case .lunch: "Lunch"
        case .dinner: "Dinner"
        case .snack: "Snacks"
        }
    }

    var symbolName: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "moon"
        case .snack: "takeoutbag.and.cup.and.straw"
        }
    }
}

nonisolated enum MealSource: String, CaseIterable, Codable, Identifiable, Sendable {
    case manual
    case aiEstimate
    case favorite
    case seedFood

    var id: String { rawValue }
}

nonisolated enum CoachRole: String, Codable, Sendable {
    case user
    case assistant
    case system
}

nonisolated enum CoachInsightType: String, CaseIterable, Codable, Identifiable, Sendable {
    case dailyNote
    case calorieTrend
    case proteinConsistency
    case macroBalance
    case water
    case mealTiming

    var id: String { rawValue }
}
