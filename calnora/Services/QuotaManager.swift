import Foundation

enum QuotaFeature: String, CaseIterable, Sendable {
    case aiMealParse
    case coachQuestion
}

enum QuotaError: LocalizedError, Sendable {
    case limitReached

    var errorDescription: String? {
        "You have used your free AI quota for this week. Pro unlocks unlimited AI estimates and coach questions."
    }
}

actor QuotaManager {
    private let weeklyFreeLimit: Int
    private let calendar: Calendar
    private var usage: [QuotaFeature: [Date]]

    init(weeklyFreeLimit: Int = 3, calendar: Calendar = .current, usage: [QuotaFeature: [Date]] = [:]) {
        self.weeklyFreeLimit = weeklyFreeLimit
        self.calendar = calendar
        self.usage = usage
    }

    func canUse(_ feature: QuotaFeature, entitlements: PurchaseEntitlements, at date: Date = .now) -> Bool {
        guard !entitlements.unlocksPro else { return true }
        return usageCount(for: feature, inWeekOf: date) < weeklyFreeLimit
    }

    func recordUsage(_ feature: QuotaFeature, at date: Date = .now, entitlements: PurchaseEntitlements) {
        guard !entitlements.unlocksPro else { return }
        usage[feature, default: []].append(date)
        resetOldUsage(for: feature, keepingWeekOf: date)
    }

    func remainingUses(for feature: QuotaFeature, entitlements: PurchaseEntitlements, at date: Date = .now) -> Int? {
        guard !entitlements.unlocksPro else { return nil }
        return max(weeklyFreeLimit - usageCount(for: feature, inWeekOf: date), 0)
    }

    func resetWeek(containing date: Date = .now) {
        for feature in QuotaFeature.allCases {
            resetOldUsage(for: feature, keepingWeekOf: date)
        }
    }

    private func usageCount(for feature: QuotaFeature, inWeekOf date: Date) -> Int {
        usage[feature, default: []].filter { calendar.isDate($0, equalTo: date, toGranularity: .weekOfYear) }.count
    }

    private func resetOldUsage(for feature: QuotaFeature, keepingWeekOf date: Date) {
        usage[feature, default: []] = usage[feature, default: []].filter {
            calendar.isDate($0, equalTo: date, toGranularity: .weekOfYear)
        }
    }
}
