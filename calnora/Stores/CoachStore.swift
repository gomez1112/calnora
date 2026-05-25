import Foundation
import Observation
import SwiftData

@Observable
final class CoachStore {
    @ObservationIgnored private let engine: any CoachEngine
    @ObservationIgnored private let mealStore: MealStore
    @ObservationIgnored private let nutritionGoalStore: NutritionGoalStore

    var messages: [CoachMessage] = []
    var latestInsight: CoachInsightDraft?
    var isResponding = false
    var lastErrorMessage: String?

    init(
        engine: any CoachEngine,
        mealStore: MealStore,
        nutritionGoalStore: NutritionGoalStore
    ) {
        self.engine = engine
        self.mealStore = mealStore
        self.nutritionGoalStore = nutritionGoalStore
    }

    func refreshDailyInsight() async {
        let context = makeDailyContext()
        do {
            latestInsight = try await engine.generateDailyInsight(for: context)
        } catch {
            latestInsight = CoachInsightDraft(
                title: "Today's Coach Note",
                message: "Keep logging with curiosity. Estimates are approximate and editable.",
                insightType: .dailyNote
            )
        }
    }

    func answer(_ question: String, entitlements: PurchaseEntitlements, quotaManager: QuotaManager) async -> String {
        guard await quotaManager.canUse(.coachQuestion, entitlements: entitlements) else {
            return QuotaError.limitReached.localizedDescription
        }

        isResponding = true
        defer { isResponding = false }

        do {
            let context = CoachContext(
                today: makeDailyContext(),
                recentInsights: latestInsight.map { [$0] } ?? [],
                isPro: entitlements.unlocksPro
            )
            let answer = try await engine.answerCoachQuestion(question, context: context)
            await quotaManager.recordUsage(.coachQuestion, entitlements: entitlements)
            return answer
        } catch {
            lastErrorMessage = error.localizedDescription
            return "I can help with general nutrition awareness, but I cannot provide medical advice. For medical needs, please work with a qualified professional."
        }
    }

    private func makeDailyContext() -> DailyNutritionContext {
        let snapshots = mealStore.snapshots(on: .now)
        return DailyNutritionContext(
            date: .now,
            goal: nutritionGoalStore.targets,
            consumed: NutritionCalculator.mealTotals(for: snapshots),
            meals: snapshots
        )
    }
}
