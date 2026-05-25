import Foundation

actor MealParser {
    private let engine: any CoachEngine
    private let quotaManager: QuotaManager

    init(engine: any CoachEngine, quotaManager: QuotaManager) {
        self.engine = engine
        self.quotaManager = quotaManager
    }

    func parse(
        _ text: String,
        context: MealParsingContext,
        entitlements: PurchaseEntitlements,
        at date: Date = .now
    ) async throws -> ParsedMealEstimate {
        guard await quotaManager.canUse(.aiMealParse, entitlements: entitlements, at: date) else {
            throw QuotaError.limitReached
        }

        let estimate = try await engine.parseMealDescription(text, context: context)
        await quotaManager.recordUsage(.aiMealParse, at: date, entitlements: entitlements)
        return estimate
    }
}
