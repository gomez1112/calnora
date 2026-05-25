import SwiftData
import SwiftUI

struct MealLogView: View {
    @Environment(AppRouter.self) private var router
    @Environment(MealStore.self) private var mealStore
    let quotaManager: QuotaManager

    var body: some View {
        List {
            Section {
                Button("Add Manual Meal", systemImage: "plus.circle.fill") {
                    router.push(.mealEditor, in: .meals)
                }
                Button("Use AI Meal Estimate", systemImage: "sparkles") {
                    router.push(.aiMealParse, in: .meals)
                }
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
                    }
                }
            }

            Section("Favorites") {
                if mealStore.favorites.isEmpty {
                    Text("Reusable meal templates will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(mealStore.favorites) { favorite in
                        Label(favorite.name, systemImage: "star.fill")
                    }
                }
            }
        }
        .navigationTitle("Meals")
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
            }
            Spacer()
            Text(meal.calories, format: .number.precision(.fractionLength(0)))
                .font(.headline.monospacedDigit())
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MealLogView(quotaManager: QuotaManager())
        .environment(AppRouter())
        .environment(MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
}
