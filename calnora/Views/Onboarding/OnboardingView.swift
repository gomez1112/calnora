import OnboardingKit
import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = OnboardingModel()

    var body: some View {
        Group {
            if model.hasFinishedIntro {
                OnboardingSetupView(model: model) {
                    Task { await finishOnboarding() }
                }
            } else {
                PagedOnboardingView(
                    appName: "Calnora",
                    pages: model.pages,
                    tintColor: CalnoraColors.coach
                ) {
                    withAnimation(.smooth) {
                        model.hasFinishedIntro = true
                    }
                }
            }
        }
    }

    private func finishOnboarding() async {
        let draft = model.profileDraft
        userProfileStore.update(from: draft, completesOnboarding: true)
        let profile = userProfileStore.ensureProfile()
        nutritionGoalStore.recalculate(from: profile)

        if draft.wantsReminders {
            await notificationStore.requestGentleReminders()
        }

        appState.hasCompletedOnboarding = true
        notificationStore.show(
            title: "Welcome to Calnora",
            message: "Your private dashboard is ready.",
            symbolName: "sparkles"
        )
    }
}

private struct OnboardingSetupView: View {
    @Bindable var model: OnboardingModel
    var finish: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CalnoraSpacing.large) {
                header
                profileSection
                goalsSection
                preferencesSection
                remindersSection
                disclaimerSection
                proIntroSection

                Button("Start Calnora", systemImage: "checkmark.circle.fill", action: finish)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .disabled(!model.canFinishSetup)
                    .accessibilityHint("Completes onboarding and creates your starting nutrition targets.")
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(CalnoraColors.groupedBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraArtworkView(
                assetName: "onboarding_welcome_hero",
                systemImage: "sparkles",
                tint: CalnoraColors.coach
            )
                .frame(height: 180)
                .clipShape(.rect(cornerRadius: 26, style: .continuous))
                .accessibilityHidden(true)

            Text("Set up your private coach")
                .font(.largeTitle.bold())
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            Text("These values create a starting point only. Calnora keeps estimates editable and focuses on awareness, consistency, and supportive guidance.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Profile", subtitle: "Approximate details are enough.")
            TextField("Display name", text: $model.displayName)
                .textFieldStyle(.roundedBorder)
                .textContentType(.givenName)
            Picker("Age range", selection: $model.ageRange) {
                ForEach(AgeRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            Picker("Units", selection: $model.preferredUnits) {
                ForEach(PreferredUnits.allCases) { units in
                    Text(units.title).tag(units)
                }
            }
            HStack(spacing: CalnoraSpacing.medium) {
                TextField("Height", value: $model.height, format: .number)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                Text(model.preferredUnits.heightUnit)
                    .foregroundStyle(.secondary)
                TextField("Weight", value: $model.weight, format: .number)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                Text(model.preferredUnits.weightUnit)
                    .foregroundStyle(.secondary)
            }
            .textFieldStyle(.roundedBorder)
        }
        .calnoraCard(tint: CalnoraColors.protein)
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Goals", subtitle: "No promises, no pressure.")
            Picker("Goal", selection: $model.selectedGoal) {
                ForEach(GoalType.allCases) { goal in
                    Text(goal.title).tag(goal)
                }
            }
            Picker("Activity", selection: $model.activityLevel) {
                ForEach(ActivityLevel.allCases) { level in
                    Text(level.title).tag(level)
                }
            }
        }
        .calnoraCard(tint: CalnoraColors.calories)
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Preferences", subtitle: "Used as context for estimates and meal ideas.")
            Picker("Diet", selection: $model.dietaryPreference) {
                ForEach(DietaryPreference.allCases) { preference in
                    Text(preference.title).tag(preference)
                }
            }
            TextField("Allergies, separated by commas", text: $model.allergiesText, axis: .vertical)
                .lineLimit(1...3)
                .textFieldStyle(.roundedBorder)
            TextField("Foods to avoid, separated by commas", text: $model.avoidedFoodsText, axis: .vertical)
                .lineLimit(1...3)
                .textFieldStyle(.roundedBorder)
        }
        .calnoraCard(tint: CalnoraColors.fat)
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Reminders", subtitle: "Optional and gentle.")
            Toggle(isOn: $model.wantsReminders) {
                Label("Enable gentle reminders", systemImage: "bell.badge")
            }
            Text("Examples include hydration check-ins, lunch logging, and daily summaries. No guilt-based reminders.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .calnoraCard(tint: CalnoraColors.water)
    }

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            CalnoraSectionHeader(title: "Health Disclaimer", subtitle: "Informational wellness guidance only.")
            Text("Calnora does not diagnose, treat, replace professional care, or claim AI nutrition estimates are exact. If you have a medical condition or nutrition concern, work with a qualified professional.")
                .foregroundStyle(.secondary)
            Toggle(isOn: $model.acceptedDisclaimer) {
                Text("I understand nutrition estimates are approximate.")
            }
        }
        .calnoraCard(tint: CalnoraColors.warning)
    }

    private var proIntroSection: some View {
        WalletPassCard(
            title: "Optional Pro",
            subtitle: "Unlock unlimited AI estimates, coach chat, weekly insights, and premium trend cards when you are ready.",
            systemImage: "sparkles",
            footnote: "You can continue with free manual logging today."
        )
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .environment(UserProfileStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NotificationStore())
}
