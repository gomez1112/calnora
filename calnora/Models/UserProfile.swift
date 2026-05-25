import Foundation
import SwiftData

@Model
final class UserProfile {
    var id = UUID()
    var createdAt = Date()
    var updatedAt = Date()
    var displayName = ""
    var goal = GoalType.improveHabits
    var ageRange = AgeRange.twentyFiveToThirtyFour
    var height = 68.0
    var weight = 165.0
    var activityLevel = ActivityLevel.moderate
    var dietaryPreference = DietaryPreference.balanced
    var allergies: [String] = []
    var avoidedFoods: [String] = []
    var preferredUnits = PreferredUnits.imperial
    var hasCompletedOnboarding = false

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        updatedAt: Date = .now,
        displayName: String = "",
        goal: GoalType = .improveHabits,
        ageRange: AgeRange = .twentyFiveToThirtyFour,
        height: Double = 68,
        weight: Double = 165,
        activityLevel: ActivityLevel = .moderate,
        dietaryPreference: DietaryPreference = .balanced,
        allergies: [String] = [],
        avoidedFoods: [String] = [],
        preferredUnits: PreferredUnits = .imperial,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.displayName = displayName
        self.goal = goal
        self.ageRange = ageRange
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.dietaryPreference = dietaryPreference
        self.allergies = allergies
        self.avoidedFoods = avoidedFoods
        self.preferredUnits = preferredUnits
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
