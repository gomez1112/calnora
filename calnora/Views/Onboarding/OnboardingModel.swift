import Observation
import OnboardingKit
import SwiftUI

@Observable
final class OnboardingModel {
    var hasFinishedIntro = false
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

    var canFinishSetup: Bool {
        acceptedDisclaimer && height > 0 && weight > 0
    }

    var profileDraft: OnboardingProfileDraft {
        OnboardingProfileDraft(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
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

    var pages: [OnboardingPage] {
        [
            OnboardingPage(
                title: "Welcome to Calnora",
                description: "Private calorie and macro logging with editable AI estimates and calm daily coaching.",
                systemImage: "heart.text.square",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.calories
            ),
            OnboardingPage(
                title: "Choose your goal",
                description: "Focus on awareness, consistency, and routines that feel sustainable.",
                systemImage: "scope",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.success
            ),
            OnboardingPage(
                title: "Body metrics",
                description: "Use approximate details to create a starting target. You can edit everything later.",
                systemImage: "ruler",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.protein
            ),
            OnboardingPage(
                title: "Activity level",
                description: "Calnora uses activity as context, not judgment.",
                systemImage: "figure.walk",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.water
            ),
            OnboardingPage(
                title: "Dietary preferences",
                description: "Add preferences, allergies, and avoidances so estimates and ideas fit you.",
                systemImage: "leaf",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.fat
            ),
            OnboardingPage(
                title: "Units and reminders",
                description: "Choose your units and optional gentle reminders. Nothing guilt-based.",
                systemImage: "bell.badge",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.coach
            ),
            OnboardingPage(
                title: "Health disclaimer",
                description: "Calnora provides informational wellness guidance only. It does not diagnose, treat, or replace professional care.",
                systemImage: "checkmark.shield",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.warning
            ),
            OnboardingPage(
                title: "Optional Pro",
                description: "Unlock unlimited AI estimates, coach chat, weekly insights, and premium trends when you are ready.",
                systemImage: "sparkles",
                backgroundColor: CalnoraColors.groupedBackground,
                iconColor: CalnoraColors.coach
            )
        ]
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
