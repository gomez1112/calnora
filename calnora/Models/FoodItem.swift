import Foundation
import SwiftData

@Model
final class FoodItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var caloriesPerServing: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var servingDescription: String
    var isCustom: Bool

    init(
        id: UUID = UUID(),
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
        self.id = id
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
