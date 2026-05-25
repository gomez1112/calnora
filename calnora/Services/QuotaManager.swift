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
    private let persistenceURL: URL?
    private var usage: [QuotaFeature: [Date]]
    private var hasLoadedUsage = false

    init(
        weeklyFreeLimit: Int = 3,
        calendar: Calendar = .current,
        usage: [QuotaFeature: [Date]] = [:],
        persistenceURL: URL? = URL.documentsDirectory.appending(path: "CalnoraQuotaUsage.json")
    ) {
        self.weeklyFreeLimit = weeklyFreeLimit
        self.calendar = calendar
        self.usage = usage
        self.persistenceURL = persistenceURL
        self.hasLoadedUsage = !usage.isEmpty || persistenceURL == nil
    }

    func canUse(_ feature: QuotaFeature, entitlements: PurchaseEntitlements, at date: Date = .now) async -> Bool {
        await loadPersistedUsageIfNeeded()
        guard !entitlements.unlocksPro else { return true }
        return usageCount(for: feature, inWeekOf: date) < weeklyFreeLimit
    }

    func recordUsage(_ feature: QuotaFeature, at date: Date = .now, entitlements: PurchaseEntitlements) async {
        await loadPersistedUsageIfNeeded()
        guard !entitlements.unlocksPro else { return }
        usage[feature, default: []].append(date)
        resetOldUsage(for: feature, keepingWeekOf: date)
        persistUsage()
    }

    func remainingUses(for feature: QuotaFeature, entitlements: PurchaseEntitlements, at date: Date = .now) async -> Int? {
        await loadPersistedUsageIfNeeded()
        guard !entitlements.unlocksPro else { return nil }
        return max(weeklyFreeLimit - usageCount(for: feature, inWeekOf: date), 0)
    }

    func resetWeek(containing date: Date = .now) async {
        await loadPersistedUsageIfNeeded()
        for feature in QuotaFeature.allCases {
            resetOldUsage(for: feature, keepingWeekOf: date)
        }
        persistUsage()
    }

    func usageSnapshot() async -> [QuotaFeature: [Date]] {
        await loadPersistedUsageIfNeeded()
        return usage
    }

    private func usageCount(for feature: QuotaFeature, inWeekOf date: Date) -> Int {
        usage[feature, default: []].filter { calendar.isDate($0, equalTo: date, toGranularity: .weekOfYear) }.count
    }

    private func resetOldUsage(for feature: QuotaFeature, keepingWeekOf date: Date) {
        usage[feature, default: []] = usage[feature, default: []].filter {
            calendar.isDate($0, equalTo: date, toGranularity: .weekOfYear)
        }
    }

    private func loadPersistedUsageIfNeeded() async {
        guard !hasLoadedUsage else { return }
        hasLoadedUsage = true
        guard let persistenceURL,
              let data = try? Data(contentsOf: persistenceURL),
              let storedUsage = try? JSONDecoder().decode(StoredQuotaUsage.self, from: data)
        else {
            return
        }
        usage = storedUsage.usage
        await resetWeek()
    }

    private func persistUsage() {
        guard let persistenceURL else { return }
        do {
            let data = try JSONEncoder().encode(StoredQuotaUsage(usage: usage))
            try FileManager.default.createDirectory(
                at: persistenceURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: persistenceURL, options: [.atomic])
        } catch {
            // Quotas are an upgrade prompt aid. A write failure should not block logging.
        }
    }
}

nonisolated private struct StoredQuotaUsage: Codable, Sendable {
    var aiMealParse: [Date]
    var coachQuestion: [Date]

    init(usage: [QuotaFeature: [Date]]) {
        aiMealParse = usage[.aiMealParse, default: []]
        coachQuestion = usage[.coachQuestion, default: []]
    }

    var usage: [QuotaFeature: [Date]] {
        [
            .aiMealParse: aiMealParse,
            .coachQuestion: coachQuestion
        ]
    }
}
