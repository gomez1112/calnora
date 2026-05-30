import Charts
import EZCharts
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(MealStore.self) private var mealStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @State private var hasAppeared = false
    @State private var barsRevealed = false

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: CalnoraSpacing.large) {
                greetingHeader

                summaryHero
                    .stagger(0, hasAppeared: hasAppeared)

                trendCard
                    .stagger(1, hasAppeared: hasAppeared)

                dailyBreakdown
                    .stagger(2, hasAppeared: hasAppeared)

                recentMealsSection
                    .stagger(3, hasAppeared: hasAppeared)

                weightCard
                    .stagger(4, hasAppeared: hasAppeared)
            }
            .padding(.horizontal, CalnoraSpacing.medium)
            .padding(.top, CalnoraSpacing.medium)
            .padding(.bottom, CalnoraSpacing.xLarge)
        }
        .calnoraAmbientBackground()
        .scrollIndicators(.hidden)
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .onAppear { animateIn() }
    }

    // MARK: - Derived data

    private var weeklySamples: [WeeklyCalorieSample] {
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        let snapshots = mealStore.snapshots()
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
            return WeeklyCalorieSample(
                date: day,
                calories: NutritionCalculator.dailyTotals(for: snapshots, on: day, calendar: calendar).calories
            )
        }
    }

    private var dailySummaries: [DailyNutritionSummary] {
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

    private var averageCalories: Double {
        let samples = weeklySamples
        guard !samples.isEmpty else { return 0 }
        return samples.map(\.calories).reduce(0, +) / Double(samples.count)
    }

    private var totalMealsLogged: Int {
        dailySummaries.reduce(0) { $0 + $1.mealCount }
    }

    private var onTrackDays: Int {
        let target = nutritionGoalStore.targets.calories
        return dailySummaries.filter {
            let p = $0.totals.calories / max(target, 1)
            return p >= 0.7 && p <= 1.05
        }.count
    }

    // MARK: - Header

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("History")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.4)
                Text("Last 7 days")
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                Text(rangeLabel)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(CalnoraColors.coach)
            .padding(.horizontal, CalnoraSpacing.small)
            .padding(.vertical, 6)
            .background(CalnoraColors.coach.opacity(0.14), in: .capsule)
        }
        .padding(.horizontal, CalnoraSpacing.xSmall)
    }

    private var rangeLabel: String {
        let end = Date.now
        guard let start = calendar.date(byAdding: .day, value: -6, to: end) else { return "" }
        let style = Date.FormatStyle().month(.abbreviated).day()
        return "\(start.formatted(style)) – \(end.formatted(style))"
    }

    // MARK: - Summary hero

    private var summaryHero: some View {
        let target = nutritionGoalStore.targets.calories
        let avg = averageCalories
        let progress = min(max(avg / max(target, 1), 0), 1)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This week")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(Int(avg.rounded()), format: .number)
                            .contentTransition(.numericText(value: avg))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("kcal/day avg")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("of \(Int(target.rounded()))")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                    Text("Goal")
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.8)
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

            HStack(spacing: CalnoraSpacing.medium) {
                statPill(value: "\(onTrackDays)", caption: "On-track", tint: CalnoraColors.success)
                statPill(value: "\(totalMealsLogged)", caption: "Meals", tint: CalnoraColors.protein)
                statPill(value: "\(Int(totalWater.rounded())) oz", caption: "Water", tint: CalnoraColors.water)
            }
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.calories)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Average \(Int(avg)) kilocalories per day, \(onTrackDays) on-track days, \(totalMealsLogged) meals logged.")
    }

    private var totalWater: Double {
        dailySummaries.reduce(0) { $0 + $1.water }
    }

    private func statPill(value: String, caption: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(tint)
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

    // MARK: - Trend chart

    private var trendCard: some View {
        let samples = weeklySamples
        let target = nutritionGoalStore.targets.calories
        let safeMax = max(samples.map(\.calories).max() ?? 0, target, 1)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(alignment: .firstTextBaseline) {
                Text("Calorie trend")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Label("Target \(Int(target.rounded()))", systemImage: "target")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }

            EZAnimatedChart(animation: .smooth, reveal: .horizontal, replayToken: samples.count) { progress in
                ForEach(samples) { sample in
                    AreaMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.calories, progress: progress))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [CalnoraColors.calories.opacity(0.35), CalnoraColors.calories.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.calories, progress: progress))
                    )
                    .foregroundStyle(CalnoraColors.calories.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.calories, progress: progress))
                    )
                    .symbolSize(calendar.isDateInToday(sample.date) ? 90 : 36)
                    .foregroundStyle(calendar.isDateInToday(sample.date) ? AnyShapeStyle(CalnoraColors.calories) : AnyShapeStyle(CalnoraColors.calories.opacity(0.65)))
                }

                RuleMark(y: .value("Target", target))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
            .ezChartYScale(for: samples.map(\.calories), fallback: 0...max(safeMax, 1))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine().foregroundStyle(.secondary.opacity(0.12))
                    AxisValueLabel()
                        .font(.system(.caption2, design: .rounded))
                }
            }
            .frame(height: 180)
            .accessibilityLabel("Weekly calorie trend")
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard()
    }

    // MARK: - Daily breakdown

    private var dailyBreakdown: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            Text("Daily breakdown")
                .font(.system(.title3, design: .rounded, weight: .bold))

            VStack(spacing: CalnoraSpacing.small) {
                ForEach(dailySummaries) { summary in
                    dailyRow(summary)
                }
            }
        }
    }

    private func dailyRow(_ summary: DailyNutritionSummary) -> some View {
        let target = nutritionGoalStore.targets.calories
        let rawProgress = summary.totals.calories / max(target, 1)
        let progress = min(max(rawProgress, 0), 1)
        let isToday = calendar.isDateInToday(summary.date)
        let status = statusFor(progress: rawProgress, mealCount: summary.mealCount)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(spacing: CalnoraSpacing.small) {
                ZStack {
                    Circle()
                        .fill((isToday ? CalnoraColors.calories : Color.secondary).opacity(0.14))
                        .frame(width: 36, height: 36)
                    Text(summary.date, format: .dateTime.day())
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(isToday ? CalnoraColors.calories : .secondary)
                        .monospacedDigit()
                }
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(summary.date, format: .dateTime.weekday(.wide))
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        if isToday {
                            Text("Today")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(CalnoraColors.calories)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(CalnoraColors.calories.opacity(0.14), in: .capsule)
                        }
                    }
                    Text("\(summary.mealCount) \(summary.mealCount == 1 ? "meal" : "meals") · \(Int(summary.water.rounded())) oz")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(Int(summary.totals.calories.rounded()), format: .number)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .monospacedDigit()
                        Text("cal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Text(status.label)
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(status.tint)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(CalnoraColors.calories.opacity(0.10))
                    Capsule()
                        .fill(status.tint.gradient)
                        .frame(width: geo.size.width * (barsRevealed ? progress : 0))
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, CalnoraSpacing.medium)
        .padding(.vertical, CalnoraSpacing.small + 2)
        .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius, tint: isToday ? CalnoraColors.calories : nil)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(summary.date.formatted(.dateTime.weekday(.wide))), \(Int(summary.totals.calories)) calories, \(summary.mealCount) meals.")
    }

    private func statusFor(progress: Double, mealCount: Int) -> (label: String, tint: Color) {
        guard mealCount > 0 else { return ("Untracked", .secondary) }
        if progress < 0.7 { return ("Under", CalnoraColors.coach) }
        if progress <= 1.05 { return ("On track", CalnoraColors.success) }
        return ("Over", .orange)
    }

    // MARK: - Recent meals

    private var recentMealsSection: some View {
        let recent = Array(mealStore.meals.prefix(8))
        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent meals")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Spacer()
                if !recent.isEmpty {
                    Text("\(mealStore.meals.count) total")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                }
            }
            if recent.isEmpty {
                Text("Logged meals will appear here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(CalnoraSpacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .calnoraCard()
            } else {
                VStack(spacing: CalnoraSpacing.small) {
                    ForEach(recent) { meal in
                        mealRow(meal)
                    }
                }
            }
        }
    }

    private func mealRow(_ meal: MealEntry) -> some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: meal.mealType.symbolName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CalnoraColors.calories)
                .frame(width: 36, height: 36)
                .background(CalnoraColors.calories.opacity(0.14), in: .circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                Text(meal.date, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 1) {
                Text(Int(meal.calories.rounded()), format: .number)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .monospacedDigit()
                Text("\(Int(meal.protein.rounded()))g protein")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, CalnoraSpacing.medium)
        .padding(.vertical, CalnoraSpacing.small + 2)
        .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Weight

    private var weightCard: some View {
        let entries = mealStore.weightEntries
        let latest = entries.first
        let trendEntries = Array(entries.prefix(14)).reversed()

        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .center) {
                Label {
                    Text("Weight")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                } icon: {
                    Image(systemName: "scalemass.fill")
                        .font(.subheadline)
                        .foregroundStyle(CalnoraColors.fat)
                }
                Spacer()
                if let latest {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(latest.weight, format: .number.precision(.fractionLength(1)))
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                        Text("lb")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let latest {
                Text(latest.date, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                if trendEntries.count >= 2 {
                    Chart {
                        ForEach(Array(trendEntries.enumerated()), id: \.element.id) { _, entry in
                            LineMark(
                                x: .value("Date", entry.date, unit: .day),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(CalnoraColors.fat.gradient)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))

                            AreaMark(
                                x: .value("Date", entry.date, unit: .day),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [CalnoraColors.fat.opacity(0.32), CalnoraColors.fat.opacity(0.04)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 60)
                }
            } else {
                Text("Weight entries are optional and stay local.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.fat)
    }

    // MARK: - Animations

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

// MARK: - Daily summary model

private struct DailyNutritionSummary: Identifiable {
    var id: Date { date }
    var date: Date
    var totals: NutritionTotals
    var water: Double
    var mealCount: Int
}

#Preview {
    let container = PersistenceController.makeModelContainer(inMemory: true)
    return NavigationStack {
        HistoryView()
    }
    .environment(MealStore(context: container.mainContext))
    .environment(NutritionGoalStore(context: container.mainContext))
}
