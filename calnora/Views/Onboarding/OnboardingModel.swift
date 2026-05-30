import Foundation
import Observation
import OnboardingKit

@Observable
@MainActor
final class OnboardingModel {
    var displayName = ""
    var selectedGoal: GoalType = .improveHabits
    var ageRange: AgeRange = .twentyFiveToThirtyFour
    var height: Double = 68
    var weight: Double = 165
    var activityLevel: ActivityLevel = .moderate
    var dietaryPreference: DietaryPreference = .balanced
    var allergiesText = ""
    var avoidedFoodsText = ""
    var preferredUnits: PreferredUnits = .imperial
    var wantsReminders = false
    var acceptedDisclaimer = false

    var trimmedDisplayName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var profileDraft: OnboardingProfileDraft {
        OnboardingProfileDraft(
            displayName: trimmedDisplayName,
            goal: selectedGoal,
            ageRange: ageRange,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            dietaryPreference: dietaryPreference,
            allergiesText: allergiesText,
            avoidedFoodsText: avoidedFoodsText,
            preferredUnits: preferredUnits,
            wantsReminders: wantsReminders
        )
    }
}

nonisolated struct OnboardingProfileDraft: Equatable, Sendable {
    var displayName: String
    var goal: GoalType
    var ageRange: AgeRange
    var height: Double
    var weight: Double
    var activityLevel: ActivityLevel
    var dietaryPreference: DietaryPreference
    var allergiesText: String
    var avoidedFoodsText: String
    var preferredUnits: PreferredUnits
    var wantsReminders: Bool

    var allergyList: [String] {
        Self.splitCommaSeparatedList(allergiesText)
    }

    var avoidedFoodList: [String] {
        Self.splitCommaSeparatedList(avoidedFoodsText)
    }

    private static func splitCommaSeparatedList(_ text: String) -> [String] {
        text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
