import Foundation
import SwiftData

@Model
final class NutritionGoal {
    var id = UUID()
    var calories = 2_100.0
    var protein = 130.0
    var carbs = 230.0
    var fat = 70.0
    var fiber = 28.0
    var water = 80.0
    var goalType = GoalType.improveHabits
    var createdAt = Date()
    var updatedAt = Date()

    init(
        id: UUID = UUID(),
        calories: Double = 2_100,
        protein: Double = 130,
        carbs: Double = 230,
        fat: Double = 70,
        fiber: Double = 28,
        water: Double = 80,
        goalType: GoalType = .improveHabits,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.water = water
        self.goalType = goalType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
