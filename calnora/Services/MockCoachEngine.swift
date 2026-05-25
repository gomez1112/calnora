import Foundation

struct MockCoachEngine: CoachEngine {
    func parseMealDescription(_ text: String, context: MealParsingContext) async throws -> ParsedMealEstimate {
        let estimate = NutritionCalculator.estimateMeal(from: text)
        return ParsedMealEstimate(
            mealName: estimate.name,
            servingSummary: "Estimated from your description",
            estimatedCalories: estimate.totals.calories,
            protein: estimate.totals.protein,
            carbs: estimate.totals.carbs,
            fat: estimate.totals.fat,
            fiber: estimate.totals.fiber,
            sugar: estimate.totals.sugar,
            confidence: 0.54,
            explanation: "Foundation Models are unavailable, so this uses a local approximation. Review and edit before saving.",
            items: estimate.items
        )
    }

    func generateDailyInsight(for context: DailyNutritionContext) async throws -> CoachInsightDraft {
        let remaining = NutritionCalculator.remaining(targets: context.goal, consumed: context.consumed)
        let message: String
        if remaining.calories >= 450 {
            message = "You have room left today. A steady meal with protein, fiber, and water would keep things balanced."
        } else if remaining.calories >= 0 {
            message = "You are close to your target. Keep the next choice simple and satisfying."
        } else {
            message = "You are a little above target. No reset needed; use it as context for tomorrow."
        }

        return CoachInsightDraft(
            title: "Today's Coach Note",
            message: "\(message) Nutrition estimates are approximate.",
            insightType: .dailyNote
        )
    }

    func answerCoachQuestion(_ question: String, context: CoachContext) async throws -> String {
        if question.localizedCaseInsensitiveContains("diagnose") {
            throw CoachEngineError.unsafeRequest
        }

        return "A supportive next step is to look for one small consistency win: protein at your next meal, enough water, or logging while the meal is still fresh. For medical needs, work with a qualified professional."
    }

    func suggestMealAdjustment(for context: MealAdjustmentContext) async throws -> MealAdjustmentSuggestion {
        MealAdjustmentSuggestion(
            title: "Small adjustment",
            message: "If you want more balance, add a protein-rich side and keep the estimate editable before saving.",
            suggestedCalories: min(context.remaining.calories, context.meal.estimatedCalories),
            suggestedProtein: max(context.meal.protein, 25)
        )
    }
}
