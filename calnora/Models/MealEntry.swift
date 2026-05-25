import Foundation
import SwiftData

@Model
final class MealEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mealType: MealType
    var name: String
    var servingDescription: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var notes: String
    var source: MealSource
    var confidence: Double
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        date: Date = .now,
        mealType: MealType = .breakfast,
        name: String,
        servingDescription: String = "1 serving",
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0,
        sugar: Double = 0,
        notes: String = "",
        source: MealSource = .manual,
        confidence: Double = 1,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.name = name
        self.servingDescription = servingDescription
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.notes = notes
        self.source = source
        self.confidence = confidence
        self.isFavorite = isFavorite
    }
}
