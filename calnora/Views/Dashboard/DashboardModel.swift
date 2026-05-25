import Foundation
import Observation

@Observable
final class DashboardModel {
    var today = Date.now
    var weeklySamples: [WeeklyCalorieSample] = []
    var dailyTotals: NutritionTotals = .zero
    var target: NutritionTargets = NutritionTargets(calories: 2_100, protein: 130, carbs: 230, fat: 70, fiber: 28, water: 80)
    var water: Double = 0
    var streak: Int = 0

    func update(mealStore: MealStore, nutritionGoalStore: NutritionGoalStore) {
        target = nutritionGoalStore.targets
        let snapshots = mealStore.snapshots(on: today)
        dailyTotals = NutritionCalculator.mealTotals(for: snapshots)
        water = mealStore.totalWater(on: today)
        streak = NutritionCalculator.streakDays(from: mealStore.meals.map(\.date), today: today)
        weeklySamples = makeWeeklySamples(from: mealStore.snapshots(), calendar: .current)
    }

    private func makeWeeklySamples(from meals: [MealNutrientSnapshot], calendar: Calendar) -> [WeeklyCalorieSample] {
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: today)) ?? today
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return WeeklyCalorieSample(
                date: day,
                calories: NutritionCalculator.dailyTotals(for: meals, on: day, calendar: calendar).calories
            )
        }
    }
}

nonisolated struct WeeklyCalorieSample: Identifiable, Equatable, Sendable {
    let id = UUID()
    var date: Date
    var calories: Double
}
