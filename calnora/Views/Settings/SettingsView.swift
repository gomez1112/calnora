import FlexStore
import SwiftUI

struct SettingsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @Environment(MealStore.self) private var mealStore
    @Environment(CoachStore.self) private var coachStore
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = SettingsModel()
    @State private var hasAppeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: CalnoraSpacing.large) {
                greetingHeader

                profileCard
                    .stagger(0, hasAppeared: hasAppeared)

                notificationsCard
                    .stagger(1, hasAppeared: hasAppeared)

                purchasesCard
                    .stagger(2, hasAppeared: hasAppeared)

                privacyCard
                    .stagger(3, hasAppeared: hasAppeared)

                aboutCard
                    .stagger(4, hasAppeared: hasAppeared)
            }
            .calnoraScreenContent(maxWidth: CalnoraSpacing.readableMaxWidth)
        }
        .calnoraAmbientBackground()
        .scrollIndicators(.hidden)
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .onAppear { animateIn() }
        .alert("Health Disclaimer", isPresented: $model.showingDisclaimer) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Calnora provides informational wellness guidance only. It does not diagnose, treat, or replace professional medical advice.")
        }
    }

    // MARK: - Header

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Settings")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.4)
                Text("Calnora")
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
            Spacer()
            statusChip
        }
        .padding(.horizontal, CalnoraSpacing.xSmall)
    }

    @ViewBuilder
    private var statusChip: some View {
        if purchaseStore.entitlements.unlocksPro {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption.weight(.semibold))
                Text("Pro")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(CalnoraColors.success)
            .padding(.horizontal, CalnoraSpacing.small)
            .padding(.vertical, 6)
            .background(CalnoraColors.success.opacity(0.16), in: .capsule)
        } else {
            Button {
                router.push(.paywall, in: .dashboard)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.semibold))
                    Text("Upgrade")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, CalnoraSpacing.small)
                .padding(.vertical, 6)
                .background(CalnoraColors.coach.gradient, in: .capsule)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Profile

    private var profileCard: some View {
        sectionCard(title: "Profile") {
            settingsRow(
                title: "Profile and preferences",
                subtitle: "Identity, body, diet, targets",
                symbol: "person.crop.circle",
                tint: CalnoraColors.protein
            ) {
                router.push(.profile, in: .dashboard)
            }
            rowDivider
            settingsRow(
                title: "Replay onboarding",
                subtitle: "Walk through the setup again",
                symbol: "arrow.uturn.left.circle",
                tint: CalnoraColors.coach
            ) {
                appState.hasCompletedOnboarding = false
            }
        }
    }

    // MARK: - Notifications

    private var notificationsCard: some View {
        sectionCard(title: "Notifications") {
            settingsRow(
                title: "Enable gentle reminders",
                subtitle: "Ask iOS permission",
                symbol: "bell.badge",
                tint: CalnoraColors.coach
            ) {
                Task { await notificationStore.requestGentleReminders() }
            }
            rowDivider
            settingsRow(
                title: "Hydration reminder",
                subtitle: "Schedule a water nudge",
                symbol: "drop.fill",
                tint: CalnoraColors.water
            ) {
                Task { await notificationStore.scheduleHydrationReminder() }
            }
            rowDivider
            settingsRow(
                title: "Lunch reminder",
                subtitle: "Mid-day nudge",
                symbol: "fork.knife",
                tint: CalnoraColors.calories
            ) {
                Task { await notificationStore.scheduleLunchReminder() }
            }
            rowDivider
            settingsRow(
                title: "Daily summary",
                subtitle: "Evening recap",
                symbol: "list.bullet.clipboard",
                tint: CalnoraColors.carbs
            ) {
                Task { await notificationStore.scheduleDailySummaryReminder() }
            }
        }
    }

    // MARK: - Purchases

    private var purchasesCard: some View {
        sectionCard(title: "Purchases") {
            if !purchaseStore.entitlements.unlocksPro {
                settingsRow(
                    title: "Upgrade to Pro",
                    subtitle: "Unlimited AI coaching",
                    symbol: "sparkles",
                    tint: CalnoraColors.coach,
                    accent: true
                ) {
                    router.push(.paywall, in: .dashboard)
                }
                rowDivider
            }
            settingsRow(
                title: "High Protein Pack",
                subtitle: "Premium meal templates",
                symbol: "takeoutbag.and.cup.and.straw",
                tint: CalnoraColors.protein
            ) {
                router.push(.premiumPack, in: .dashboard)
            }
            rowDivider
            manageSubscriptionsRow
            rowDivider
            settingsRow(
                title: "Restore purchases",
                subtitle: "Sync past transactions",
                symbol: "arrow.clockwise",
                tint: CalnoraColors.success
            ) {
                Task {
                    await purchaseStore.storeKitService.restorePurchases()
                    purchaseStore.persistSnapshot()
                    notificationStore.restoreComplete()
                }
            }
        }
    }

    private var manageSubscriptionsRow: some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: "creditcard.fill")
                .font(.subheadline)
                .foregroundStyle(CalnoraColors.fat)
                .frame(width: 36, height: 36)
                .background(CalnoraColors.fat.opacity(0.14), in: .circle)
            VStack(alignment: .leading, spacing: 1) {
                Text("Manage subscriptions")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Apple's subscription sheet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ManageSubscriptionsButton()
                .labelStyle(.iconOnly)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(CalnoraColors.coach)
        }
        .padding(.vertical, CalnoraSpacing.small + 2)
        .padding(.horizontal, CalnoraSpacing.medium)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Privacy

    private var privacyCard: some View {
        sectionCard(title: "Privacy and safety") {
            settingsRow(
                title: "Privacy",
                subtitle: "What stays on this device",
                symbol: "hand.raised",
                tint: CalnoraColors.success
            ) {
                router.push(.privacy, in: .dashboard)
            }
            rowDivider
            settingsRow(
                title: "Health disclaimer",
                subtitle: "Informational only",
                symbol: "checkmark.shield",
                tint: CalnoraColors.fat
            ) {
                model.showingDisclaimer = true
            }
            rowDivider
            exportRow
            if let exportURL = model.exportURL {
                rowDivider
                ShareLink(item: exportURL) {
                    settingsRowLayout(
                        title: "Share latest export",
                        subtitle: exportURL.lastPathComponent,
                        symbol: "doc.badge.arrow.up",
                        tint: CalnoraColors.coach,
                        trailing: AnyView(
                            Image(systemName: "square.and.arrow.up")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        )
                    )
                }
                .buttonStyle(.plain)
            }
            if let error = model.exportErrorMessage {
                rowDivider
                HStack(spacing: CalnoraSpacing.medium) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(CalnoraColors.warning)
                        .frame(width: 36, height: 36)
                        .background(CalnoraColors.warning.opacity(0.16), in: .circle)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, CalnoraSpacing.small + 2)
                .padding(.horizontal, CalnoraSpacing.medium)
            }
        }
    }

    private var exportRow: some View {
        Button {
            Task { await exportData() }
        } label: {
            settingsRowLayout(
                title: model.isExporting ? "Exporting data" : "Export data",
                subtitle: "JSON snapshot of your data",
                symbol: model.isExporting ? "hourglass" : "square.and.arrow.up",
                tint: CalnoraColors.calories,
                trailing: model.isExporting
                    ? AnyView(ProgressView().controlSize(.small))
                    : AnyView(
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(model.isExporting)
    }

    // MARK: - About

    private var aboutCard: some View {
        sectionCard(title: "About") {
            aboutRow(label: "App", value: "Calnora")
            rowDivider
            aboutRow(label: "Bundle ID", value: "com.gerardgomez.calnora")
            rowDivider
            aboutRow(label: "SKU", value: "CALNORA-001")
        }
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, CalnoraSpacing.small + 2)
        .padding(.horizontal, CalnoraSpacing.medium)
    }

    // MARK: - Section card

    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
                .padding(.horizontal, CalnoraSpacing.xSmall)

            VStack(spacing: 0) {
                content()
            }
            .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius)
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(.secondary.opacity(0.12))
            .frame(height: 0.5)
            .padding(.leading, 64)
    }

    private func settingsRow(
        title: String,
        subtitle: String?,
        symbol: String,
        tint: Color,
        accent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            settingsRowLayout(
                title: title,
                subtitle: subtitle,
                symbol: symbol,
                tint: tint,
                accent: accent,
                trailing: AnyView(
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                )
            )
        }
        .buttonStyle(.plain)
    }

    private func settingsRowLayout(
        title: String,
        subtitle: String?,
        symbol: String,
        tint: Color,
        accent: Bool = false,
        trailing: AnyView
    ) -> some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: symbol)
                .font(.subheadline)
                .foregroundStyle(accent ? AnyShapeStyle(tint.gradient) : AnyShapeStyle(tint))
                .frame(width: 36, height: 36)
                .background(tint.opacity(accent ? 0.20 : 0.14), in: .circle)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            trailing
        }
        .padding(.vertical, CalnoraSpacing.small + 2)
        .padding(.horizontal, CalnoraSpacing.medium)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Actions

    private func exportData() async {
        model.isExporting = true
        model.exportErrorMessage = nil
        defer { model.isExporting = false }

        let snapshot = CalnoraExportSnapshot(
            userProfileStore: userProfileStore,
            nutritionGoalStore: nutritionGoalStore,
            mealStore: mealStore,
            coachStore: coachStore,
            purchaseStore: purchaseStore
        )

        do {
            model.exportURL = try await DataExportService().export(snapshot)
            notificationStore.show(
                title: "Export ready",
                message: "Your Calnora data export is ready to share.",
                symbolName: "square.and.arrow.up"
            )
        } catch {
            model.exportErrorMessage = error.localizedDescription
            notificationStore.show(
                title: "Export issue",
                message: error.localizedDescription,
                symbolName: "exclamationmark.triangle"
            )
        }
    }

    private func animateIn() {
        guard !hasAppeared else { return }
        withAnimation(.smooth(duration: 0.7)) {
            hasAppeared = true
        }
    }
}
