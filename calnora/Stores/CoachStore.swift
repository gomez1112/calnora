import Foundation
import Observation
import SwiftData

@Observable
final class CoachStore {
    @ObservationIgnored private let context: ModelContext?
    @ObservationIgnored private let engine: any CoachEngine
    @ObservationIgnored private let mealStore: MealStore
    @ObservationIgnored private let nutritionGoalStore: NutritionGoalStore

    var messages: [CoachMessage] = []
    var insights: [CoachInsight] = []
    var latestInsight: CoachInsightDraft?
    var isResponding = false
    var lastErrorMessage: String?

    init(
        context: ModelContext? = nil,
        engine: any CoachEngine,
        mealStore: MealStore,
        nutritionGoalStore: NutritionGoalStore
    ) {
        self.context = context
        self.engine = engine
        self.mealStore = mealStore
        self.nutritionGoalStore = nutritionGoalStore
        load()
    }

    func load() {
        guard let context else { return }
        let messageDescriptor = FetchDescriptor<CoachMessage>(sortBy: [SortDescriptor(\.date)])
        messages = (try? context.fetch(messageDescriptor)) ?? []

        let insightDescriptor = FetchDescriptor<CoachInsight>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        insights = (try? context.fetch(insightDescriptor)) ?? []
        if let newest = insights.first {
            latestInsight = CoachInsightDraft(title: newest.title, message: newest.message, insightType: newest.insightType)
        }
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
        persistLatestInsight()
    }

    func answer(_ question: String, entitlements: PurchaseEntitlements, quotaManager: QuotaManager) async -> String {
        guard await quotaManager.canUse(.coachQuestion, entitlements: entitlements) else {
            return QuotaError.limitReached.localizedDescription
        }

        saveMessage(role: .user, content: question)
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
            saveMessage(role: .assistant, content: answer)
            return answer
        } catch {
            lastErrorMessage = error.localizedDescription
            let fallback = "I can help with general nutrition awareness, but I cannot provide medical advice. For medical needs, please work with a qualified professional."
            saveMessage(role: .assistant, content: fallback)
            return fallback
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

    private func saveMessage(role: CoachRole, content: String) {
        guard let context else { return }
        context.insert(CoachMessage(role: role, content: content))
        try? context.save()
        load()
    }

    private func persistLatestInsight() {
        guard let context, let latestInsight else { return }
        if let existing = insights.first(where: {
            Calendar.current.isDateInToday($0.date) && $0.insightType == latestInsight.insightType
        }) {
            existing.title = latestInsight.title
            existing.message = latestInsight.message
            existing.date = .now
        } else {
            context.insert(CoachInsight(
                title: latestInsight.title,
                message: latestInsight.message,
                insightType: latestInsight.insightType
            ))
        }
        try? context.save()
        load()
    }
}
