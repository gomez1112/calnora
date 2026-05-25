import Testing
@testable import calnora

struct EntitlementTests {
    @Test func lifetimeUnlockEqualsPro() {
        let entitlements = PurchaseEntitlements(
            hasPro: false,
            hasLifetime: true,
            hasHighProteinPack: false,
            activeProductIDs: [CalnoraProductID.lifetimePro]
        )

        #expect(entitlements.unlocksPro)
    }

    @Test func premiumPackCanUnlockIndependently() {
        let entitlements = PurchaseEntitlements(
            hasPro: false,
            hasLifetime: false,
            hasHighProteinPack: true,
            activeProductIDs: [CalnoraProductID.highProteinPack]
        )

        #expect(entitlements.unlocksPro == false)
        #expect(entitlements.hasHighProteinPack)
    }

    @Test func productIDsAreStable() {
        #expect(CalnoraProductID.weeklyPro == "com.gerardgomez.calnora.pro.weekly")
        #expect(CalnoraProductID.monthlyPro == "com.gerardgomez.calnora.pro.monthly")
        #expect(CalnoraProductID.yearlyPro == "com.gerardgomez.calnora.pro.yearly")
        #expect(CalnoraProductID.lifetimePro == "com.gerardgomez.calnora.pro.lifetime")
        #expect(CalnoraProductID.highProteinPack == "com.gerardgomez.calnora.pack.highprotein")
    }
}
