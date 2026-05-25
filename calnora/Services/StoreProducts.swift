import FlexStore
import Foundation

nonisolated enum CalnoraProductID {
    static let weeklyPro = "com.gerardgomez.calnora.pro.weekly"
    static let monthlyPro = "com.gerardgomez.calnora.pro.monthly"
    static let yearlyPro = "com.gerardgomez.calnora.pro.yearly"
    static let lifetimePro = "com.gerardgomez.calnora.pro.lifetime"
    static let highProteinPack = "com.gerardgomez.calnora.pack.highprotein"

    static let subscriptions: Set<String> = [weeklyPro, monthlyPro, yearlyPro]
    static let nonConsumables: Set<String> = [lifetimePro, highProteinPack]
    static let all: Set<String> = subscriptions.union(nonConsumables)

    static let subscriptionGroupID = "CALNORA_PRO"
}

nonisolated enum CalnoraSubscriptionTier: Int, CaseIterable, SubscriptionTier {
    case free
    case pro

    static var defaultTier: CalnoraSubscriptionTier { .free }

    init?(levelOfService: Int) {
        self = levelOfService > 0 ? .pro : .free
    }

    init?(productID: String) {
        if CalnoraProductID.subscriptions.contains(productID) || productID == CalnoraProductID.lifetimePro {
            self = .pro
        } else {
            self = .free
        }
    }
}

nonisolated struct PurchaseEntitlements: Equatable, Sendable {
    var hasPro: Bool
    var hasLifetime: Bool
    var hasHighProteinPack: Bool
    var activeProductIDs: Set<String>

    var unlocksPro: Bool { hasPro || hasLifetime }

    static let free = PurchaseEntitlements(
        hasPro: false,
        hasLifetime: false,
        hasHighProteinPack: false,
        activeProductIDs: []
    )
}
