import Foundation
import FlexStore
import Observation

enum CalnoraPurchaseState: String, CaseIterable, Sendable {
    case loadingProducts
    case ready
    case purchasing
    case purchased
    case restored
    case cancelled
    case pending
    case failed
}

@Observable
final class PurchaseStore {
    @ObservationIgnored let storeKitService = StoreKitService<CalnoraSubscriptionTier>()
    var purchaseState: CalnoraPurchaseState = .loadingProducts
    var lastErrorMessage: String?

    var entitlements: PurchaseEntitlements {
        let owned = storeKitService.purchasedNonConsumables
        let hasLifetime = owned.contains(CalnoraProductID.lifetimePro)
        let hasHighProteinPack = owned.contains(CalnoraProductID.highProteinPack)
        let hasPro = storeKitService.subscriptionTier == .pro || hasLifetime
        var active = owned
        if let activeProductID = storeKitService.activeProductID {
            active.insert(activeProductID)
        }

        return PurchaseEntitlements(
            hasPro: hasPro,
            hasLifetime: hasLifetime,
            hasHighProteinPack: hasHighProteinPack,
            activeProductIDs: active
        )
    }

    func configure() async {
        purchaseState = .loadingProducts
        await storeKitService.configure(
            productIDs: CalnoraProductID.all,
            subscriptionGroupID: CalnoraProductID.subscriptionGroupID
        )
        purchaseState = .ready
    }

    func restorePurchases() async {
        await storeKitService.restorePurchases()
        purchaseState = .restored
    }

    func purchase(productID: String) async {
        purchaseState = .purchasing
        do {
            let outcome = try await storeKitService.purchase(productID: productID)
            switch outcome {
            case .success:
                purchaseState = .purchased
            case .cancelled:
                purchaseState = .cancelled
            case .pending:
                purchaseState = .pending
            }
        } catch {
            purchaseState = .failed
            lastErrorMessage = error.localizedDescription
        }
    }

    func owns(_ productID: String) -> Bool {
        storeKitService.purchasedNonConsumables.contains(productID)
    }
}
