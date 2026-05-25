import Foundation
import Testing
@testable import calnora

struct MealMathTests {
    @Test func calculatesMealDailyAndWeeklyTotals() {
        let calendar = Calendar(identifier: .gregorian)
        let day = calendar.date(from: DateComponents(year: 2026, month: 5, day: 25))!
        let meals = [
            MealNutrientSnapshot(id: UUID(), date: day, mealType: .breakfast, name: "Eggs", calories: 140, protein: 12, carbs: 1, fat: 10, fiber: 0, sugar: 0),
            MealNutrientSnapshot(id: UUID(), date: day, mealType: .lunch, name: "Chicken", calories: 300, protein: 40, carbs: 20, fat: 8, fiber: 3, sugar: 2)
        ]

        let totals = NutritionCalculator.mealTotals(for: meals)
        let daily = NutritionCalculator.dailyTotals(for: meals, on: day, calendar: calendar)
        let average = NutritionCalculator.weeklyAverageCalories(for: meals, ending: day, calendar: calendar)

        #expect(totals.calories == 440)
        #expect(totals.protein == 52)
        #expect(daily.carbs == 21)
        #expect(abs(average - (440.0 / 7.0)) < 0.01)
    }

    @Test func calculatesRemainingWaterAndStreak() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2026, month: 5, day: 25))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let targets = NutritionTargets(calories: 2_000, protein: 120, carbs: 220, fat: 65, fiber: 28, water: 80)
        let consumed = NutritionTotals(calories: 1_500, protein: 80, carbs: 150, fat: 45, fiber: 20, sugar: 35)

        let remaining = NutritionCalculator.remaining(targets: targets, consumed: consumed)
        let progress = NutritionCalculator.waterProgress(consumed: 40, target: 80)
        let streak = NutritionCalculator.streakDays(from: [today, yesterday, twoDaysAgo], calendar: calendar, today: today)

        #expect(remaining.calories == 500)
        #expect(remaining.protein == 40)
        #expect(progress == 0.5)
        #expect(streak == 3)
    }
}
