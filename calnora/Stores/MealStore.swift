import Foundation
import Observation
import SwiftData

@Observable
final class MealStore {
    @ObservationIgnored private let context: ModelContext
    var meals: [MealEntry] = []
    var waterEntries: [WaterEntry] = []
    var favorites: [FavoriteMeal] = []

    init(context: ModelContext) {
        self.context = context
        load()
        seedFoodItemsIfNeeded()
    }

    func load() {
        let mealDescriptor = FetchDescriptor<MealEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        meals = (try? context.fetch(mealDescriptor)) ?? []

        let waterDescriptor = FetchDescriptor<WaterEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        waterEntries = (try? context.fetch(waterDescriptor)) ?? []

        let favoriteDescriptor = FetchDescriptor<FavoriteMeal>(sortBy: [SortDescriptor(\.name)])
        favorites = (try? context.fetch(favoriteDescriptor)) ?? []
    }

    func save(_ meal: MealEntry) {
        context.insert(meal)
        try? context.save()
        load()
    }

    func saveEstimate(_ estimate: ParsedMealEstimate, mealType: MealType) {
        let meal = MealEntry(
            mealType: mealType,
            name: estimate.mealName,
            servingDescription: estimate.servingSummary,
            calories: estimate.estimatedCalories,
            protein: estimate.protein,
            carbs: estimate.carbs,
            fat: estimate.fat,
            fiber: estimate.fiber,
            sugar: estimate.sugar,
            notes: estimate.explanation,
            source: .aiEstimate,
            confidence: estimate.confidence
        )
        save(meal)
    }

    func saveWater(amount: Double) {
        context.insert(WaterEntry(amount: amount))
        try? context.save()
        load()
    }

    func meals(on date: Date, calendar: Calendar = .current) -> [MealEntry] {
        meals.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func snapshots(on date: Date? = nil, calendar: Calendar = .current) -> [MealNutrientSnapshot] {
        let selectedMeals = date.map { day in meals.filter { calendar.isDate($0.date, inSameDayAs: day) } } ?? meals
        return selectedMeals.map(MealNutrientSnapshot.init(meal:))
    }

    func totalWater(on date: Date, calendar: Calendar = .current) -> Double {
        waterEntries
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .map(\.amount)
            .reduce(0, +)
    }

    private func seedFoodItemsIfNeeded() {
        let descriptor = FetchDescriptor<FoodItem>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let foods = LocalFoodSeed.items.map {
            FoodItem(
                name: $0.name,
                caloriesPerServing: $0.caloriesPerServing,
                protein: $0.protein,
                carbs: $0.carbs,
                fat: $0.fat,
                fiber: $0.fiber,
                sugar: $0.sugar,
                servingDescription: $0.servingDescription,
                isCustom: false
            )
        }
        foods.forEach(context.insert)
        try? context.save()
    }
}
