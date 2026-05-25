import Foundation
import Observation

@Observable
final class MealEditorModel {
    var date = Date()
    var mealType: MealType = .breakfast
    var name = ""
    var servingDescription = "1 serving"
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var fiber: Double = 0
    var sugar: Double = 0
    var notes = ""
    var saveAsFavorite = false

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && calories >= 0
    }

    func apply(_ estimate: ParsedMealEstimate) {
        name = estimate.mealName
        servingDescription = estimate.servingSummary
        calories = estimate.estimatedCalories
        protein = estimate.protein
        carbs = estimate.carbs
        fat = estimate.fat
        fiber = estimate.fiber
        sugar = estimate.sugar
        notes = estimate.explanation
    }

    func makeMealEntry(source: MealSource = .manual, confidence: Double = 1) -> MealEntry {
        MealEntry(
            date: date,
            mealType: mealType,
            name: name,
            servingDescription: servingDescription,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            notes: notes,
            source: source,
            confidence: confidence,
            isFavorite: saveAsFavorite
        )
    }
}
