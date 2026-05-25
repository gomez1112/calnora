import Charts
import EZCharts
import SwiftData
import SwiftUI

struct InsightsView: View {
    @Environment(MealStore.self) private var mealStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: CalnoraSpacing.large) {
                CalnoraSectionHeader(title: "Insights", subtitle: "Approximate trends from your local data")
                weeklyCaloriesCard
                insightSummaryCards
                macroBalanceCard
                trendCard(title: "Protein Consistency", keyPath: \.protein, tint: CalnoraColors.protein)
                trendCard(title: "Water Trend", values: waterSamples(), tint: CalnoraColors.water)
                weightTrendCard
                mealTimingCard
            }
            .padding()
        }
        .background(CalnoraColors.groupedBackground)
        .navigationTitle("Insights")
    }

    private var weeklyCaloriesCard: some View {
        let values = makeDailyValues(keyPath: \.calories)
        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Weekly Calories", subtitle: "Compared with your target")
            EZAnimatedChart(animation: .smooth, reveal: .horizontal, replayToken: values.count) { progress in
                ForEach(values) { sample in
                    LineMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.value, progress: progress))
                    )
                    .foregroundStyle(CalnoraColors.calories)
                    AreaMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.value, progress: progress))
                    )
                    .foregroundStyle(CalnoraColors.calories.opacity(0.18).gradient)
                }
                RuleMark(y: .value("Target", nutritionGoalStore.targets.calories))
                    .foregroundStyle(.secondary)
            }
            .ezChartYScale(for: values.map(\.value) + [nutritionGoalStore.targets.calories], fallback: 0...1)
            .frame(height: 180)
        }
        .calnoraCard(tint: CalnoraColors.calories)
    }

    private var insightSummaryCards: some View {
        let weeklyAverage = NutritionCalculator.weeklyAverageCalories(for: mealStore.snapshots(), ending: .now)
        let todayProtein = NutritionCalculator.mealTotals(for: mealStore.snapshots(on: .now)).protein
        let targetProtein = nutritionGoalStore.targets.protein

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: CalnoraSpacing.medium)], spacing: CalnoraSpacing.medium) {
            HealthMetricCard(
                title: "7-day average",
                value: weeklyAverage,
                target: nutritionGoalStore.targets.calories,
                unit: "cal",
                symbolName: "chart.line.uptrend.xyaxis",
                tint: CalnoraColors.calories
            )
            HealthMetricCard(
                title: "Protein today",
                value: todayProtein,
                target: targetProtein,
                unit: "g",
                symbolName: "bolt.fill",
                tint: CalnoraColors.protein
            )
        }
    }

    private var macroBalanceCard: some View {
        let totals = NutritionCalculator.mealTotals(for: mealStore.snapshots(on: .now))
        let sectors = [
            MacroSector(name: "Protein", value: totals.protein, tint: CalnoraColors.protein),
            MacroSector(name: "Carbs", value: totals.carbs, tint: CalnoraColors.carbs),
            MacroSector(name: "Fat", value: totals.fat, tint: CalnoraColors.fat)
        ]

        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Macro Balance", subtitle: "Today")
            EZAnimatedSectorChart(sectors, id: \.name, value: \.value, replayToken: totals.calories) { sector in
                sector.tint
            }
            .frame(height: 210)
            HStack {
                ForEach(sectors) { sector in
                    Label(sector.name, systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(sector.tint)
                }
            }
        }
        .calnoraCard()
    }

    private func trendCard(title: String, keyPath: KeyPath<MealNutrientSnapshot, Double>, tint: Color) -> some View {
        let values = makeDailyValues(keyPath: keyPath)
        return trendCard(title: title, values: values, tint: tint)
    }

    private func trendCard(title: String, values: [WeeklyValueSample], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: title, subtitle: "Last 7 days")
            EZAnimatedChart(animation: .smooth, reveal: .horizontal, replayToken: title) { progress in
                ForEach(values) { sample in
                    BarMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Value", EZChartProgress.scaled(sample.value, progress: progress))
                    )
                    .foregroundStyle(tint.gradient)
                    .cornerRadius(8)
                }
            }
            .ezChartYScale(for: values.map(\.value), fallback: 0...1)
            .frame(height: 160)
        }
        .calnoraCard(tint: tint)
    }

    private var weightTrendCard: some View {
        Group {
            if mealStore.weightEntries.isEmpty {
                CalnoraEmptyState(
                    title: "Weight trend",
                    message: "Optional weight entries will appear here when logged.",
                    systemImage: "chart.line.uptrend.xyaxis",
                    tint: CalnoraColors.success
                )
            } else {
                trendCard(title: "Weight Trend", values: weightSamples(), tint: CalnoraColors.success)
            }
        }
    }

    private var mealTimingCard: some View {
        let samples = mealTimingSamples()
        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Meal Timing", subtitle: "Meals logged by type")
            if samples.allSatisfy({ $0.count == 0 }) {
                CalnoraEmptyState(
                    title: "No timing pattern yet",
                    message: "Meal timing insights will appear as you log breakfast, lunch, dinner, and snacks.",
                    systemImage: "clock.badge",
                    tint: CalnoraColors.coach
                )
            } else {
                EZAnimatedChart(animation: .smooth, reveal: .none, replayToken: samples.map(\.count).reduce(0, +)) { progress in
                    ForEach(samples) { sample in
                        BarMark(
                            x: .value("Meal", sample.mealType.title),
                            y: .value("Count", EZChartProgress.scaled(Double(sample.count), progress: progress))
                        )
                        .foregroundStyle(CalnoraColors.coach.gradient)
                        .cornerRadius(8)
                    }
                }
                .frame(height: 170)
            }
        }
        .calnoraCard(tint: CalnoraColors.coach)
    }

    private func makeDailyValues(keyPath: KeyPath<MealNutrientSnapshot, Double>) -> [WeeklyValueSample] {
        let calendar = Calendar.current
        let snapshots = mealStore.snapshots()
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            let value = snapshots
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .map { $0[keyPath: keyPath] }
                .reduce(0, +)
            return WeeklyValueSample(date: day, value: value)
        }
    }

    private func waterSamples() -> [WeeklyValueSample] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return WeeklyValueSample(date: day, value: mealStore.totalWater(on: day))
        }
    }

    private func weightSamples() -> [WeeklyValueSample] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            let weight = mealStore.weightEntries.first { calendar.isDate($0.date, inSameDayAs: day) }?.weight ?? 0
            return WeeklyValueSample(date: day, value: weight)
        }
    }

    private func mealTimingSamples() -> [MealTimingSample] {
        MealType.allCases.map { type in
            MealTimingSample(
                mealType: type,
                count: mealStore.meals.filter { $0.mealType == type }.count
            )
        }
    }
}

private struct MacroSector: Identifiable {
    var id: String { name }
    var name: String
    var value: Double
    var tint: Color
}

private struct WeeklyValueSample: Identifiable {
    let id = UUID()
    var date: Date
    var value: Double
}

private struct MealTimingSample: Identifiable {
    var id: MealType { mealType }
    var mealType: MealType
    var count: Int
}

#Preview {
    InsightsView()
        .environment(MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
}
