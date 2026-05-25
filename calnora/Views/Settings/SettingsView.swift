import FlexStore
import SwiftUI

struct SettingsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @Environment(MealStore.self) private var mealStore
    @Environment(CoachStore.self) private var coachStore
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = SettingsModel()

    var body: some View {
        List {
            Section("Profile") {
                Button("Profile and preferences", systemImage: "person.crop.circle") {
                    router.push(.profile, in: .settings)
                }
                Button("Goals", systemImage: "target") {
                    router.push(.profile, in: .settings)
                }
                Button("Units", systemImage: "ruler") {
                    router.push(.profile, in: .settings)
                }
            }

            Section("Notifications") {
                Button("Enable gentle reminders", systemImage: "bell.badge") {
                    Task { await notificationStore.requestGentleReminders() }
                }
                Button("Schedule hydration reminder", systemImage: "drop.fill") {
                    Task { await notificationStore.scheduleHydrationReminder() }
                }
                Button("Schedule lunch reminder", systemImage: "fork.knife") {
                    Task { await notificationStore.scheduleLunchReminder() }
                }
                Button("Schedule daily summary", systemImage: "list.bullet.clipboard") {
                    Task { await notificationStore.scheduleDailySummaryReminder() }
                }
            }

            Section("Purchases") {
                Button("Upgrade to Pro", systemImage: "sparkles") {
                    router.push(.paywall, in: .settings)
                }
                Button("High Protein Pack", systemImage: "takeoutbag.and.cup.and.straw") {
                    router.push(.premiumPack, in: .settings)
                }
                ManageSubscriptionsButton()
                Button("Restore Purchases", systemImage: "arrow.clockwise") {
                    Task {
                        await purchaseStore.restorePurchases()
                        notificationStore.restoreComplete()
                    }
                }
            }

            Section("Privacy and Safety") {
                Button("Privacy", systemImage: "hand.raised") {
                    router.push(.privacy, in: .settings)
                }
                Button("Health disclaimer", systemImage: "checkmark.shield") {
                    model.showingDisclaimer = true
                }
                Button {
                    Task { await exportData() }
                } label: {
                    if model.isExporting {
                        Label("Exporting data", systemImage: "hourglass")
                    } else {
                        Label("Export data", systemImage: "square.and.arrow.up")
                    }
                }
                .disabled(model.isExporting)

                if let exportURL = model.exportURL {
                    ShareLink(item: exportURL) {
                        Label("Share latest export", systemImage: "doc.badge.arrow.up")
                    }
                }

                if let error = model.exportErrorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(CalnoraColors.warning)
                }
            }

            Section("About") {
                LabeledContent("App", value: "Calnora")
                LabeledContent("Bundle ID", value: "com.gerardgomez.calnora")
                LabeledContent("SKU", value: "CALNORA-001")
            }
        }
        .navigationTitle("Settings")
        .alert("Health Disclaimer", isPresented: $model.showingDisclaimer) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Calnora provides informational wellness guidance only. It does not diagnose, treat, or replace professional medical advice.")
        }
    }

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
}
