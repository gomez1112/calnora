import FlexStore
import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = PaywallModel()

    private let policies = SubscriptionStorePolicies(
        privacyPolicyURL: URL(string: "https://example.com/privacy"),
        termsOfServiceURL: URL(string: "https://example.com/terms")
    )

    var body: some View {
        FlexSubscriptionPaywall<CalnoraSubscriptionTier, _, _, _>(
            groupID: CalnoraProductID.subscriptionGroupID,
            sectionTitle: "What's included",
            features: model.features,
            iconProvider: { _, product in icon(for: product.id) },
            onPurchaseCompletion: { _ in handlePurchaseSuccess() },
            policies: policies
        ) {
            backgroundView
        } header: {
            headerView
        } featureRow: { feature in
            FlexDefaultFeatureRow(feature)
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .overlay(alignment: .topLeading) { closeButton }
        .onChange(of: purchaseStore.storeKitService.subscriptionTier) { _, tier in
            guard tier == .pro else { return }
            handlePurchaseSuccess()
        }
        .onChange(of: purchaseStore.storeKitService.purchasedNonConsumables) { _, owned in
            guard owned.contains(CalnoraProductID.lifetimePro) else { return }
            handlePurchaseSuccess()
        }
        .onChange(of: purchaseStore.purchaseState) { _, state in
            if state == .failed {
                notificationStore.show(
                    title: "Purchase issue",
                    message: purchaseStore.lastErrorMessage ?? "Please try again.",
                    symbolName: "exclamationmark.triangle"
                )
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: CalnoraSpacing.large) {
            heroBlock
            lifetimeCard
        }
        .padding(.top, 64)
        .padding(.horizontal, CalnoraSpacing.medium)
    }

    private var heroBlock: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.16))
                    .frame(width: 104, height: 104)
                Circle()
                    .stroke(.white.opacity(0.28), lineWidth: 1)
                    .frame(width: 104, height: 104)
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("Calnora Pro")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("Your private AI nutrition coach.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var lifetimeCard: some View {
        let product = purchaseStore.storeKitService.product(for: CalnoraProductID.lifetimePro)
        let isOwned = purchaseStore.storeKitService.purchasedNonConsumables.contains(CalnoraProductID.lifetimePro)

        return VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(spacing: CalnoraSpacing.medium) {
                Image(systemName: "infinity")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.18), in: .circle)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Lifetime Pro")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                        Text("ONE-TIME")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .tracking(0.8)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.white.opacity(0.20), in: .capsule)
                            .foregroundStyle(.white)
                    }
                    Text("Pay once. Yours forever.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer(minLength: 0)
                if let price = product?.displayPrice {
                    Text(price)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
            }

            NonConsumablePurchaseButton<CalnoraSubscriptionTier>(
                productID: CalnoraProductID.lifetimePro,
                title: "Buy Lifetime",
                purchasedTitle: "Lifetime Owned"
            )
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .disabled(product == nil || isOwned)
        }
        .padding(CalnoraSpacing.medium)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.12))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.46, blue: 0.62),
                    Color(red: 0.74, green: 0.39, blue: 0.86),
                    Color(red: 0.32, green: 0.30, blue: 0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [.white.opacity(0.20), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 380
            )
            RadialGradient(
                colors: [.white.opacity(0.10), .clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Close button

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.18), in: .circle)
                .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.top, 16)
        .padding(.leading, 16)
        .accessibilityLabel("Close")
    }

    // MARK: - Helpers

    private func icon(for productID: String) -> Image {
        switch productID {
        case CalnoraProductID.yearlyPro:
            Image(systemName: "crown")
        case CalnoraProductID.monthlyPro:
            Image(systemName: "sparkles")
        case CalnoraProductID.weeklyPro:
            Image(systemName: "calendar.badge.clock")
        default:
            Image(systemName: "checkmark.seal")
        }
    }

    private func handlePurchaseSuccess() {
        purchaseStore.purchaseState = .purchased
        purchaseStore.persistSnapshot()
        notificationStore.purchaseSuccessful()
        dismiss()
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
