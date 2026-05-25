import SwiftData
import SwiftUI

struct MealLogView: View {
    @Environment(AppRouter.self) private var router
    @Environment(MealStore.self) private var mealStore
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore
    let quotaManager: QuotaManager
    @State private var aiRemainingUses: Int?

    var body: some View {
        List {
            Section {
                Button("Add Manual Meal", systemImage: "plus.circle.fill") {
                    router.push(.mealEditor, in: .meals)
                }
                Button("Use AI Meal Estimate", systemImage: "sparkles") {
                    openAIParser()
                }
                LabeledContent("AI estimates this week", value: aiQuotaText)
                    .foregroundStyle(.secondary)
            }

            Section("Today") {
                let meals = mealStore.meals(on: .now)
                if meals.isEmpty {
                    CalnoraEmptyState(
                        title: "No meals yet",
                        message: "Manual logging is unlimited. AI estimates are approximate and editable.",
                        systemImage: "fork.knife.circle",
                        tint: CalnoraColors.calories
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(meals) { meal in
                        MealRow(meal: meal)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    mealStore.delete(meal)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    mealStore.toggleFavorite(meal)
                                    notificationStore.show(
                                        title: meal.isFavorite ? "Favorite saved" : "Favorite removed",
                                        message: "Reusable meals stay local on this device.",
                                        symbolName: "star.fill"
                                    )
                                } label: {
                                    Label(meal.isFavorite ? "Unfavorite" : "Favorite", systemImage: "star.fill")
                                }
                                .tint(CalnoraColors.carbs)
                            }
                    }
                }
            }

            Section("Water") {
                LabeledContent("Today") {
                    HStack(spacing: 2) {
                        Text(mealStore.totalWater(on: .now), format: .number.precision(.fractionLength(0)))
                        Text("oz")
                    }
                }
                HStack(spacing: CalnoraSpacing.small) {
                    waterButton(amount: 8)
                    waterButton(amount: 16)
                    waterButton(amount: 24)
                }
            }

            Section("Recent Foods") {
                ForEach(mealStore.foodItems.prefix(6)) { item in
                    Button {
                        mealStore.save(MealEntry(
                            mealType: .snack,
                            name: item.name,
                            servingDescription: item.servingDescription,
                            calories: item.caloriesPerServing,
                            protein: item.protein,
                            carbs: item.carbs,
                            fat: item.fat,
                            fiber: item.fiber,
                            sugar: item.sugar,
                            source: .seedFood
                        ))
                        notificationStore.mealSaved()
                    } label: {
                        FoodItemRow(item: item)
                    }
                }
            }

            Section("Favorites") {
                if mealStore.favorites.isEmpty {
                    Text("Reusable meal templates will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(mealStore.favorites) { favorite in
                        Button {
                            mealStore.logFavorite(favorite)
                            notificationStore.mealSaved()
                        } label: {
                            FavoriteMealRow(favorite: favorite)
                        }
                    }
                }
            }
        }
        .navigationTitle("Meals")
        .task {
            await refreshQuota()
        }
        .onChange(of: purchaseStore.entitlements) { _, _ in
            Task { await refreshQuota() }
        }
    }

    private var aiQuotaText: String {
        if purchaseStore.entitlements.unlocksPro {
            "Unlimited"
        } else if let aiRemainingUses {
            "\(aiRemainingUses) remaining"
        } else {
            "Loading"
        }
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
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
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
}

private struct MealRow: View {
    var meal: MealEntry

    var body: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: meal.mealType.symbolName)
                .foregroundStyle(CalnoraColors.calories)
                .frame(width: 34, height: 34)
                .background(CalnoraColors.calories.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(meal.name)
                    .font(.headline)
                Text(meal.servingDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(meal.source.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Text(meal.calories, format: .number.precision(.fractionLength(0)))
                .font(.headline.monospacedDigit())
        }
        .accessibilityElement(children: .combine)
    }
}

private struct FavoriteMealRow: View {
    var favorite: FavoriteMeal

    var body: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: "star.fill")
                .foregroundStyle(CalnoraColors.carbs)
                .frame(width: 34, height: 34)
                .background(CalnoraColors.carbs.opacity(0.14), in: .circle)
            VStack(alignment: .leading, spacing: 3) {
                Text(favorite.name)
                    .font(.headline)
                Text("Tap to log as lunch")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(favorite.totalCalories, format: .number.precision(.fractionLength(0)))
                .font(.subheadline.monospacedDigit())
        }
        .accessibilityElement(children: .combine)
    }
}

private struct FoodItemRow: View {
    var item: FoodItem

    var body: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(CalnoraColors.success)
                .frame(width: 34, height: 34)
                .background(CalnoraColors.success.opacity(0.12), in: .circle)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.headline)
                Text(item.servingDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.caloriesPerServing, format: .number.precision(.fractionLength(0)))
                .font(.subheadline.monospacedDigit())
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MealLogView(quotaManager: QuotaManager())
        .environment(AppRouter())
        .environment(MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(PurchaseStore())
        .environment(NotificationStore())
}
