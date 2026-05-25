import Foundation
import Testing
@testable import calnora

struct NutritionCalculatorTests {
    @Test func calculatesBasalAndActivityCalories() {
        let profile = CalorieProfile(
            age: 30,
            height: 65,
            weight: 150,
            units: .imperial,
            activityLevel: .moderate,
            goalType: .maintain,
            biologicalSex: .female
        )

        #expect(abs(NutritionCalculator.basalCalories(for: profile) - 1_401.3) < 1)
        #expect(abs(NutritionCalculator.activityAdjustedCalories(for: profile) - 2_172.0) < 2)
    }

    @Test func appliesGoalAdjustmentAndMacroTargets() {
        let profile = CalorieProfile(
            age: 30,
            height: 65,
            weight: 150,
            units: .imperial,
            activityLevel: .moderate,
            goalType: .gentleDeficit,
            biologicalSex: .female
        )

        let calories = NutritionCalculator.goalAdjustedCalories(for: profile)
        let targets = NutritionCalculator.macroTargets(for: 2_100, goalType: .maintain)

        #expect(abs(calories - 1_872) < 3)
        #expect(abs(targets.protein - 131.25) < 0.1)
        #expect(abs(targets.carbs - 236.25) < 0.1)
        #expect(abs(targets.fat - 70) < 0.1)
    }
}
