import Foundation
import Observation
import SwiftData

@Observable
final class NutritionGoalStore {
    @ObservationIgnored private let context: ModelContext
    var goal: NutritionGoal?

    init(context: ModelContext) {
        self.context = context
        loadGoal()
    }

    func loadGoal() {
        let descriptor = FetchDescriptor<NutritionGoal>(sortBy: [SortDescriptor(\.createdAt)])
        goal = try? context.fetch(descriptor).first
    }

    @discardableResult
    func ensureGoal() -> NutritionGoal {
        if let goal { return goal }
        let goal = NutritionGoal()
        context.insert(goal)
        try? context.save()
        self.goal = goal
        return goal
    }

    var targets: NutritionTargets {
        let goal = ensureGoal()
        return NutritionTargets(
            calories: goal.calories,
            protein: goal.protein,
            carbs: goal.carbs,
            fat: goal.fat,
            fiber: goal.fiber,
            water: goal.water
        )
    }

    func updateTargets(_ targets: NutritionTargets, goalType: GoalType) {
        let goal = ensureGoal()
        goal.calories = targets.calories
        goal.protein = targets.protein
        goal.carbs = targets.carbs
        goal.fat = targets.fat
        goal.fiber = targets.fiber
        goal.water = targets.water
        goal.goalType = goalType
        goal.updatedAt = .now
        try? context.save()
        self.goal = goal
    }

    func recalculate(from profile: UserProfile) {
        let calorieProfile = CalorieProfile(
            age: profile.ageRange.representativeAge,
            height: profile.height,
            weight: profile.weight,
            units: profile.preferredUnits,
            activityLevel: profile.activityLevel,
            goalType: profile.goal,
            biologicalSex: .unspecified
        )
        let calories = NutritionCalculator.goalAdjustedCalories(for: calorieProfile)
        var targets = NutritionCalculator.macroTargets(for: calories, goalType: profile.goal)
        targets.water = profile.preferredUnits == .imperial ? 80 : 2_400
        updateTargets(targets, goalType: profile.goal)
    }

    func saveChanges() {
        goal?.updatedAt = .now
        try? context.save()
        loadGoal()
    }
}
