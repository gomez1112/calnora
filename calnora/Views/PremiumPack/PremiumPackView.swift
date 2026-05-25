import FlexStore
import SwiftUI

struct PremiumPackView: View {
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: CalnoraSpacing.large) {
                WalletPassCard(
                    title: "High Protein Pack",
                    subtitle: "20 local meal ideas",
                    systemImage: "takeoutbag.and.cup.and.straw",
                    footnote: "Values are approximate and intended for planning.",
                    actionTitle: purchaseStore.entitlements.hasHighProteinPack ? nil : "Unlock"
                ) {
                    Task {
                        await purchaseStore.purchase(productID: CalnoraProductID.highProteinPack)
                        if purchaseStore.purchaseState == .purchased {
                            notificationStore.purchaseSuccessful()
                        }
                    }
                }

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
                    NonConsumablePurchaseButton<CalnoraSubscriptionTier>(
                        productID: CalnoraProductID.highProteinPack,
                        title: "Unlock High Protein Pack",
                        purchasedTitle: "Unlocked"
                    )
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .background(CalnoraColors.groupedBackground)
        .navigationTitle("Premium Pack")
    }
}
