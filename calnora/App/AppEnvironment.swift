import EZSwiftData
import Foundation
import Observation
import SwiftData

@Observable
final class AppEnvironment {
    let modelContainer: ModelContainer
    let appState: AppState
    let router: AppRouter
    let userProfileStore: UserProfileStore
    let nutritionGoalStore: NutritionGoalStore
    let mealStore: MealStore
    let coachStore: CoachStore
    let purchaseStore: PurchaseStore
    let notificationStore: NotificationStore

    init(
        modelContainer: ModelContainer,
        appState: AppState,
        router: AppRouter,
        userProfileStore: UserProfileStore,
        nutritionGoalStore: NutritionGoalStore,
        mealStore: MealStore,
        coachStore: CoachStore,
        purchaseStore: PurchaseStore,
        notificationStore: NotificationStore
    ) {
        self.modelContainer = modelContainer
        self.appState = appState
        self.router = router
        self.userProfileStore = userProfileStore
        self.nutritionGoalStore = nutritionGoalStore
        self.mealStore = mealStore
        self.coachStore = coachStore
        self.purchaseStore = purchaseStore
        self.notificationStore = notificationStore
    }

    static func live() -> AppEnvironment {
        let container = PersistenceController.makeModelContainer()
        let appState = AppState()
        let router = AppRouter()
        let userProfileStore = UserProfileStore(context: container.mainContext)
        let nutritionGoalStore = NutritionGoalStore(context: container.mainContext)
        let mealStore = MealStore(context: container.mainContext)
        let purchaseStore = PurchaseStore()
        let notificationStore = NotificationStore()
        let coachStore = CoachStore(
            engine: CoachEngineAvailability.makeEngine(),
            mealStore: mealStore,
            nutritionGoalStore: nutritionGoalStore
        )

        return AppEnvironment(
            modelContainer: container,
            appState: appState,
            router: router,
            userProfileStore: userProfileStore,
            nutritionGoalStore: nutritionGoalStore,
            mealStore: mealStore,
            coachStore: coachStore,
            purchaseStore: purchaseStore,
            notificationStore: notificationStore
        )
    }
}

enum PersistenceController {
    static let modelTypes: [any PersistentModel.Type] = [
        UserProfile.self,
        NutritionGoal.self,
        MealEntry.self,
        FoodItem.self,
        FavoriteMeal.self,
        WaterEntry.self,
        WeightEntry.self,
        CoachMessage.self,
        CoachInsight.self,
        PurchaseSnapshot.self,
        PremiumContentPack.self
    ]

    static func makeModelContainer(inMemory: Bool = false) -> ModelContainer {
        do {
            return try ModelContainerFactory.create(
                for: modelTypes,
                isStoredInMemoryOnly: inMemory
            )
        } catch {
            preconditionFailure("Unable to create Calnora SwiftData container: \(error)")
        }
    }
}
