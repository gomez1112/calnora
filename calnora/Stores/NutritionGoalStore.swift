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
}
