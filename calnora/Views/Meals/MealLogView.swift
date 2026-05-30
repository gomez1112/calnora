import SwiftData
import SwiftUI

struct MealLogView: View {
    @Environment(AppRouter.self) private var router
    @Environment(MealStore.self) private var mealStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore
    let quotaManager: QuotaManager

    @State private var aiRemainingUses: Int?
    @State private var hasAppeared = false
    @State private var barsRevealed = false

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: CalnoraSpacing.large) {
                greetingHeader

                summaryHero
                    .stagger(0, hasAppeared: hasAppeared)

                quickActions
                    .stagger(1, hasAppeared: hasAppeared)

                todaysMealsSection
                    .stagger(2, hasAppeared: hasAppeared)

                hydrationCard
                    .stagger(3, hasAppeared: hasAppeared)

                favoritesSection
                    .stagger(4, hasAppeared: hasAppeared)
            }
            .calnoraScreenContent(maxWidth: CalnoraSpacing.readableMaxWidth)
        }
        .calnoraAmbientBackground()
        .scrollIndicators(.hidden)
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task {
            await refreshQuota()
        }
        .onAppear { animateIn() }
        .onChange(of: purchaseStore.entitlements) { _, _ in
            Task { await refreshQuota() }
        }
    }

    // MARK: - Header

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Logged")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.4)
                Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.semibold))
                Text(aiQuotaText)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(CalnoraColors.coach)
            .padding(.horizontal, CalnoraSpacing.small)
            .padding(.vertical, 6)
            .background(CalnoraColors.coach.opacity(0.14), in: .capsule)
            .accessibilityLabel("AI estimates: \(aiQuotaText)")
        }
        .padding(.horizontal, CalnoraSpacing.xSmall)
    }

    // MARK: - Summary hero

    private var summaryHero: some View {
        let meals = mealStore.meals(on: .now)
        let totalCal = meals.reduce(0) { $0 + $1.calories }
        let target = nutritionGoalStore.targets.calories
        let rawProgress = totalCal / max(target, 1)
        let displayProgress = min(max(rawProgress, 0), 1)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(meals.count == 1 ? "1 meal" : "\(meals.count) meals")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(Int(totalCal.rounded()), format: .number)
                            .contentTransition(.numericText(value: totalCal))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                        Text("kcal")
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
                    Text(statusText(progress: rawProgress))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(rawProgress > 1 ? .orange : CalnoraColors.calories)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(CalnoraColors.calories.opacity(0.14))
                    Capsule()
                        .fill(CalnoraColors.calories.gradient)
                        .frame(width: geo.size.width * (barsRevealed ? displayProgress : 0))
                        .shadow(color: CalnoraColors.calories.opacity(0.35), radius: 6, y: 2)
                }
            }
            .frame(height: 10)
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.calories)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Int(totalCal)) of \(Int(target)) kilocalories logged")
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            actionTile(
                title: "Manual",
                subtitle: "Type a meal in",
                symbol: "square.and.pencil",
                tint: CalnoraColors.protein
            ) {
                router.push(.mealEditor, in: .meals)
            }
            actionTile(
                title: "AI Estimate",
                subtitle: aiTileSubtitle,
                symbol: "sparkles",
                tint: CalnoraColors.coach
            ) {
                openAIParser()
            }
        }
    }

    private var aiTileSubtitle: String {
        purchaseStore.entitlements.unlocksPro ? "Unlimited" : aiQuotaText
    }

    private func actionTile(title: String, subtitle: String, symbol: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
                Image(systemName: symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.16), in: .circle)
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text(subtitle)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(CalnoraSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius, tint: tint, isInteractive: true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(subtitle)")
    }

    // MARK: - Today's meals

    private var todaysMealsSection: some View {
        let meals = mealStore.meals(on: .now)
        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Text("Today")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Spacer()
                if !meals.isEmpty {
                    Text("\(meals.count)")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(.secondary.opacity(0.12), in: .capsule)
                }
            }
            if meals.isEmpty {
                emptyMealsState
            } else {
                VStack(spacing: CalnoraSpacing.small) {
                    ForEach(meals) { meal in
                        mealCard(meal)
                    }
                }
            }
        }
    }

    private var emptyMealsState: some View {
        VStack(spacing: CalnoraSpacing.small) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(CalnoraColors.calories)
                .frame(width: 62, height: 62)
                .background(CalnoraColors.calories.opacity(0.14), in: .circle)
            Text("Nothing logged yet")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            Text("Manual logging is unlimited. AI estimates are approximate and editable.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .padding(CalnoraSpacing.large)
        .calnoraCard()
    }

    private func mealCard(_ meal: MealEntry) -> some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: meal.mealType.symbolName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CalnoraColors.calories)
                .frame(width: 38, height: 38)
                .background(CalnoraColors.calories.opacity(0.14), in: .circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(meal.name)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                    if meal.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(CalnoraColors.carbs)
                            .accessibilityHidden(true)
                    }
                }
                Text(meal.servingDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(meal.source.rawValue.capitalized)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .tracking(0.6)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 1) {
                Text(Int(meal.calories.rounded()), format: .number)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: meal.calories))
                Text("cal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, CalnoraSpacing.medium)
        .padding(.vertical, CalnoraSpacing.small + 2)
        .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius)
        .contentShape(.rect)
        .contextMenu {
            Button {
                mealStore.toggleFavorite(meal)
                notificationStore.show(
                    title: meal.isFavorite ? "Favorite removed" : "Favorite saved",
                    message: "Reusable meals stay local on this device.",
                    symbolName: "star.fill"
                )
            } label: {
                Label(meal.isFavorite ? "Unfavorite" : "Favorite", systemImage: "star.fill")
            }
            Button(role: .destructive) {
                mealStore.delete(meal)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(meal.name), \(Int(meal.calories)) calories. Long press for options.")
    }

    // MARK: - Hydration

    private var hydrationCard: some View {
        let total = mealStore.totalWater(on: .now)
        let target = nutritionGoalStore.targets.water
        let progress = min(total / max(target, 1), 1)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text("Hydration")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                } icon: {
                    Image(systemName: "drop.fill")
                        .font(.subheadline)
                        .foregroundStyle(CalnoraColors.water)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text(Int(total.rounded()), format: .number)
                        .contentTransition(.numericText(value: total))
                    Text("/ \(Int(target.rounded())) oz")
                        .foregroundStyle(.secondary)
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(CalnoraColors.water.opacity(0.14))
                    Capsule()
                        .fill(CalnoraColors.water.gradient)
                        .frame(width: geo.size.width * (barsRevealed ? progress : 0))
                }
            }
            .frame(height: 8)

            HStack(spacing: CalnoraSpacing.small) {
                waterButton(amount: 8)
                waterButton(amount: 16)
                waterButton(amount: 24)
            }
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.water)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hydration \(Int(total)) of \(Int(target)) ounces")
    }

    private func waterButton(amount: Double) -> some View {
        Button {
            mealStore.saveWater(amount: amount)
            notificationStore.show(
                title: "Water logged",
                message: "\(Int(amount)) oz added to today.",
                symbolName: "drop.fill"
            )
        } label: {
            Text("+\(Int(amount)) oz")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .foregroundStyle(CalnoraColors.water)
                .background(CalnoraColors.water.opacity(0.16), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(Int(amount)) ounces of water")
    }

    // MARK: - Favorites

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Text("Favorites")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Spacer()
                if !mealStore.favorites.isEmpty {
                    Text("Tap to log as lunch")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }
            if mealStore.favorites.isEmpty {
                Text("Reusable meal templates will appear here when you star a meal.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(CalnoraSpacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .calnoraCard()
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: CalnoraSpacing.medium),
                        GridItem(.flexible())
                    ],
                    spacing: CalnoraSpacing.medium
                ) {
                    ForEach(mealStore.favorites) { favorite in
                        favoriteTile(favorite)
                    }
                }
            }
        }
    }

    private func favoriteTile(_ favorite: FavoriteMeal) -> some View {
        Button {
            mealStore.logFavorite(favorite)
            notificationStore.mealSaved()
        } label: {
            VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
                Image(systemName: "star.fill")
                    .font(.subheadline)
                    .foregroundStyle(CalnoraColors.carbs)
                    .frame(width: 30, height: 30)
                    .background(CalnoraColors.carbs.opacity(0.16), in: .circle)
                Text(favorite.name)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(Int(favorite.totalCalories.rounded()), format: .number)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .monospacedDigit()
                    Text("cal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(CalnoraSpacing.medium)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius, tint: CalnoraColors.carbs)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Log favorite \(favorite.name), \(Int(favorite.totalCalories)) calories")
    }

    // MARK: - Helpers

    private var aiQuotaText: String {
        if purchaseStore.entitlements.unlocksPro {
            "Unlimited"
        } else if let aiRemainingUses {
            "\(aiRemainingUses) left this week"
        } else {
            "Loading"
        }
    }

    private func statusText(progress: Double) -> String {
        if progress < 0.7 { return "Room" }
        if progress <= 1.05 { return "On track" }
        return "Over"
    }

    private func openAIParser() {
        if purchaseStore.entitlements.unlocksPro || (aiRemainingUses ?? 1) > 0 {
            router.push(.aiMealParse, in: .meals)
        } else {
            notificationStore.quotaLimitReached()
            router.push(.paywall, in: .meals)
        }
    }

    private func refreshQuota() async {
        aiRemainingUses = await quotaManager.remainingUses(
            for: .aiMealParse,
            entitlements: purchaseStore.entitlements
        )
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

#Preview {
    let container = PersistenceController.makeModelContainer(inMemory: true)
    return NavigationStack {
        MealLogView(quotaManager: QuotaManager())
    }
    .environment(AppRouter())
    .environment(MealStore(context: container.mainContext))
    .environment(NutritionGoalStore(context: container.mainContext))
    .environment(PurchaseStore())
    .environment(NotificationStore())
}
