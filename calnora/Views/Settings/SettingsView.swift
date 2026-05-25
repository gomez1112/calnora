import FlexStore
import SwiftUI

struct SettingsView: View {
    @Environment(AppRouter.self) private var router
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
                Button("Export data", systemImage: "square.and.arrow.up") {
                    notificationStore.show(
                        title: "Export placeholder",
                        message: "Data export is reserved for the next build slice.",
                        symbolName: "square.and.arrow.up"
                    )
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
}
