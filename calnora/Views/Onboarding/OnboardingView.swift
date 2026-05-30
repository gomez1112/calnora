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
        OnboardingFlow(
            tint: CalnoraColors.coach,
            progressStyle: .dots,
            onComplete: { await finishOnboarding() },
            steps: {
                for step in makeSteps() {
                    step
                }
            },
            customContent: { step in
                customContent(for: step.id)
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity)
            }
        )
        .calnoraAmbientBackground()
    }

    // MARK: - Steps

    private func makeSteps() -> [OnboardingStep] {
        [
            .welcome(
                id: "welcome",
                title: "Welcome to Calnora",
                subtitle: "Your private coach for awareness, consistency, and calm habits — no guilt, no exact-calorie promises.",
                systemImage: "sparkles"
            ),
            .custom(
                id: "name",
                title: "What should we call you?",
                subtitle: "Just a friendly first name. It stays on this device.",
                systemImage: "person.crop.circle",
                isComplete: { !model.trimmedDisplayName.isEmpty }
            ),
            .custom(
                id: "goal",
                title: "What brings you here?",
                subtitle: "Pick a direction — you can change this anytime.",
                systemImage: "scope"
            ),
            .custom(
                id: "body",
                title: "A few quick details",
                subtitle: "Used once to build your starting calorie target.",
                systemImage: "ruler",
                isComplete: { model.height > 0 && model.weight > 0 }
            ),
            .custom(
                id: "activity",
                title: "How active are you?",
                subtitle: "Activity is context — not judgment.",
                systemImage: "figure.walk"
            ),
            .custom(
                id: "diet",
                title: "Any dietary preferences?",
                subtitle: "Helps tailor AI estimates and meal ideas. Optional.",
                systemImage: "leaf",
                isRequired: false
            ),
            .custom(
                id: "disclaimer",
                title: "One quick note",
                subtitle: "Calnora is informational wellness guidance — not medical advice.",
                systemImage: "checkmark.shield",
                isComplete: { model.acceptedDisclaimer }
            )
        ]
    }

    @ViewBuilder
    private func customContent(for stepID: String) -> some View {
        switch stepID {
        case "name":     NameStep(model: model)
        case "goal":     GoalStep(model: model)
        case "body":     BodyStep(model: model)
        case "activity": ActivityStep(model: model)
        case "diet":     DietStep(model: model)
        case "disclaimer": DisclaimerStep(model: model)
        default: EmptyView()
        }
    }

    // MARK: - Completion

    private func finishOnboarding() async {
        let draft = model.profileDraft
        userProfileStore.update(from: draft, completesOnboarding: true)
        let profile = userProfileStore.ensureProfile()
        nutritionGoalStore.recalculate(from: profile)

        if draft.wantsReminders {
            await notificationStore.requestGentleReminders()
        }

        appState.hasCompletedOnboarding = true
        let greeting = draft.displayName.isEmpty ? "Welcome to Calnora" : "Welcome, \(draft.displayName)"
        notificationStore.show(
            title: greeting,
            message: "Your private dashboard is ready.",
            symbolName: "sparkles"
        )
    }
}

// MARK: - Custom step content

private struct NameStep: View {
    @Bindable var model: OnboardingModel
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            TextField("First name", text: $model.displayName)
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .multilineTextAlignment(.center)
                .textContentType(.givenName)
                #if os(iOS)
                .textInputAutocapitalization(.words)
                #endif
                .submitLabel(.next)
                .focused($focused)
                .padding(.vertical, CalnoraSpacing.medium)
                .padding(.horizontal, CalnoraSpacing.large)
                .background(.regularMaterial, in: .rect(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(CalnoraColors.coach.opacity(focused ? 0.45 : 0.15), lineWidth: 1)
                )
                .padding(.horizontal, CalnoraSpacing.large)
                .onAppear { focused = true }
        }
    }
}

private struct GoalStep: View {
    @Bindable var model: OnboardingModel

    var body: some View {
        VStack(spacing: CalnoraSpacing.small) {
            ForEach(GoalType.allCases) { goal in
                PillChoice(
                    title: goal.title,
                    subtitle: subtitle(for: goal),
                    symbol: symbol(for: goal),
                    isSelected: model.selectedGoal == goal,
                    tint: CalnoraColors.coach
                ) {
                    model.selectedGoal = goal
                }
            }
        }
        .padding(.horizontal, CalnoraSpacing.large)
    }

    private func subtitle(for goal: GoalType) -> String {
        switch goal {
        case .maintain: "Hold steady at where you are."
        case .gentleDeficit: "Lean toward a small, sustainable deficit."
        case .buildMuscle: "Eat to support training and growth."
        case .improveHabits: "Build consistency without numbers chasing."
        }
    }

    private func symbol(for goal: GoalType) -> String {
        switch goal {
        case .maintain: "equal.circle"
        case .gentleDeficit: "arrow.down.right.circle"
        case .buildMuscle: "dumbbell"
        case .improveHabits: "leaf.circle"
        }
    }
}

private struct BodyStep: View {
    @Bindable var model: OnboardingModel

    var body: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            unitsPicker

            agePicker

            HStack(spacing: CalnoraSpacing.medium) {
                numberField(label: "Height", value: $model.height, unit: model.preferredUnits.heightUnit)
                numberField(label: "Weight", value: $model.weight, unit: model.preferredUnits.weightUnit)
            }
        }
        .padding(.horizontal, CalnoraSpacing.large)
    }

    private var unitsPicker: some View {
        Picker("Units", selection: $model.preferredUnits) {
            ForEach(PreferredUnits.allCases) { units in
                Text(units.title).tag(units)
            }
        }
        .pickerStyle(.segmented)
    }

    private var agePicker: some View {
        Picker("Age range", selection: $model.ageRange) {
            ForEach(AgeRange.allCases) { range in
                Text(range.title).tag(range)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CalnoraSpacing.medium)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: .rect(cornerRadius: 14, style: .continuous))
        .tint(CalnoraColors.coach)
    }

    private func numberField(label: String, value: Binding<Double>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
            HStack(spacing: 4) {
                TextField("0", value: value, format: .number)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .multilineTextAlignment(.leading)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                Text(unit)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, CalnoraSpacing.medium)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: .rect(cornerRadius: 14, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityStep: View {
    @Bindable var model: OnboardingModel

    var body: some View {
        VStack(spacing: CalnoraSpacing.small) {
            ForEach(ActivityLevel.allCases) { level in
                PillChoice(
                    title: level.title,
                    subtitle: subtitle(for: level),
                    symbol: symbol(for: level),
                    isSelected: model.activityLevel == level,
                    tint: CalnoraColors.water
                ) {
                    model.activityLevel = level
                }
            }
        }
        .padding(.horizontal, CalnoraSpacing.large)
    }

    private func subtitle(for level: ActivityLevel) -> String {
        switch level {
        case .low: "Mostly sitting through the day."
        case .light: "Light walking, occasional movement."
        case .moderate: "A few workouts a week."
        case .active: "Daily training or active job."
        case .veryActive: "Heavy training or very active job."
        }
    }

    private func symbol(for level: ActivityLevel) -> String {
        switch level {
        case .low: "figure.seated.side"
        case .light: "figure.walk"
        case .moderate: "figure.run"
        case .active: "figure.strengthtraining.traditional"
        case .veryActive: "flame"
        }
    }
}

private struct DietStep: View {
    @Bindable var model: OnboardingModel

    var body: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            VStack(spacing: CalnoraSpacing.small) {
                ForEach(DietaryPreference.allCases) { pref in
                    PillChoice(
                        title: pref.title,
                        subtitle: nil,
                        symbol: "leaf.fill",
                        isSelected: model.dietaryPreference == pref,
                        tint: CalnoraColors.fat,
                        compact: true
                    ) {
                        model.dietaryPreference = pref
                    }
                }
            }

            TextField("Allergies (comma separated)", text: $model.allergiesText, axis: .vertical)
                .font(.system(.subheadline, design: .rounded))
                .lineLimit(1...2)
                .padding(.horizontal, CalnoraSpacing.medium)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: .rect(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal, CalnoraSpacing.large)
    }
}

private struct DisclaimerStep: View {
    @Bindable var model: OnboardingModel

    var body: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            Text("Calnora does not diagnose, treat, replace professional care, or claim AI nutrition estimates are exact. If you have a medical condition or nutrition concern, work with a qualified professional.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                model.acceptedDisclaimer.toggle()
            } label: {
                HStack(spacing: CalnoraSpacing.small) {
                    Image(systemName: model.acceptedDisclaimer ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(model.acceptedDisclaimer ? CalnoraColors.success : .secondary)
                    Text("I understand estimates are approximate.")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                .padding(CalnoraSpacing.medium)
                .background(.regularMaterial, in: .rect(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(model.acceptedDisclaimer ? CalnoraColors.success.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)

            Toggle(isOn: $model.wantsReminders) {
                Label("Send gentle reminders", systemImage: "bell.badge")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
            .tint(CalnoraColors.coach)
            .padding(CalnoraSpacing.medium)
            .background(.regularMaterial, in: .rect(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal, CalnoraSpacing.large)
    }
}

// MARK: - Pill choice

private struct PillChoice: View {
    var title: String
    var subtitle: String?
    var symbol: String
    var isSelected: Bool
    var tint: Color
    var compact: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CalnoraSpacing.medium) {
                Image(systemName: symbol)
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : tint)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? tint : tint.opacity(0.14), in: .circle)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                    if let subtitle, !compact {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(tint)
                }
            }
            .padding(.horizontal, CalnoraSpacing.medium)
            .padding(.vertical, compact ? CalnoraSpacing.small : CalnoraSpacing.small + 4)
            .background(.regularMaterial, in: .rect(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? tint.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .environment(UserProfileStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
        .environment(NotificationStore())
}
