import Charts
import EZCharts
import SwiftData
import SwiftUI

struct InsightsView: View {
    @Environment(MealStore.self) private var mealStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @State private var hasAppeared = false
    @State private var barsRevealed = false

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: CalnoraSpacing.large) {
                greetingHeader

                weeklyAveragesHero
                    .stagger(0, hasAppeared: hasAppeared)

                weeklyCaloriesCard
                    .stagger(1, hasAppeared: hasAppeared)

                macroBalanceCard
                    .stagger(2, hasAppeared: hasAppeared)

                trendCard(
                    title: "Protein consistency",
                    subtitle: "Last 7 days",
                    samples: makeDailyValues(keyPath: \.protein),
                    tint: CalnoraColors.protein,
                    unit: "g"
                )
                .stagger(3, hasAppeared: hasAppeared)

                trendCard(
                    title: "Water trend",
                    subtitle: "Last 7 days",
                    samples: waterSamples(),
                    tint: CalnoraColors.water,
                    unit: "oz"
                )
                .stagger(4, hasAppeared: hasAppeared)

                weightTrendCard
                    .stagger(5, hasAppeared: hasAppeared)

                mealTimingCard
                    .stagger(6, hasAppeared: hasAppeared)
            }
            .calnoraScreenContent()
        }
        .calnoraAmbientBackground()
        .scrollIndicators(.hidden)
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .onAppear { animateIn() }
    }

    // MARK: - Header

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Insights")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.4)
                Text("Patterns from your data")
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.caption.weight(.semibold))
                Text("Local")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(CalnoraColors.success)
            .padding(.horizontal, CalnoraSpacing.small)
            .padding(.vertical, 6)
            .background(CalnoraColors.success.opacity(0.14), in: .capsule)
        }
        .padding(.horizontal, CalnoraSpacing.xSmall)
    }

    // MARK: - Weekly averages hero

    private var weeklyAveragesHero: some View {
        let avgCals = NutritionCalculator.weeklyAverageCalories(for: mealStore.snapshots(), ending: .now)
        let target = nutritionGoalStore.targets.calories
        let progress = min(max(avgCals / max(target, 1), 0), 1)
        let avgs = weeklyMacroAverages

        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("7-day average")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(Int(avgCals.rounded()), format: .number)
                            .contentTransition(.numericText(value: avgCals))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("kcal/day")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Goal \(Int(target.rounded()))")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                    Text(statusFor(progress: avgCals / max(target, 1)))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(CalnoraColors.calories)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(CalnoraColors.calories.opacity(0.14))
                    Capsule()
                        .fill(CalnoraColors.calories.gradient)
                        .frame(width: geo.size.width * (barsRevealed ? progress : 0))
                        .shadow(color: CalnoraColors.calories.opacity(0.32), radius: 6, y: 2)
                }
            }
            .frame(height: 10)

            HStack(spacing: CalnoraSpacing.small) {
                macroPill(value: avgs.protein, unit: "g", caption: "Protein", tint: CalnoraColors.protein)
                macroPill(value: avgs.carbs, unit: "g", caption: "Carbs", tint: CalnoraColors.carbs)
                macroPill(value: avgs.fat, unit: "g", caption: "Fat", tint: CalnoraColors.fat)
            }
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.calories)
        .accessibilityElement(children: .combine)
    }

    private func macroPill(value: Double, unit: String, caption: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(Int(value.rounded()), format: .number)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(tint)
                Text(unit)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Text(caption)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .padding(.horizontal, CalnoraSpacing.small)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.10), in: .rect(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Weekly calories card

    private var weeklyCaloriesCard: some View {
        let values = makeDailyValues(keyPath: \.calories)
        let target = nutritionGoalStore.targets.calories
        let safeMax = max(values.map(\.value).max() ?? 0, target, 1)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Calories")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Text("Compared with your target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label("\(Int(target.rounded()))", systemImage: "target")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }

            EZAnimatedChart(animation: .smooth, reveal: .horizontal, replayToken: values.count) { progress in
                ForEach(values) { sample in
                    AreaMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.value, progress: progress))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [CalnoraColors.calories.opacity(0.32), CalnoraColors.calories.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.value, progress: progress))
                    )
                    .foregroundStyle(CalnoraColors.calories.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.value, progress: progress))
                    )
                    .symbolSize(calendar.isDateInToday(sample.date) ? 90 : 30)
                    .foregroundStyle(calendar.isDateInToday(sample.date) ? AnyShapeStyle(CalnoraColors.calories) : AnyShapeStyle(CalnoraColors.calories.opacity(0.5)))
                }
                RuleMark(y: .value("Target", target))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
            .ezChartYScale(for: values.map(\.value) + [target], fallback: 0...max(safeMax, 1))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(.secondary.opacity(0.12))
                    AxisValueLabel().font(.system(.caption2, design: .rounded))
                }
            }
            .frame(height: 180)
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.calories)
    }

    // MARK: - Macro balance

    private var macroBalanceCard: some View {
        let totals = NutritionCalculator.mealTotals(for: mealStore.snapshots(on: .now))
        let sectors = [
            MacroSector(name: "Protein", value: totals.protein, tint: CalnoraColors.protein),
            MacroSector(name: "Carbs", value: totals.carbs, tint: CalnoraColors.carbs),
            MacroSector(name: "Fat", value: totals.fat, tint: CalnoraColors.fat)
        ]
        let empty = sectors.allSatisfy { $0.value == 0 }

        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Macro Balance")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("Today's split")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if empty {
                Text("Log a meal to see today's macro balance.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, CalnoraSpacing.medium)
            } else {
                EZAnimatedSectorChart(sectors, id: \.name, value: \.value, replayToken: totals.calories) { sector in
                    sector.tint
                }
                .frame(height: 210)

                HStack(spacing: CalnoraSpacing.small) {
                    ForEach(sectors) { sector in
                        macroLegendChip(name: sector.name, value: sector.value, tint: sector.tint)
                    }
                }
            }
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard()
    }

    private func macroLegendChip(name: String, value: Double, tint: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tint.gradient)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(Int(value.rounded()), format: .number)
                        .font(.system(.footnote, design: .rounded, weight: .bold))
                        .monospacedDigit()
                    Text("g")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, CalnoraSpacing.small)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.10), in: .capsule)
    }

    // MARK: - Trend card

    private func trendCard(title: String, subtitle: String, samples: [WeeklyValueSample], tint: Color, unit: String) -> some View {
        let total = samples.map(\.value).reduce(0, +)
        let avg = samples.isEmpty ? 0 : total / Double(samples.count)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(Int(avg.rounded()), format: .number)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(tint)
                    Text("\(unit) avg")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, CalnoraSpacing.small)
                .padding(.vertical, 4)
                .background(tint.opacity(0.14), in: .capsule)
            }

            EZAnimatedChart(animation: .smooth, reveal: .horizontal, replayToken: title) { progress in
                ForEach(samples) { sample in
                    BarMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Value", EZChartProgress.scaled(sample.value, progress: progress))
                    )
                    .foregroundStyle(barStyle(for: sample, tint: tint))
                    .cornerRadius(8)
                }
            }
            .ezChartYScale(for: samples.map(\.value), fallback: 0...1)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(.secondary.opacity(0.12))
                    AxisValueLabel().font(.system(.caption2, design: .rounded))
                }
            }
            .frame(height: 160)
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: tint)
    }

    private func barStyle(for sample: WeeklyValueSample, tint: Color) -> AnyShapeStyle {
        if calendar.isDateInToday(sample.date) {
            AnyShapeStyle(tint.gradient)
        } else {
            AnyShapeStyle(tint.opacity(0.6).gradient)
        }
    }

    // MARK: - Weight trend

    private var weightTrendCard: some View {
        let entries = Array(mealStore.weightEntries.prefix(14)).reversed()

        return VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weight Trend")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Text("Optional · stays local")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let latest = entries.last {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(latest.weight, format: .number.precision(.fractionLength(1)))
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(CalnoraColors.success)
                        Text("lb")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, CalnoraSpacing.small)
                    .padding(.vertical, 4)
                    .background(CalnoraColors.success.opacity(0.14), in: .capsule)
                }
            }

            if entries.count < 2 {
                Text("Log two or more weight entries to see your trend.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, CalnoraSpacing.medium)
            } else {
                Chart {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { _, entry in
                        AreaMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [CalnoraColors.success.opacity(0.32), CalnoraColors.success.opacity(0.04)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(CalnoraColors.success.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel().font(.system(.caption2, design: .rounded))
                    }
                }
                .frame(height: 140)
            }
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.success)
    }

    // MARK: - Meal timing

    private var mealTimingCard: some View {
        let samples = mealTimingSamples()
        let isEmpty = samples.allSatisfy { $0.count == 0 }

        return VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Meal Timing")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("How you log across the day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isEmpty {
                Text("Meal timing insights appear as you log breakfast, lunch, dinner, and snacks.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, CalnoraSpacing.medium)
            } else {
                EZAnimatedChart(animation: .smooth, reveal: .none, replayToken: samples.map(\.count).reduce(0, +)) { progress in
                    ForEach(samples) { sample in
                        BarMark(
                            x: .value("Meal", sample.mealType.title),
                            y: .value("Count", EZChartProgress.scaled(Double(sample.count), progress: progress))
                        )
                        .foregroundStyle(CalnoraColors.coach.gradient)
                        .cornerRadius(10)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine().foregroundStyle(.secondary.opacity(0.12))
                        AxisValueLabel().font(.system(.caption2, design: .rounded))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel().font(.system(.caption2, design: .rounded, weight: .semibold))
                    }
                }
                .frame(height: 170)
            }
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.coach)
    }

    // MARK: - Data helpers

    private func makeDailyValues(keyPath: KeyPath<MealNutrientSnapshot, Double>) -> [WeeklyValueSample] {
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
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return WeeklyValueSample(date: day, value: mealStore.totalWater(on: day))
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

    private var weeklyMacroAverages: (protein: Double, carbs: Double, fat: Double) {
        let snapshots = mealStore.snapshots()
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        let dailyValues = (0..<7).map { offset -> NutritionTotals in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return NutritionCalculator.dailyTotals(for: snapshots, on: day, calendar: calendar)
        }
        let total = dailyValues.reduce(NutritionTotals.zero) { partial, day in
            NutritionTotals(
                calories: partial.calories + day.calories,
                protein: partial.protein + day.protein,
                carbs: partial.carbs + day.carbs,
                fat: partial.fat + day.fat,
                fiber: partial.fiber + day.fiber,
                sugar: partial.sugar + day.sugar
            )
        }
        return (total.protein / 7, total.carbs / 7, total.fat / 7)
    }

    private func statusFor(progress: Double) -> String {
        if progress < 0.7 { return "Under" }
        if progress <= 1.05 { return "On track" }
        return "Over"
    }

    private func animateIn() {
        guard !hasAppeared else { return }
        withAnimation(.smooth(duration: 0.7)) {
            hasAppeared = true
        }
        withAnimation(.smooth(duration: 1.1).delay(0.25)) {
            barsRevealed = true
        }
    }
}

// MARK: - Sample models

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
    let container = PersistenceController.makeModelContainer(inMemory: true)
    return NavigationStack {
        InsightsView()
    }
    .environment(MealStore(context: container.mainContext))
    .environment(NutritionGoalStore(context: container.mainContext))
}
