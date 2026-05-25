import Foundation
import Observation
import SwiftData

@Observable
final class MealStore {
    @ObservationIgnored private let context: ModelContext
    var meals: [MealEntry] = []
    var waterEntries: [WaterEntry] = []
    var weightEntries: [WeightEntry] = []
    var favorites: [FavoriteMeal] = []
    var foodItems: [FoodItem] = []

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

        let weightDescriptor = FetchDescriptor<WeightEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        weightEntries = (try? context.fetch(weightDescriptor)) ?? []

        let favoriteDescriptor = FetchDescriptor<FavoriteMeal>(sortBy: [SortDescriptor(\.name)])
        favorites = (try? context.fetch(favoriteDescriptor)) ?? []

        let foodDescriptor = FetchDescriptor<FoodItem>(sortBy: [SortDescriptor(\.name)])
        foodItems = (try? context.fetch(foodDescriptor)) ?? []
    }

    func save(_ meal: MealEntry) {
        context.insert(meal)
        try? context.save()
        load()
    }

    func delete(_ meal: MealEntry) {
        context.delete(meal)
        try? context.save()
        load()
    }

    func toggleFavorite(_ meal: MealEntry) {
        meal.isFavorite.toggle()
        if meal.isFavorite {
            saveFavorite(from: meal)
        } else if let favorite = favorites.first(where: { $0.name == meal.name }) {
            context.delete(favorite)
        }
        try? context.save()
        load()
    }

    func saveFavorite(from meal: MealEntry) {
        guard !favorites.contains(where: { $0.name.localizedCaseInsensitiveCompare(meal.name) == .orderedSame }) else { return }
        context.insert(FavoriteMeal(
            name: meal.name,
            totalCalories: meal.calories,
            totalProtein: meal.protein,
            totalCarbs: meal.carbs,
            totalFat: meal.fat
        ))
        try? context.save()
        load()
    }

    func logFavorite(_ favorite: FavoriteMeal, mealType: MealType = .lunch) {
        save(MealEntry(
            mealType: mealType,
            name: favorite.name,
            servingDescription: "Saved favorite",
            calories: favorite.totalCalories,
            protein: favorite.totalProtein,
            carbs: favorite.totalCarbs,
            fat: favorite.totalFat,
            source: .favorite,
            confidence: 1,
            isFavorite: true
        ))
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

    func saveWeight(_ weight: Double) {
        context.insert(WeightEntry(weight: weight))
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
        load()
    }
}
