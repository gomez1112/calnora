import FlexStore
import StoreKit
import SwiftUI

struct PremiumPackView: View {
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: CalnoraSpacing.large) {
                WalletPassCard(
                    title: "High Protein Pack",
                    subtitle: "20 local meal ideas\(priceSuffix)",
                    systemImage: "takeoutbag.and.cup.and.straw",
                    footnote: "Values are approximate and intended for planning.",
                    actionTitle: nil
                )

                if purchaseStore.entitlements.hasHighProteinPack {
                    ForEach(PremiumContentService.highProteinIdeas()) { idea in
                        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
                            Text(idea.title)
                                .font(.headline)
                            Text(idea.description)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text(idea.calories, format: .number.precision(.fractionLength(0)))
                                Text("cal")
                                Spacer()
                                Text(idea.protein, format: .number.precision(.fractionLength(0)))
                                Text("g protein")
                            }
                            .font(.caption.weight(.semibold))
                        }
                        .calnoraCard(tint: CalnoraColors.protein)
                    }
                } else {
                    CalnoraEmptyState(
                        title: "Pack locked",
                        message: "Unlock a local high-protein idea pack independently from Pro.",
                        systemImage: "lock.fill",
                        tint: CalnoraColors.protein
                    )
                    highProteinPurchaseButton

                    ForEach(PremiumContentService.highProteinIdeas().prefix(3)) { idea in
                        LockedMealIdeaRow(idea: idea)
                    }
                }
            }
            .padding()
        }
        .background(CalnoraColors.groupedBackground)
        .navigationTitle("Premium Pack")
        .onChange(of: purchaseStore.storeKitService.purchasedNonConsumables) { _, owned in
            guard owned.contains(CalnoraProductID.highProteinPack) else { return }
            purchaseStore.purchaseState = .purchased
            purchaseStore.persistSnapshot()
            notificationStore.purchaseSuccessful()
        }
    }

    private var highProteinPurchaseButton: some View {
        NonConsumablePurchaseButton<CalnoraSubscriptionTier>(
            productID: CalnoraProductID.highProteinPack,
            title: "Unlock High Protein Pack",
            purchasedTitle: "Pack Unlocked"
        )
        .label { state in
            Label(highProteinButtonTitle(for: state), systemImage: "takeoutbag.and.cup.and.straw")
        }
        .buttonStyle(.borderedProminent)
        .disabled(purchaseStore.storeKitService.product(for: CalnoraProductID.highProteinPack) == nil)
    }

    private var priceSuffix: String {
        guard let price = purchaseStore.storeKitService.product(for: CalnoraProductID.highProteinPack)?.displayPrice else {
            return ""
        }
        return " · \(price)"
    }

    private func highProteinButtonTitle(for state: FlexStoreNonConsumablePurchaseState) -> String {
        switch state {
        case .purchasing:
            "Purchasing"
        case .purchased:
            "Pack Unlocked"
        default:
            "Unlock High Protein Pack"
        }
    }
}

private struct LockedMealIdeaRow: View {
    var idea: HighProteinMealIdea

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.headline)
                Text("Unlock to view local meal details and approximate macros.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "lock.fill")
                .foregroundStyle(CalnoraColors.protein)
        }
        .redacted(reason: .placeholder)
        .calnoraCard(tint: CalnoraColors.protein)
        .accessibilityLabel("Locked high protein meal idea")
    }
}
