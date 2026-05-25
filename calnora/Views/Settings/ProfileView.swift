import SwiftUI

struct ProfileView: View {
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore

    var body: some View {
        let profile = userProfileStore.ensureProfile()
        let goal = nutritionGoalStore.ensureGoal()

        Form {
            Section("Profile") {
                LabeledContent("Name", value: profile.displayName.isEmpty ? "Not set" : profile.displayName)
                LabeledContent("Goal", value: profile.goal.title)
                LabeledContent("Activity", value: profile.activityLevel.title)
                LabeledContent("Units", value: profile.preferredUnits.rawValue.capitalized)
            }

            Section("Nutrition Targets") {
                HealthMetricCard(title: "Calories", value: goal.calories, target: nil, unit: "cal", symbolName: "flame.fill", tint: CalnoraColors.calories)
                HealthMetricCard(title: "Protein", value: goal.protein, target: nil, unit: "g", symbolName: "bolt.fill", tint: CalnoraColors.protein)
                HealthMetricCard(title: "Carbs", value: goal.carbs, target: nil, unit: "g", symbolName: "leaf.fill", tint: CalnoraColors.carbs)
                HealthMetricCard(title: "Fat", value: goal.fat, target: nil, unit: "g", symbolName: "drop.fill", tint: CalnoraColors.fat)
            }
        }
        .navigationTitle("Profile")
    }
}
