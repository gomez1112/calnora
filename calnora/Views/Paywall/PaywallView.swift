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
                subscriptionOptions
                featureList
                lifetimeUnlock

                LabeledContent("Purchase status", value: purchaseStore.purchaseState.rawValue.capitalized)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .calnoraCard(tint: CalnoraColors.coach)

                Button("Restore Purchases", systemImage: "arrow.clockwise") {
                    Task {
                        purchaseStore.purchaseState = .loadingProducts
                        await purchaseStore.storeKitService.restorePurchases()
                        purchaseStore.purchaseState = .restored
                        purchaseStore.persistSnapshot()
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
        .onChange(of: purchaseStore.storeKitService.subscriptionTier) { _, tier in
            guard tier == .pro else { return }
            purchaseStore.purchaseState = .purchased
            purchaseStore.persistSnapshot()
        }
    }

    private var subscriptionOptions: some View {
        SubscriptionPassStoreView<CalnoraSubscriptionTier, WalletPassCard>(
            groupID: CalnoraProductID.subscriptionGroupID,
            iconProvider: subscriptionIcon
        ) {
            WalletPassCard(
                title: "Unlock your AI nutrition coach",
                subtitle: "Private estimates, daily coaching, and premium trends.",
                systemImage: "sparkles",
                footnote: "Estimates stay approximate and editable. No medical claims."
            )
        }
        .calnoraCard(tint: CalnoraColors.coach)
    }

    private var featureList: some View {
        VStack(spacing: CalnoraSpacing.small) {
            ForEach(model.features) { feature in
                FlexDefaultFeatureRow(feature)
            }
        }
    }

    private var lifetimeUnlock: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .top, spacing: CalnoraSpacing.medium) {
                Image(systemName: "infinity.circle.fill")
                    .font(.title2)
                    .foregroundStyle(CalnoraColors.coach)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Lifetime Pro")
                            .font(.headline)
                        Text("One Time")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(CalnoraColors.coach.opacity(0.16), in: .capsule)
                            .foregroundStyle(CalnoraColors.coach)
                    }
                    Text("Unlock core Pro features without a subscription.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            NonConsumablePurchaseButton<CalnoraSubscriptionTier>(
                productID: CalnoraProductID.lifetimePro,
                title: "Buy Lifetime",
                purchasedTitle: "Lifetime Owned"
            )
            .label { state in
                HStack {
                    Text(lifetimeButtonTitle(for: state))
                    Spacer()
                    Text(purchaseStore.storeKitService.product(for: CalnoraProductID.lifetimePro)?.displayPrice ?? "")
                        .font(.headline.monospacedDigit())
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(purchaseStore.storeKitService.product(for: CalnoraProductID.lifetimePro) == nil)
            .onChange(of: purchaseStore.storeKitService.purchasedNonConsumables) { _, owned in
                guard owned.contains(CalnoraProductID.lifetimePro) else { return }
                purchaseStore.purchaseState = .purchased
                purchaseStore.persistSnapshot()
            }
        }
        .calnoraCard(tint: CalnoraColors.coach, isInteractive: true)
    }

    private func subscriptionIcon(for tier: CalnoraSubscriptionTier, product: Product) -> Image {
        switch product.id {
        case CalnoraProductID.yearlyPro:
            Image(systemName: "crown")
        case CalnoraProductID.monthlyPro:
            Image(systemName: "sparkles")
        case CalnoraProductID.weeklyPro:
            Image(systemName: "calendar.badge.clock")
        default:
            Image(systemName: tier == .pro ? "checkmark.seal" : "circle")
        }
    }

    private func lifetimeButtonTitle(for state: FlexStoreNonConsumablePurchaseState) -> String {
        switch state {
        case .purchasing:
            "Purchasing"
        case .purchased:
            "Lifetime Owned"
        default:
            "Buy Lifetime"
        }
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
