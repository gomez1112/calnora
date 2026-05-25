import Charts
import EZCharts
import SwiftUI

struct HistoryView: View {
    @Environment(MealStore.self) private var mealStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore

    var body: some View {
        List {
            Section("Weekly Summary") {
                let samples = makeSamples()
                EZAnimatedChart(animation: .smooth, reveal: .horizontal, replayToken: samples.count) { progress in
                    ForEach(samples) { sample in
                        LineMark(
                            x: .value("Day", sample.date, unit: .day),
                            y: .value("Calories", EZChartProgress.scaled(sample.calories, progress: progress))
                        )
                        .foregroundStyle(CalnoraColors.calories)
                        PointMark(
                            x: .value("Day", sample.date, unit: .day),
                            y: .value("Calories", EZChartProgress.scaled(sample.calories, progress: progress))
                        )
                        .foregroundStyle(CalnoraColors.calories)
                    }
                    RuleMark(y: .value("Target", nutritionGoalStore.targets.calories))
                        .foregroundStyle(.secondary)
                }
                .frame(height: 180)
                .accessibilityLabel("Weekly calorie history")
            }

            Section("Meals") {
                if mealStore.meals.isEmpty {
                    Text("Logged meals will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(mealStore.meals) { meal in
                        VStack(alignment: .leading) {
                            Text(meal.name)
                                .font(.headline)
                            Text(meal.date, format: .dateTime.month().day().hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }

    private func makeSamples() -> [WeeklyCalorieSample] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return WeeklyCalorieSample(
                date: day,
                calories: NutritionCalculator.dailyTotals(for: mealStore.snapshots(), on: day, calendar: calendar).calories
            )
        }
    }
}
