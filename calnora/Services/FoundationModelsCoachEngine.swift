import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@Generable
private struct FoundationMealEstimate {
    @Guide(description: "Short meal name.")
    let mealName: String
    let servingSummary: String
    let estimatedCalories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let confidence: Double
    let explanation: String
    let items: [FoundationMealItem]
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@Generable
private struct FoundationMealItem {
    let name: String
    let servingSummary: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}
#endif

struct FoundationModelsCoachEngine: CoachEngine {
    func parseMealDescription(_ text: String, context: MealParsingContext) async throws -> ParsedMealEstimate {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            guard SystemLanguageModel.default.availability == .available else {
                return try await MockCoachEngine().parseMealDescription(text, context: context)
            }

            let session = LanguageModelSession(instructions: Instructions {
                "You are Calnora, a private nutrition logging assistant."
                "Estimate calories and macros approximately. Never claim exactness."
                "Avoid medical advice, diagnoses, shame, or extreme restriction."
                "Return concise values the user can review and edit before saving."
            })
            let response = try await session.respond(
                to: """
                Estimate this meal: \(text)

                User context:
                Units: \(context.preferredUnits.rawValue)
                Dietary preference: \(context.dietaryPreference.rawValue)
                Allergies: \(context.allergies.joined(separator: ", "))
                Avoided foods: \(context.avoidedFoods.joined(separator: ", "))
                """,
                generating: FoundationMealEstimate.self,
                options: GenerationOptions(sampling: .greedy, maximumResponseTokens: 700)
            )
            return response.content.parsedEstimate
        }
        #endif

        return try await MockCoachEngine().parseMealDescription(text, context: context)
    }

    func generateDailyInsight(for context: DailyNutritionContext) async throws -> CoachInsightDraft {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *),
           SystemLanguageModel.default.availability == .available {
            let session = LanguageModelSession(instructions: Instructions {
                "You are Calnora, a calm nutrition coach."
                "Be concise, supportive, nonjudgmental, and clear that estimates are approximate."
                "Do not diagnose, treat, promise weight loss, or recommend extreme restriction."
            })
            let response = try await session.respond(
                to: "Write one short daily nutrition note. Calories consumed: \(context.consumed.calories). Target: \(context.goal.calories). Protein: \(context.consumed.protein)g of \(context.goal.protein)g.",
                options: GenerationOptions(sampling: .greedy, maximumResponseTokens: 160)
            )
            return CoachInsightDraft(
                title: "Today's Coach Note",
                message: response.content,
                insightType: .dailyNote
            )
        }
        #endif

        return try await MockCoachEngine().generateDailyInsight(for: context)
    }

    func answerCoachQuestion(_ question: String, context: CoachContext) async throws -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *),
           SystemLanguageModel.default.availability == .available {
            let session = LanguageModelSession(instructions: Instructions {
                "You are Calnora, a supportive nutrition coach for general wellness."
                "Keep answers concise. Do not provide medical advice or eating disorder guidance."
                "Encourage professional support for medical conditions."
                "Remind users nutrition estimates are approximate when relevant."
            })
            let response = try await session.respond(
                to: question,
                options: GenerationOptions(sampling: .greedy, maximumResponseTokens: 240)
            )
            return response.content
        }
        #endif

        return try await MockCoachEngine().answerCoachQuestion(question, context: context)
    }

    func suggestMealAdjustment(for context: MealAdjustmentContext) async throws -> MealAdjustmentSuggestion {
        try await MockCoachEngine().suggestMealAdjustment(for: context)
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
private extension FoundationMealEstimate {
    var parsedEstimate: ParsedMealEstimate {
        ParsedMealEstimate(
            mealName: mealName,
            servingSummary: servingSummary,
            estimatedCalories: estimatedCalories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            confidence: min(max(confidence, 0), 1),
            explanation: explanation,
            items: items.map(\.parsedItem)
        )
    }
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
private extension FoundationMealItem {
    var parsedItem: ParsedFoodItem {
        ParsedFoodItem(
            name: name,
            servingSummary: servingSummary,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }
}
#endif
