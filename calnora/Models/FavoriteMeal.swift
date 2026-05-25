import Foundation
import SwiftData

@Model
final class FavoriteMeal {
    var name = ""
    @Relationship(deleteRule: .nullify, inverse: \FoodItem.favoriteMeals) var mealItems: [FoodItem]? = []
    var totalCalories = 0.0
    var totalProtein  = 0.0
    var totalCarbs  = 0.0
    var totalFat  = 0.0

    init(
        name: String,
        mealItems: [FoodItem] = [],
        totalCalories: Double = 0,
        totalProtein: Double = 0,
        totalCarbs: Double = 0,
        totalFat: Double = 0
    ) {
        self.name = name
        self.mealItems = mealItems
        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
    }
}
