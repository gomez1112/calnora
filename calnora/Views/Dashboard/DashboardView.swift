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
    @State private var hasAppeared = false
    @State private var ringProgress: Double = 0
    @State private var barsRevealed = false

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: CalnoraSpacing.large) {
                greetingHeader

                heroRing
                    .stagger(0, hasAppeared: hasAppeared)

                macroLines
                    .stagger(1, hasAppeared: hasAppeared)

                coachWhisper
                    .stagger(2, hasAppeared: hasAppeared)

                mealRibbon
                    .stagger(3, hasAppeared: hasAppeared)

                wellnessRow
                    .stagger(4, hasAppeared: hasAppeared)

                if !purchaseStore.entitlements.unlocksPro {
                    proPass
                        .stagger(5, hasAppeared: hasAppeared)
                }
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
        .task {
            model.update(mealStore: mealStore, nutritionGoalStore: nutritionGoalStore)
            await coachStore.refreshDailyInsight()
            animateRingToTarget()
        }
        .onAppear { animateIn() }
        .onChange(of: mealStore.meals.count) { _, _ in
            model.update(mealStore: mealStore, nutritionGoalStore: nutritionGoalStore)
            animateRingToTarget()
        }
        .onChange(of: mealStore.waterEntries.count) { _, _ in
            model.update(mealStore: mealStore, nutritionGoalStore: nutritionGoalStore)
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        HStack(alignment: .center, spacing: CalnoraSpacing.small) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingPhrase)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.4)
                Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
            Spacer()
            toolbarButton(symbol: "sparkles", tint: CalnoraColors.coach, accessibilityLabel: "Open Coach") {
                router.push(.coach, in: .dashboard)
            }
            toolbarButton(symbol: "gearshape.fill", tint: CalnoraColors.fat, accessibilityLabel: "Open Settings") {
                router.push(.settings, in: .dashboard)
            }
            toolbarButton(symbol: "person.crop.circle.fill", tint: CalnoraColors.protein, accessibilityLabel: "Profile and goals") {
                router.push(.profile, in: .dashboard)
            }
        }
        .padding(.horizontal, CalnoraSpacing.xSmall)
    }

    private func toolbarButton(symbol: String, tint: Color, accessibilityLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.14), in: .circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Hero ring

    private var heroRing: some View {
        let remaining = max(model.target.calories - model.dailyTotals.calories, 0)
        let consumed = Int(model.dailyTotals.calories.rounded())
        let target = Int(model.target.calories.rounded())
        let progress = targetProgress

        return VStack(spacing: CalnoraSpacing.large) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [CalnoraColors.calories.opacity(0.32), .clear],
                            center: .center,
                            startRadius: 8,
                            endRadius: 160
                        )
                    )
                    .blur(radius: 24)
                    .scaleEffect(hasAppeared ? 1.05 : 0.5)
                    .opacity(hasAppeared ? 1 : 0)

                Circle()
                    .stroke(CalnoraColors.calories.opacity(0.12), lineWidth: 20)

                Circle()
                    .trim(from: 0, to: min(max(ringProgress, 0), 1))
                    .stroke(
                        AngularGradient(
                            colors: [
                                CalnoraColors.calories.opacity(0.55),
                                CalnoraColors.calories,
                                Color.orange,
                                CalnoraColors.calories.opacity(0.55)
                            ],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: CalnoraColors.calories.opacity(0.35), radius: 12, x: 0, y: 4)

                VStack(spacing: 6) {
                    Text(Int(remaining.rounded()), format: .number)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: remaining))
                        .foregroundStyle(.primary)
                    Text("kcal left")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .animation(.smooth(duration: 0.6), value: remaining)
            }
            .frame(width: 250, height: 250)

            HStack(spacing: CalnoraSpacing.large) {
                statColumn(value: "\(consumed)", caption: "Eaten")
                divider
                statColumn(value: "\(target)", caption: "Goal")
                divider
                statColumn(value: statusText(progress: progress), caption: "Status")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CalnoraSpacing.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Int(remaining.rounded())) kilocalories left of \(target)")
    }

    private var divider: some View {
        Circle()
            .fill(.secondary.opacity(0.35))
            .frame(width: 4, height: 4)
    }

    private func statColumn(value: String, caption: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .monospacedDigit()
            Text(caption)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
        }
    }

    // MARK: - Macro lines

    private var macroLines: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            macroLine(title: "Protein", value: model.dailyTotals.protein, target: model.target.protein, tint: CalnoraColors.protein, symbol: "bolt.fill")
            macroLine(title: "Carbs", value: model.dailyTotals.carbs, target: model.target.carbs, tint: CalnoraColors.carbs, symbol: "leaf.fill")
            macroLine(title: "Fat", value: model.dailyTotals.fat, target: model.target.fat, tint: CalnoraColors.fat, symbol: "drop.fill")
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard()
    }

    private func macroLine(title: String, value: Double, target: Double, tint: Color, symbol: String) -> some View {
        let progress = min(max(value / max(target, 1), 0), 1)
        return HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: symbol)
                .font(.subheadline)
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.14), in: .circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    Spacer()
                    HStack(spacing: 4) {
                        Text(Int(value.rounded()), format: .number)
                            .contentTransition(.numericText(value: value))
                            .foregroundStyle(.primary)
                        Text("/ \(Int(target.rounded())) g")
                            .foregroundStyle(.secondary)
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .monospacedDigit()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(tint.opacity(0.14))
                        Capsule()
                            .fill(tint.gradient)
                            .frame(width: geo.size.width * (barsRevealed ? progress : 0))
                    }
                }
                .frame(height: 8)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(Int(value)) of \(Int(target)) grams")
    }

    // MARK: - Coach whisper

    private var coachWhisper: some View {
        let insight = coachStore.latestInsight
        return Button {
            router.push(.coach, in: .dashboard)
        } label: {
            HStack(alignment: .top, spacing: CalnoraSpacing.medium) {
                ZStack {
                    Circle()
                        .fill(CalnoraColors.coach.opacity(0.16))
                        .frame(width: 40, height: 40)
                    Image(systemName: "sparkles")
                        .font(.system(.headline, weight: .semibold))
                        .foregroundStyle(CalnoraColors.coach.gradient)
                        .symbolEffect(.pulse, options: .repeating, isActive: hasAppeared)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(insight?.title ?? "Today's Coach Note")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.leading)
                    Text(insight?.message ?? "Keep logging with curiosity. Estimates are approximate and editable.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(CalnoraSpacing.medium)
            .calnoraCard(tint: CalnoraColors.coach, isInteractive: true)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the coach")
    }

    // MARK: - Meal ribbon

    private var mealRibbon: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Text("Meals")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Spacer()
                Button {
                    router.push(.mealEditor, in: .dashboard)
                } label: {
                    Label("Log", systemImage: "plus")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .padding(.horizontal, CalnoraSpacing.medium)
                        .padding(.vertical, 8)
                        .foregroundStyle(CalnoraColors.calories)
                        .background(CalnoraColors.calories.opacity(0.16), in: .capsule)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Log meal")
            }
            VStack(spacing: CalnoraSpacing.small) {
                ForEach(MealType.allCases) { type in
                    mealStripRow(for: type)
                }
            }
        }
    }

    private func mealStripRow(for type: MealType) -> some View {
        let meals = mealStore.meals(on: .now).filter { $0.mealType == type }
        let totalCal = meals.reduce(0) { $0 + $1.calories }
        let isEmpty = meals.isEmpty
        let accent: Color = isEmpty ? .secondary : CalnoraColors.calories

        return HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: type.symbolName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(accent)
                .frame(width: 36, height: 36)
                .background(accent.opacity(0.14), in: .circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(type.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                if isEmpty {
                    Text("Tap to log")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(meals.map(\.name).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            if !isEmpty {
                Text("\(Int(totalCal.rounded())) cal")
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText(value: totalCal))
            }
        }
        .padding(.horizontal, CalnoraSpacing.medium)
        .padding(.vertical, CalnoraSpacing.small + 2)
        .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius)
        .contentShape(.rect)
        .onTapGesture {
            router.push(.mealEditor, in: .dashboard)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(isEmpty ? "Tap to log \(type.title)" : "Edit meals")
    }

    // MARK: - Wellness row

    private var wellnessRow: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            wellnessPill(
                title: "Water",
                value: Int(model.water.rounded()),
                doubleValue: model.water,
                unit: "oz",
                progress: min(model.water / max(model.target.water, 1), 1),
                tint: CalnoraColors.water,
                symbol: "drop.fill"
            )
            wellnessPill(
                title: "Streak",
                value: model.streak,
                doubleValue: Double(model.streak),
                unit: model.streak == 1 ? "day" : "days",
                progress: min(Double(model.streak) / 7.0, 1),
                tint: .orange,
                symbol: "flame.fill"
            )
        }
    }

    private func wellnessPill(title: String, value: Int, doubleValue: Double, unit: String, progress: Double, tint: Color, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack {
                Image(systemName: symbol)
                    .font(.subheadline)
                    .foregroundStyle(tint)
                    .frame(width: 30, height: 30)
                    .background(tint.opacity(0.16), in: .circle)
                Spacer()
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value, format: .number)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: doubleValue))
                Text(unit)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(tint.opacity(0.16))
                    Capsule()
                        .fill(tint.gradient)
                        .frame(width: geo.size.width * (barsRevealed ? progress : 0))
                }
            }
            .frame(height: 6)
        }
        .padding(CalnoraSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius, tint: tint)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value) \(unit)")
    }

    // MARK: - Pro pass

    private var proPass: some View {
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

    // MARK: - Helpers

    private var targetProgress: Double {
        min(model.dailyTotals.calories / max(model.target.calories, 1), 1.2)
    }

    private var greetingPhrase: String {
        let hour = calendar.component(.hour, from: Date.now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Tonight"
        }
    }

    private func statusText(progress: Double) -> String {
        if progress < 0.7 { return "Room" }
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

    private func animateRingToTarget() {
        withAnimation(.spring(duration: 1.3, bounce: 0.18)) {
            ringProgress = targetProgress
        }
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
