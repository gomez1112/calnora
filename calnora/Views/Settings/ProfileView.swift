import SwiftUI

struct ProfileView: View {
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @Environment(NotificationStore.self) private var notificationStore

    var body: some View {
        let profile = userProfileStore.ensureProfile()
        let goal = nutritionGoalStore.ensureGoal()
        @Bindable var editableProfile = profile
        @Bindable var editableGoal = goal

        Form {
            Section("Profile") {
                TextField("Display name", text: $editableProfile.displayName)
                Picker("Goal", selection: $editableProfile.goal) {
                    ForEach(GoalType.allCases) { goal in
                        Text(goal.title).tag(goal)
                    }
                }
                Picker("Age range", selection: $editableProfile.ageRange) {
                    ForEach(AgeRange.allCases) { ageRange in
                        Text(ageRange.title).tag(ageRange)
                    }
                }
                Picker("Activity", selection: $editableProfile.activityLevel) {
                    ForEach(ActivityLevel.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                Picker("Units", selection: $editableProfile.preferredUnits) {
                    ForEach(PreferredUnits.allCases) { units in
                        Text(units.title).tag(units)
                    }
                }
                HStack {
                    TextField("Height", value: $editableProfile.height, format: .number)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    Text(editableProfile.preferredUnits.heightUnit)
                        .foregroundStyle(.secondary)
                    TextField("Weight", value: $editableProfile.weight, format: .number)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    Text(editableProfile.preferredUnits.weightUnit)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Diet") {
                Picker("Preference", selection: $editableProfile.dietaryPreference) {
                    ForEach(DietaryPreference.allCases) { preference in
                        Text(preference.title).tag(preference)
                    }
                }
                TextField(
                    "Allergies",
                    text: Binding(
                        get: { profile.allergies.joined(separator: ", ") },
                        set: { profile.allergies = Self.splitCommaSeparatedList($0) }
                    ),
                    axis: .vertical
                )
                TextField(
                    "Foods to avoid",
                    text: Binding(
                        get: { profile.avoidedFoods.joined(separator: ", ") },
                        set: { profile.avoidedFoods = Self.splitCommaSeparatedList($0) }
                    ),
                    axis: .vertical
                )
            }

            Section {
                TextField("Calories", value: $editableGoal.calories, format: .number)
                TextField("Protein", value: $editableGoal.protein, format: .number)
                TextField("Carbs", value: $editableGoal.carbs, format: .number)
                TextField("Fat", value: $editableGoal.fat, format: .number)
                TextField("Fiber", value: $editableGoal.fiber, format: .number)
                TextField("Water", value: $editableGoal.water, format: .number)
                Button("Recalculate from profile", systemImage: "wand.and.stars") {
                    nutritionGoalStore.recalculate(from: profile)
                    notificationStore.show(
                        title: "Targets updated",
                        message: "Your starting targets were recalculated from your profile.",
                        symbolName: "target"
                    )
                }
            } header: {
                Text("Nutrition Targets")
            } footer: {
                Text("Targets are planning estimates, not medical advice. You can edit them any time.")
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    userProfileStore.saveChanges()
                    nutritionGoalStore.saveChanges()
                    notificationStore.show(
                        title: "Profile saved",
                        message: "Your Calnora preferences are updated.",
                        symbolName: "checkmark.circle.fill"
                    )
                }
            }
        }
    }

    private static func splitCommaSeparatedList(_ text: String) -> [String] {
        text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
