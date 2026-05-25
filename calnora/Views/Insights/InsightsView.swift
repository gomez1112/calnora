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
                macroBalanceCard
                trendCard(title: "Protein Consistency", keyPath: \.protein, tint: CalnoraColors.protein)
                trendCard(title: "Water Trend", values: waterSamples(), tint: CalnoraColors.water)
                trendCard(title: "Weight Trend", values: placeholderWeightSamples(), tint: CalnoraColors.success)
                CalnoraEmptyState(
                    title: "Meal timing insights",
                    message: "Timing patterns will appear as you log more meals.",
                    systemImage: "clock.badge",
                    tint: CalnoraColors.coach
                )
            }
            .padding()
        }
        .background(CalnoraColors.groupedBackground)
        .navigationTitle("Insights")
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

    private func placeholderWeightSamples() -> [WeeklyValueSample] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return WeeklyValueSample(date: day, value: 0)
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

#Preview {
    InsightsView()
        .environment(MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
}
