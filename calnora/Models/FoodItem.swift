import Foundation
import SwiftData

@Model
final class FoodItem {
    var name = ""
    var caloriesPerServing = 0.0
    var protein = 0.0
    var carbs = 0.0
    var fat = 0.0
    var fiber = 0.0
    var sugar = 0.0
    var servingDescription = ""
    var isCustom = false
    var favoriteMeals: [FavoriteMeal]? = []

    init(
        name: String,
        caloriesPerServing: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0,
        sugar: Double = 0,
        servingDescription: String = "1 serving",
        isCustom: Bool = false
    ) {
        self.name = name
        self.caloriesPerServing = caloriesPerServing
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.servingDescription = servingDescription
        self.isCustom = isCustom
    }
}
