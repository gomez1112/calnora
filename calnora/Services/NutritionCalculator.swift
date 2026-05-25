import Foundation

nonisolated enum BiologicalSex: String, CaseIterable, Codable, Sendable {
    case female
    case male
    case unspecified
}

nonisolated struct CalorieProfile: Equatable, Sendable {
    var age: Int
    var height: Double
    var weight: Double
    var units: PreferredUnits
    var activityLevel: ActivityLevel
    var goalType: GoalType
    var biologicalSex: BiologicalSex
}

nonisolated struct NutritionTargets: Equatable, Sendable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var water: Double
}

nonisolated struct NutritionTotals: Equatable, Sendable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double

    static let zero = NutritionTotals(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0)
}

nonisolated struct MealNutrientSnapshot: Identifiable, Equatable, Sendable {
    var id: UUID
    var date: Date
    var mealType: MealType
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
}

extension MealNutrientSnapshot {
    init(meal: MealEntry) {
        self.init(
            id: meal.id,
            date: meal.date,
            mealType: meal.mealType,
            name: meal.name,
            calories: meal.calories,
            protein: meal.protein,
            carbs: meal.carbs,
            fat: meal.fat,
            fiber: meal.fiber,
            sugar: meal.sugar
        )
    }
}

nonisolated struct LocalMealEstimate: Equatable, Sendable {
    var name: String
    var totals: NutritionTotals
    var items: [ParsedFoodItem]
}

nonisolated enum NutritionCalculator {
    static func basalCalories(for profile: CalorieProfile) -> Double {
        let kilograms = profile.units == .imperial ? profile.weight * 0.453_592_37 : profile.weight
        let centimeters = profile.units == .imperial ? profile.height * 2.54 : profile.height
        let sexAdjustment: Double

        switch profile.biologicalSex {
        case .female:
            sexAdjustment = -161
        case .male:
            sexAdjustment = 5
        case .unspecified:
            sexAdjustment = -78
        }

        return (10 * kilograms) + (6.25 * centimeters) - (5 * Double(profile.age)) + sexAdjustment
    }

    static func activityAdjustedCalories(for profile: CalorieProfile) -> Double {
        basalCalories(for: profile) * profile.activityLevel.multiplier
    }

    static func goalAdjustedCalories(for profile: CalorieProfile) -> Double {
        let maintenance = activityAdjustedCalories(for: profile)

        switch profile.goalType {
        case .maintain, .improveHabits:
            return maintenance
        case .gentleDeficit:
            return max(maintenance - 300, 1_500)
        case .buildMuscle:
            return maintenance + 250
        }
    }

    static func macroTargets(for calories: Double, goalType: GoalType) -> NutritionTargets {
        let proteinRatio: Double
        let carbRatio: Double
        let fatRatio: Double

        switch goalType {
        case .buildMuscle:
            proteinRatio = 0.32
            carbRatio = 0.40
            fatRatio = 0.28
        case .gentleDeficit:
            proteinRatio = 0.30
            carbRatio = 0.38
            fatRatio = 0.32
        case .maintain, .improveHabits:
            proteinRatio = 0.25
            carbRatio = 0.45
            fatRatio = 0.30
        }

        return NutritionTargets(
            calories: calories,
            protein: calories * proteinRatio / 4,
            carbs: calories * carbRatio / 4,
            fat: calories * fatRatio / 9,
            fiber: 28,
            water: 80
        )
    }

    static func mealTotals(for meals: [MealNutrientSnapshot]) -> NutritionTotals {
        meals.reduce(.zero) { partial, meal in
            NutritionTotals(
                calories: partial.calories + meal.calories,
                protein: partial.protein + meal.protein,
                carbs: partial.carbs + meal.carbs,
                fat: partial.fat + meal.fat,
                fiber: partial.fiber + meal.fiber,
                sugar: partial.sugar + meal.sugar
            )
        }
    }

    static func dailyTotals(for meals: [MealNutrientSnapshot], on day: Date, calendar: Calendar = .current) -> NutritionTotals {
        mealTotals(for: meals.filter { calendar.isDate($0.date, inSameDayAs: day) })
    }

    static func weeklyAverageCalories(for meals: [MealNutrientSnapshot], ending endDate: Date, calendar: Calendar = .current) -> Double {
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: endDate)) ?? endDate
        let calories = (0..<7).map { offset -> Double in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return dailyTotals(for: meals, on: day, calendar: calendar).calories
        }
        return calories.reduce(0, +) / 7
    }

    static func remaining(targets: NutritionTargets, consumed: NutritionTotals) -> NutritionTargets {
        NutritionTargets(
            calories: targets.calories - consumed.calories,
            protein: targets.protein - consumed.protein,
            carbs: targets.carbs - consumed.carbs,
            fat: targets.fat - consumed.fat,
            fiber: targets.fiber - consumed.fiber,
            water: targets.water
        )
    }

    static func waterProgress(consumed: Double, target: Double) -> Double {
        guard target > 0 else { return 0 }
        return min(max(consumed / target, 0), 1)
    }

    static func streakDays(from dates: [Date], calendar: Calendar = .current, today: Date = .now) -> Int {
        let loggedDays = Set(dates.map { calendar.startOfDay(for: $0) })
        var cursor = calendar.startOfDay(for: today)
        var count = 0

        while loggedDays.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return count
    }

    static func estimateMeal(from text: String) -> LocalMealEstimate {
        let lowercased = text.lowercased()
        let seedItems = LocalFoodSeed.items.filter { lowercased.contains($0.name.lowercased()) }
        let fallbackItems = seedItems.isEmpty ? [LocalFoodSeed.items[0]] : seedItems
        let parsedItems = fallbackItems.map {
            ParsedFoodItem(
                name: $0.name,
                servingSummary: $0.servingDescription,
                calories: $0.caloriesPerServing,
                protein: $0.protein,
                carbs: $0.carbs,
                fat: $0.fat
            )
        }
        let snapshots = parsedItems.map {
            MealNutrientSnapshot(
                id: UUID(),
                date: .now,
                mealType: .breakfast,
                name: $0.name,
                calories: $0.calories,
                protein: $0.protein,
                carbs: $0.carbs,
                fat: $0.fat,
                fiber: 0,
                sugar: 0
            )
        }
        return LocalMealEstimate(
            name: fallbackItems.count == 1 ? fallbackItems[0].name : "Estimated meal",
            totals: mealTotals(for: snapshots),
            items: parsedItems
        )
    }
}
