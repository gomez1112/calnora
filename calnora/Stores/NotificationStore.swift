import Foundation
import GentleNotification
import Observation

@Observable
final class NotificationStore {
    var latestBanner: CalnoraBanner?
    var permissionStatus: GNPermissionStatus = .notDetermined

    func show(title: String, message: String, symbolName: String) {
        latestBanner = CalnoraBanner(title: title, message: message, symbolName: symbolName)
    }

    func mealSaved() {
        show(title: "Meal saved", message: "Your entry is in today's log.", symbolName: "checkmark.circle.fill")
    }

    func aiEstimateReady() {
        show(title: "Estimate ready", message: "Review and edit before saving.", symbolName: "sparkles")
    }

    func purchaseSuccessful() {
        show(title: "Purchase complete", message: "Your Calnora access is updated.", symbolName: "checkmark.seal.fill")
    }

    func restoreComplete() {
        show(title: "Restore complete", message: "Your purchases have been refreshed.", symbolName: "arrow.clockwise.circle.fill")
    }

    func refreshPermissionStatus() async {
        permissionStatus = await Notify.permissionStatus()
    }

    func requestGentleReminders() async {
        do {
            let granted = try await Notify.requestAuthorization()
            permissionStatus = granted ? .authorized : .denied
            if granted {
                show(title: "Reminders enabled", message: "Calnora will keep them gentle.", symbolName: "bell.badge")
            }
        } catch {
            show(title: "Reminder issue", message: error.localizedDescription, symbolName: "exclamationmark.triangle")
        }
    }

    func scheduleHydrationReminder() async {
        do {
            try await Notify.schedule(
                title: "Hydration check-in",
                body: "A small water break can help your routine.",
                in: .hours(3),
                threadID: "calnora.hydration"
            )
        } catch {
            show(title: "Reminder issue", message: error.localizedDescription, symbolName: "exclamationmark.triangle")
        }
    }
}
