import Foundation
import FlexStore
import Observation
import SwiftData

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
    @ObservationIgnored private let context: ModelContext?
    @ObservationIgnored let storeKitService = StoreKitService<CalnoraSubscriptionTier>()
    var purchaseState: CalnoraPurchaseState = .loadingProducts
    var lastErrorMessage: String?

    init(context: ModelContext? = nil) {
        self.context = context
        seedPremiumPackIfNeeded()
    }

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
        persistSnapshot()
        purchaseState = .ready
    }

    func restorePurchases() async {
        await storeKitService.restorePurchases()
        persistSnapshot()
        purchaseState = .restored
    }

    func purchase(productID: String) async {
        purchaseState = .purchasing
        do {
            let outcome = try await storeKitService.purchase(productID: productID)
            switch outcome {
            case .success:
                persistSnapshot()
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

    func purchaseSnapshots() -> [ExportedPurchaseSnapshot] {
        guard let context else { return [] }
        let descriptor = FetchDescriptor<PurchaseSnapshot>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return ((try? context.fetch(descriptor)) ?? []).map(ExportedPurchaseSnapshot.init)
    }

    func premiumPacks() -> [ExportedPremiumContentPack] {
        guard let context else { return [] }
        let descriptor = FetchDescriptor<PremiumContentPack>(
            sortBy: [SortDescriptor(\.title)]
        )
        return ((try? context.fetch(descriptor)) ?? []).map(ExportedPremiumContentPack.init)
    }

    func persistSnapshot() {
        guard let context else { return }
        let entitlements = entitlements
        let snapshot = PurchaseSnapshot(
            hasPro: entitlements.hasPro,
            hasLifetime: entitlements.hasLifetime,
            hasHighProteinPack: entitlements.hasHighProteinPack,
            activeProductIDs: entitlements.activeProductIDs.sorted()
        )
        context.insert(snapshot)
        updatePremiumPackUnlock(entitlements.hasHighProteinPack)
        try? context.save()
    }

    private func seedPremiumPackIfNeeded() {
        guard let context else { return }
        let productID = CalnoraProductID.highProteinPack
        let descriptor = FetchDescriptor<PremiumContentPack>(
            predicate: #Predicate { $0.productID == productID }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        context.insert(PremiumContentPack(
            productID: productID,
            title: "High Protein Pack",
            isUnlocked: false
        ))
        try? context.save()
    }

    private func updatePremiumPackUnlock(_ isUnlocked: Bool) {
        guard let context else { return }
        let productID = CalnoraProductID.highProteinPack
        let descriptor = FetchDescriptor<PremiumContentPack>(
            predicate: #Predicate { $0.productID == productID }
        )
        if let pack = try? context.fetch(descriptor).first {
            pack.isUnlocked = isUnlocked
        }
    }
}
