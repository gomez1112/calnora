import SwiftData
import SwiftUI

@main
struct CalnoraApp: App {
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment.appState)
                .environment(environment.router)
                .environment(environment.userProfileStore)
                .environment(environment.nutritionGoalStore)
                .environment(environment.mealStore)
                .environment(environment.coachStore)
                .environment(environment.purchaseStore)
                .environment(environment.notificationStore)
                .environment(environment.purchaseStore.storeKitService)
                .modelContainer(environment.modelContainer)
        }

        #if os(macOS)
        Settings {
            SettingsView()
                .environment(environment.appState)
                .environment(environment.router)
                .environment(environment.userProfileStore)
                .environment(environment.nutritionGoalStore)
                .environment(environment.purchaseStore)
                .environment(environment.notificationStore)
                .environment(environment.purchaseStore.storeKitService)
                .modelContainer(environment.modelContainer)
                .frame(minWidth: 560, minHeight: 640)
        }
        #endif
    }
}
