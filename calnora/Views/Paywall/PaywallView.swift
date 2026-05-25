import FlexStore
import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = PaywallModel()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: CalnoraSpacing.large) {
                WalletPassCard(
                    title: "Unlock your AI nutrition coach",
                    subtitle: "Private estimates, daily coaching, and premium trends.",
                    systemImage: "sparkles",
                    footnote: "Estimates stay approximate and editable. No medical claims."
                )

                VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
                    ForEach(model.benefits, id: \.self) { benefit in
                        Label(benefit, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.primary, CalnoraColors.success)
                    }
                }
                .calnoraCard(tint: CalnoraColors.success)

                productOptions

                Button("Restore Purchases", systemImage: "arrow.clockwise") {
                    Task {
                        await purchaseStore.restorePurchases()
                        notificationStore.restoreComplete()
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Subscription renews unless canceled in App Store account settings. Lifetime is a one-time non-consumable unlock. Pricing is loaded from the App Store.")
                    Text("Privacy: https://example.com/privacy")
                    Text("Terms: https://example.com/terms")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(CalnoraColors.groupedBackground)
        .navigationTitle("Calnora Pro")
        .task {
            await purchaseStore.configure()
        }
        .onChange(of: purchaseStore.purchaseState) { _, state in
            if state == .purchased {
                notificationStore.purchaseSuccessful()
            } else if state == .failed {
                notificationStore.show(
                    title: "Purchase issue",
                    message: purchaseStore.lastErrorMessage ?? "Please try again.",
                    symbolName: "exclamationmark.triangle"
                )
            }
        }
    }

    private var productOptions: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            PaywallProductCard(
                title: "Weekly Pro",
                subtitle: "Flexible access",
                badge: nil,
                productID: CalnoraProductID.weeklyPro
            )
            PaywallProductCard(
                title: "Monthly Pro",
                subtitle: "Full AI coach access",
                badge: nil,
                productID: CalnoraProductID.monthlyPro
            )
            PaywallProductCard(
                title: "Yearly Pro",
                subtitle: "Best value for consistent tracking",
                badge: "Best Value",
                productID: CalnoraProductID.yearlyPro
            )
            PaywallProductCard(
                title: "Lifetime Pro",
                subtitle: "One-time unlock for core Pro features",
                badge: "One Time",
                productID: CalnoraProductID.lifetimePro
            )
        }
    }
}

private struct PaywallProductCard: View {
    @Environment(PurchaseStore.self) private var purchaseStore
    var title: String
    var subtitle: String
    var badge: String?
    var productID: String

    var body: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                    if let badge {
                        Text(badge)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(CalnoraColors.coach.opacity(0.16), in: .capsule)
                            .foregroundStyle(CalnoraColors.coach)
                    }
                }
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(purchaseStore.storeKitService.product(for: productID)?.displayPrice ?? "Loading")
                    .font(.headline.monospacedDigit())
                Button("Choose") {
                    Task { await purchaseStore.purchase(productID: productID) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(purchaseStore.storeKitService.product(for: productID) == nil)
            }
        }
        .calnoraCard(tint: CalnoraColors.coach, isInteractive: true)
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
    .environment(PurchaseStore())
    .environment(NotificationStore())
    .environment(StoreKitService<CalnoraSubscriptionTier>())
}
