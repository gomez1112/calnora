import OnboardingKit
import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = OnboardingModel()

    var body: some View {
        PagedOnboardingView(
            appName: "Calnora",
            pages: model.pages,
            tintColor: CalnoraColors.coach
        ) {
            userProfileStore.completeOnboarding()
            appState.hasCompletedOnboarding = true
            notificationStore.show(
                title: "Welcome to Calnora",
                message: "Your private dashboard is ready.",
                symbolName: "sparkles"
            )
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .environment(UserProfileStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NotificationStore())
}
