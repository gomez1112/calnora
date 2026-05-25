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
    @State private var remainingUses: Int?

    var body: some View {
        @Bindable var model = model

        Form {
            Section {
                LabeledContent("AI estimates this week", value: quotaText)
                if !purchaseStore.entitlements.unlocksPro {
                    Text("Free users get 3 AI meal estimates per calendar week. Manual logging stays unlimited.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                TextField("2 eggs, sourdough toast, coffee with oat milk", text: $descriptionText, axis: .vertical)
                    .lineLimit(3...6)
                Button {
                    Task { await parseMeal() }
                } label: {
                    if isParsing {
                        Label("Estimating", systemImage: "hourglass")
                    } else {
                        Label("Estimate Meal", systemImage: "sparkles")
                    }
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
                    LabeledContent("Confidence") {
                        Text(parsedEstimate.confidence, format: .percent.precision(.fractionLength(0)))
                    }
                    if !parsedEstimate.items.isEmpty {
                        DisclosureGroup("Parsed items") {
                            ForEach(Array(parsedEstimate.items.enumerated()), id: \.offset) { _, item in
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text(item.servingSummary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    HStack(spacing: 2) {
                                        Text(item.calories, format: .number.precision(.fractionLength(0)))
                                        Text("cal")
                                    }
                                }
                            }
                        }
                    }
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
                    Toggle("Save as favorite", isOn: $model.saveAsFavorite)
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
        .task {
            await refreshQuota()
        }
        .onChange(of: purchaseStore.entitlements) { _, _ in
            Task { await refreshQuota() }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let meal = model.makeMealEntry(source: .aiEstimate, confidence: parsedEstimate?.confidence ?? 0.5)
                    mealStore.save(meal)
                    if model.saveAsFavorite {
                        mealStore.saveFavorite(from: meal)
                    }
                    notificationStore.mealSaved()
                    dismiss()
                }
                .disabled(parsedEstimate == nil || !model.canSave)
            }
        }
    }

    private var quotaText: String {
        if purchaseStore.entitlements.unlocksPro {
            "Unlimited"
        } else if let remainingUses {
            "\(remainingUses) remaining"
        } else {
            "Loading"
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
            await refreshQuota()
        } catch {
            errorMessage = error.localizedDescription
            if case QuotaError.limitReached = error {
                notificationStore.quotaLimitReached()
            } else {
                notificationStore.show(
                    title: "Estimate unavailable",
                    message: error.localizedDescription,
                    symbolName: "exclamationmark.triangle"
                )
            }
        }
    }

    private func refreshQuota() async {
        remainingUses = await quotaManager.remainingUses(
            for: .aiMealParse,
            entitlements: purchaseStore.entitlements
        )
    }
}
