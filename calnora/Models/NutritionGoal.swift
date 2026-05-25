import Foundation
import SwiftData

@Model
final class NutritionGoal {
    @Attribute(.unique) var id: UUID
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var water: Double
    var goalType: GoalType
    var createdAt: Date
    var updatedAt: Date

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
