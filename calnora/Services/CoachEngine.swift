import Foundation

nonisolated protocol CoachEngine: Sendable {
    func parseMealDescription(_ text: String, context: MealParsingContext) async throws -> ParsedMealEstimate
    func generateDailyInsight(for context: DailyNutritionContext) async throws -> CoachInsightDraft
    func answerCoachQuestion(_ question: String, context: CoachContext) async throws -> String
    func suggestMealAdjustment(for context: MealAdjustmentContext) async throws -> MealAdjustmentSuggestion
}

nonisolated enum CoachEngineError: LocalizedError, Sendable {
    case unavailable
    case unsafeRequest

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Calnora's private AI coach is unavailable on this device right now."
        case .unsafeRequest:
            "Calnora can help with general nutrition awareness, but not medical or extreme dieting advice."
        }
    }
}

nonisolated struct MealParsingContext: Sendable {
    var preferredUnits: PreferredUnits
    var dietaryPreference: DietaryPreference
    var allergies: [String]
    var avoidedFoods: [String]
}

nonisolated struct DailyNutritionContext: Sendable {
    var date: Date
    var goal: NutritionTargets
    var consumed: NutritionTotals
    var meals: [MealNutrientSnapshot]
}

nonisolated struct CoachContext: Sendable {
    var today: DailyNutritionContext
    var recentInsights: [CoachInsightDraft]
    var isPro: Bool
}

nonisolated struct MealAdjustmentContext: Sendable {
    var meal: ParsedMealEstimate
    var remaining: NutritionTargets
    var dietaryPreference: DietaryPreference
}

nonisolated struct ParsedMealEstimate: Equatable, Sendable {
    var mealName: String
    var servingSummary: String
    var estimatedCalories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var confidence: Double
    var explanation: String
    var items: [ParsedFoodItem]
}

nonisolated struct ParsedFoodItem: Equatable, Sendable {
    var name: String
    var servingSummary: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
}

nonisolated struct CoachInsightDraft: Equatable, Sendable {
    var title: String
    var message: String
    var insightType: CoachInsightType
}

nonisolated struct MealAdjustmentSuggestion: Equatable, Sendable {
    var title: String
    var message: String
    var suggestedCalories: Double
    var suggestedProtein: Double
}
