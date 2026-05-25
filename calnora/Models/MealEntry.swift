import Foundation
import SwiftData

@Model
final class MealEntry {
    var id = UUID()
    var date = Date()
    var mealType = MealType.breakfast
    var name = ""
    var servingDescription = ""
    var calories = 0.0
    var protein = 0.0
    var carbs = 0.0
    var fat = 0.0
    var fiber = 0.0
    var sugar = 0.0
    var notes = ""
    var source = MealSource.manual
    var confidence = 1.0
    var isFavorite = false

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
