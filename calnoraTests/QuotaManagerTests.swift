import Foundation
import Testing
@testable import calnora

struct QuotaManagerTests {
    @Test func enforcesFreeWeeklyLimits() async {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 5, day: 25))!
        let manager = QuotaManager(calendar: calendar, persistenceURL: nil)

        #expect(await manager.canUse(.aiMealParse, entitlements: .free, at: date))
        await manager.recordUsage(.aiMealParse, at: date, entitlements: .free)
        await manager.recordUsage(.aiMealParse, at: date, entitlements: .free)
        await manager.recordUsage(.aiMealParse, at: date, entitlements: .free)

        #expect(await manager.canUse(.aiMealParse, entitlements: .free, at: date) == false)
        #expect(await manager.remainingUses(for: .aiMealParse, entitlements: .free, at: date) == 0)
    }

    @Test func resetsAcrossCalendarWeeksAndIgnoresPro() async {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 5, day: 25))!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: date)!
        let manager = QuotaManager(calendar: calendar, persistenceURL: nil)
        let pro = PurchaseEntitlements(hasPro: true, hasLifetime: false, hasHighProteinPack: false, activeProductIDs: [CalnoraProductID.monthlyPro])

        await manager.recordUsage(.coachQuestion, at: date, entitlements: .free)
        await manager.recordUsage(.coachQuestion, at: date, entitlements: .free)
        await manager.recordUsage(.coachQuestion, at: date, entitlements: .free)

        #expect(await manager.canUse(.coachQuestion, entitlements: .free, at: nextWeek))
        #expect(await manager.canUse(.coachQuestion, entitlements: pro, at: date))
        #expect(await manager.remainingUses(for: .coachQuestion, entitlements: pro, at: date) == nil)
    }

    @Test func persistsFreeUsageWhenConfigured() async {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 5, day: 25))!
        let url = URL.temporaryDirectory.appending(path: "CalnoraQuotaManagerTests-\(UUID().uuidString).json")
        let first = QuotaManager(calendar: calendar, persistenceURL: url)

        await first.recordUsage(.aiMealParse, at: date, entitlements: .free)
        let second = QuotaManager(calendar: calendar, persistenceURL: url)

        #expect(await second.remainingUses(for: .aiMealParse, entitlements: .free, at: date) == 2)
        try? FileManager.default.removeItem(at: url)
    }
}
