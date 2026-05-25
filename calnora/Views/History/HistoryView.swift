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

            Section("Daily Totals") {
                ForEach(makeDailySummaries()) { summary in
                    DailySummaryRow(summary: summary, targetCalories: nutritionGoalStore.targets.calories)
                }
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
                            HStack(spacing: CalnoraSpacing.small) {
                                Text(meal.calories, format: .number.precision(.fractionLength(0)))
                                Text("cal")
                                Text(meal.protein, format: .number.precision(.fractionLength(0)))
                                Text("g protein")
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Weight") {
                if let latest = mealStore.weightEntries.first {
                    LabeledContent("Latest") {
                        Text(latest.weight, format: .number.precision(.fractionLength(1)))
                        Text("lb")
                    }
                    Text(latest.date, format: .dateTime.month().day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Weight entries are optional and stay local.")
                        .foregroundStyle(.secondary)
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

    private func makeDailySummaries() -> [DailyNutritionSummary] {
        let calendar = Calendar.current
        let snapshots = mealStore.snapshots()
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            let totals = NutritionCalculator.dailyTotals(for: snapshots, on: day, calendar: calendar)
            return DailyNutritionSummary(
                date: day,
                totals: totals,
                water: mealStore.totalWater(on: day),
                mealCount: snapshots.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            )
        }
    }
}

private struct DailyNutritionSummary: Identifiable {
    var id: Date { date }
    var date: Date
    var totals: NutritionTotals
    var water: Double
    var mealCount: Int
}

private struct DailySummaryRow: View {
    var summary: DailyNutritionSummary
    var targetCalories: Double

    var body: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            VStack(alignment: .leading, spacing: 3) {
                Text(summary.date, format: .dateTime.weekday(.wide).month().day())
                    .font(.headline)
                Text("\(summary.mealCount) meals")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(summary.totals.calories, format: .number.precision(.fractionLength(0)))
                    .font(.headline.monospacedDigit())
                Text("of \(targetCalories, format: .number.precision(.fractionLength(0))) cal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    Text(summary.water, format: .number.precision(.fractionLength(0)))
                    Text("oz water")
                }
            }
            .font(.caption)
        }
        .accessibilityElement(children: .combine)
    }
}
