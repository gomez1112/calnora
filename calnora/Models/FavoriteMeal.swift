import Foundation
import SwiftData

@Model
final class FavoriteMeal {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .nullify) var mealItems: [FoodItem]
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double

    init(
        id: UUID = UUID(),
        name: String,
        mealItems: [FoodItem] = [],
        totalCalories: Double = 0,
        totalProtein: Double = 0,
        totalCarbs: Double = 0,
        totalFat: Double = 0
    ) {
        self.id = id
        self.name = name
        self.mealItems = mealItems
        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
    }
}
