import Charts
import EZCharts
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router
    @Environment(MealStore.self) private var mealStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @Environment(CoachStore.self) private var coachStore
    @Environment(PurchaseStore.self) private var purchaseStore
    @State private var model = DashboardModel()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: CalnoraSpacing.large) {
                header
                calorieCard
                macroRow
                coachCard
                mealTimeline
                if !purchaseStore.entitlements.unlocksPro {
                    WalletPassCard(
                        title: "Calnora Pro",
                        subtitle: "Unlimited private AI coaching",
                        systemImage: "sparkles",
                        footnote: "No fake urgency. Just more room for insight.",
                        actionTitle: "Upgrade"
                    ) {
                        router.push(.paywall, in: .dashboard)
                    }
                }
                weeklyTrend
                supportCards
            }
            .padding()
        }
        .background(CalnoraColors.groupedBackground)
        .navigationTitle("Today")
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task {
            model.update(mealStore: mealStore, nutritionGoalStore: nutritionGoalStore)
            await coachStore.refreshDailyInsight()
        }
        .onChange(of: mealStore.meals.count) { _, _ in
            model.update(mealStore: mealStore, nutritionGoalStore: nutritionGoalStore)
        }
        .onChange(of: mealStore.waterEntries.count) { _, _ in
            model.update(mealStore: mealStore, nutritionGoalStore: nutritionGoalStore)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.largeTitle.bold())
                Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                router.push(.profile, in: .dashboard)
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Profile and goals")
        }
    }

    private var calorieCard: some View {
        let remaining = model.target.calories - model.dailyTotals.calories
        return HStack(spacing: CalnoraSpacing.large) {
            VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
                Text("Calories remaining")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(max(remaining, 0), format: .number.precision(.fractionLength(0)))
                    .font(CalnoraTypography.largeNumber)
                    .monospacedDigit()
                Text("\(Int(model.dailyTotals.calories)) consumed of \(Int(model.target.calories)) target")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(statusText(remaining: remaining))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(CalnoraColors.calories)
            }
            Spacer()
            ProgressRingView(
                progress: model.dailyTotals.calories / max(model.target.calories, 1),
                tint: CalnoraColors.calories
            )
            .frame(width: 104, height: 104)
        }
        .calnoraCard(tint: CalnoraColors.calories)
        .accessibilityElement(children: .combine)
    }

    private var macroRow: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            HealthMetricCard(title: "Protein", value: model.dailyTotals.protein, target: model.target.protein, unit: "g", symbolName: "bolt.fill", tint: CalnoraColors.protein)
            HealthMetricCard(title: "Carbs", value: model.dailyTotals.carbs, target: model.target.carbs, unit: "g", symbolName: "leaf.fill", tint: CalnoraColors.carbs)
            HealthMetricCard(title: "Fat", value: model.dailyTotals.fat, target: model.target.fat, unit: "g", symbolName: "drop.fill", tint: CalnoraColors.fat)
        }
    }

    private var coachCard: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(
                title: coachStore.latestInsight?.title ?? "Today's Coach Note",
                subtitle: CoachEngineAvailability.userFacingStatus
            )
            Text(coachStore.latestInsight?.message ?? "Keep logging with curiosity. Estimates are approximate and editable.")
                .font(.body)
                .foregroundStyle(.primary)
            Button("Ask Coach", systemImage: "sparkles") {
                appState.selectedTab = .coach
            }
            .buttonStyle(.borderedProminent)
            .tint(CalnoraColors.coach)
        }
        .calnoraCard(tint: CalnoraColors.coach, isInteractive: true)
    }

    private var mealTimeline: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Today's Meals", subtitle: "Editable timeline")
            ForEach(MealType.allCases) { type in
                let meals = mealStore.meals(on: .now).filter { $0.mealType == type }
                HStack(alignment: .top, spacing: CalnoraSpacing.medium) {
                    Image(systemName: type.symbolName)
                        .foregroundStyle(CalnoraColors.calories)
                        .frame(width: 32, height: 32)
                        .background(CalnoraColors.calories.opacity(0.12), in: .circle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.title)
                            .font(.headline)
                        if meals.isEmpty {
                            Text("No meal logged yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(meals) { meal in
                                Text("\(meal.name) - \(Int(meal.calories)) cal")
                                    .font(.subheadline)
                            }
                        }
                    }
                    Spacer()
                }
            }
            Button("Add Meal", systemImage: "plus") {
                router.push(.mealEditor, in: .dashboard)
            }
            .buttonStyle(.borderedProminent)
        }
        .calnoraCard()
    }

    private var weeklyTrend: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Weekly Calories", subtitle: "Approximate daily totals")
            EZAnimatedChart(animation: .smooth, reveal: .horizontal, replayToken: model.weeklySamples.count) { progress in
                ForEach(model.weeklySamples) { sample in
                    BarMark(
                        x: .value("Day", sample.date, unit: .day),
                        y: .value("Calories", EZChartProgress.scaled(sample.calories, progress: progress))
                    )
                    .foregroundStyle(CalnoraColors.calories.gradient)
                    .cornerRadius(8)
                }
                RuleMark(y: .value("Target", model.target.calories))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
            }
            .ezChartYScale(for: model.weeklySamples.map(\.calories), fallback: 0...max(model.target.calories, 1))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .frame(height: 180)
            .accessibilityLabel("Weekly calorie trend")
        }
        .calnoraCard()
    }

    private var supportCards: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            HealthMetricCard(title: "Water", value: model.water, target: model.target.water, unit: "oz", symbolName: "drop.fill", tint: CalnoraColors.water)
            HealthMetricCard(title: "Streak", value: Double(model.streak), target: nil, unit: "days", symbolName: "flame.fill", tint: CalnoraColors.carbs)
        }
    }

    private func statusText(remaining: Double) -> String {
        if remaining > 500 { return "Room for dinner" }
        if remaining >= 0 { return "On track" }
        return "A little over"
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
        .environment(AppRouter())
        .environment(MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(CoachStore(engine: MockCoachEngine(), mealStore: MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext), nutritionGoalStore: NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext)))
        .environment(PurchaseStore())
}
