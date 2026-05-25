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

    func scheduleLunchReminder() async {
        do {
            try await Notify.schedule(
                title: "Want to log lunch?",
                body: "A quick note is enough. You can edit details later.",
                in: .hours(4),
                threadID: "calnora.lunch"
            )
            show(title: "Lunch reminder set", message: "Calnora will keep it gentle.", symbolName: "fork.knife")
        } catch {
            show(title: "Reminder issue", message: error.localizedDescription, symbolName: "exclamationmark.triangle")
        }
    }

    func scheduleDailySummaryReminder() async {
        do {
            try await Notify.schedule(
                title: "Your daily summary is ready",
                body: "Review today with curiosity, not judgment.",
                in: .hours(8),
                threadID: "calnora.daily-summary"
            )
            show(title: "Daily summary set", message: "A calm check-in is scheduled.", symbolName: "list.bullet.clipboard")
        } catch {
            show(title: "Reminder issue", message: error.localizedDescription, symbolName: "exclamationmark.triangle")
        }
    }

    func quotaLimitReached() {
        show(
            title: "Weekly AI limit reached",
            message: "Manual logging remains unlimited. Pro unlocks unlimited AI estimates and coach questions.",
            symbolName: "sparkles"
        )
    }
}
