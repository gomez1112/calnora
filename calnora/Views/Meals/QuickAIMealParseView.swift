import SwiftUI

struct QuickAIMealParseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MealStore.self) private var mealStore
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore

    let quotaManager: QuotaManager

    @State private var descriptionText = ""
    @State private var model = MealEditorModel()
    @State private var parsedEstimate: ParsedMealEstimate?
    @State private var isParsing = false
    @State private var errorMessage: String?

    var body: some View {
        @Bindable var model = model

        Form {
            Section {
                TextField("2 eggs, sourdough toast, coffee with oat milk", text: $descriptionText, axis: .vertical)
                    .lineLimit(3...6)
                Button("Estimate Meal", systemImage: "sparkles") {
                    Task { await parseMeal() }
                }
                .disabled(descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isParsing)
            } header: {
                Text("AI Meal Estimate")
            } footer: {
                Text("Estimated — review before saving. Calnora does not claim AI estimates are exact.")
            }

            if let parsedEstimate {
                Section("Review Estimate") {
                    Text(parsedEstimate.explanation)
                        .foregroundStyle(.secondary)
                    Picker("Meal type", selection: $model.mealType) {
                        ForEach(MealType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    TextField("Name", text: $model.name)
                    TextField("Serving", text: $model.servingDescription)
                    TextField("Calories", value: $model.calories, format: .number)
                    TextField("Protein", value: $model.protein, format: .number)
                    TextField("Carbs", value: $model.carbs, format: .number)
                    TextField("Fat", value: $model.fat, format: .number)
                    TextField("Fiber", value: $model.fiber, format: .number)
                    TextField("Sugar", value: $model.sugar, format: .number)
                }
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(CalnoraColors.warning)
                }
            }
        }
        .navigationTitle("AI Estimate")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    mealStore.save(model.makeMealEntry(source: .aiEstimate, confidence: parsedEstimate?.confidence ?? 0.5))
                    notificationStore.mealSaved()
                    dismiss()
                }
                .disabled(parsedEstimate == nil || !model.canSave)
            }
        }
    }

    private func parseMeal() async {
        isParsing = true
        errorMessage = nil
        defer { isParsing = false }

        let profile = userProfileStore.ensureProfile()
        let context = MealParsingContext(
            preferredUnits: profile.preferredUnits,
            dietaryPreference: profile.dietaryPreference,
            allergies: profile.allergies,
            avoidedFoods: profile.avoidedFoods
        )
        let parser = MealParser(
            engine: CoachEngineAvailability.makeEngine(),
            quotaManager: quotaManager
        )

        do {
            let estimate = try await parser.parse(
                descriptionText,
                context: context,
                entitlements: purchaseStore.entitlements
            )
            parsedEstimate = estimate
            model.apply(estimate)
            notificationStore.aiEstimateReady()
        } catch {
            errorMessage = error.localizedDescription
            notificationStore.show(
                title: "Estimate unavailable",
                message: error.localizedDescription,
                symbolName: "exclamationmark.triangle"
            )
        }
    }
}
