import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NutritionGoalStore.self) private var nutritionGoalStore
    @Environment(NotificationStore.self) private var notificationStore

    @State private var hasAppeared = false
    @State private var allergiesText = ""
    @State private var avoidedText = ""

    var body: some View {
        let profile = userProfileStore.ensureProfile()
        let goal = nutritionGoalStore.ensureGoal()
        @Bindable var editableProfile = profile
        @Bindable var editableGoal = goal

        return ScrollView {
            VStack(spacing: CalnoraSpacing.large) {
                customHeader

                identityCard(profile: editableProfile)
                    .stagger(0, hasAppeared: hasAppeared)

                bodyCard(profile: editableProfile)
                    .stagger(1, hasAppeared: hasAppeared)

                dietCard(profile: editableProfile)
                    .stagger(2, hasAppeared: hasAppeared)

                targetsCard(profile: editableProfile, goal: editableGoal)
                    .stagger(3, hasAppeared: hasAppeared)

                Color.clear.frame(height: 4)
            }
            .padding(.horizontal, CalnoraSpacing.medium)
            .padding(.top, CalnoraSpacing.small)
            .padding(.bottom, CalnoraSpacing.xLarge)
        }
        .calnoraAmbientBackground()
        .scrollIndicators(.hidden)
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .onAppear {
            allergiesText = profile.allergies.joined(separator: ", ")
            avoidedText = profile.avoidedFoods.joined(separator: ", ")
            animateIn()
        }
    }

    // MARK: - Custom header

    private var customHeader: some View {
        HStack(alignment: .center, spacing: CalnoraSpacing.small) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CalnoraColors.coach)
                    .frame(width: 36, height: 36)
                    .background(CalnoraColors.coach.opacity(0.14), in: .circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 2) {
                Text("Profile")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.4)
                Text("You and your goals")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }

            Spacer()

            Button {
                userProfileStore.saveChanges()
                nutritionGoalStore.saveChanges()
                notificationStore.show(
                    title: "Profile saved",
                    message: "Your Calnora preferences are updated.",
                    symbolName: "checkmark.circle.fill"
                )
            } label: {
                Text("Save")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, CalnoraSpacing.medium)
                    .padding(.vertical, 8)
                    .background(CalnoraColors.coach.gradient, in: .capsule)
                    .shadow(color: CalnoraColors.coach.opacity(0.32), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Save profile")
        }
        .padding(.horizontal, CalnoraSpacing.xSmall)
    }

    // MARK: - Identity

    private func identityCard(profile: UserProfile) -> some View {
        @Bindable var profile = profile
        return sectionCard(title: "Identity", tint: CalnoraColors.protein, symbol: "person.crop.circle") {
            fieldRow(label: "Display name") {
                TextField("Optional", text: $profile.displayName)
                    .textFieldStyle(.plain)
                    .font(.system(.subheadline, design: .rounded))
                    .multilineTextAlignment(.trailing)
            }
            divider
            pickerRow(label: "Goal", selection: $profile.goal) { goal in
                Text(goal.title).tag(goal)
            }
            divider
            pickerRow(label: "Age range", selection: $profile.ageRange) { range in
                Text(range.title).tag(range)
            }
            divider
            pickerRow(label: "Activity", selection: $profile.activityLevel) { level in
                Text(level.title).tag(level)
            }
        }
    }

    // MARK: - Body / units

    private func bodyCard(profile: UserProfile) -> some View {
        @Bindable var profile = profile
        return sectionCard(title: "Body & Units", tint: CalnoraColors.coach, symbol: "ruler") {
            pickerRow(label: "Units", selection: $profile.preferredUnits) { units in
                Text(units.title).tag(units)
            }
            divider
            fieldRow(label: "Height") {
                HStack(spacing: 4) {
                    TextField("0", value: $profile.height, format: .number)
                        .textFieldStyle(.plain)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(maxWidth: 80)
                    Text(profile.preferredUnits.heightUnit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            divider
            fieldRow(label: "Weight") {
                HStack(spacing: 4) {
                    TextField("0", value: $profile.weight, format: .number)
                        .textFieldStyle(.plain)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(maxWidth: 80)
                    Text(profile.preferredUnits.weightUnit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Diet

    private func dietCard(profile: UserProfile) -> some View {
        @Bindable var profile = profile
        return sectionCard(title: "Diet", tint: CalnoraColors.carbs, symbol: "leaf.fill") {
            pickerRow(label: "Preference", selection: $profile.dietaryPreference) { pref in
                Text(pref.title).tag(pref)
            }
            divider
            multilineRow(
                label: "Allergies",
                placeholder: "e.g. peanuts, shellfish",
                text: $allergiesText
            ) { newValue in
                profile.allergies = Self.splitCommaSeparatedList(newValue)
            }
            divider
            multilineRow(
                label: "Foods to avoid",
                placeholder: "e.g. soda, fried foods",
                text: $avoidedText
            ) { newValue in
                profile.avoidedFoods = Self.splitCommaSeparatedList(newValue)
            }
        }
    }

    // MARK: - Targets

    private func targetsCard(profile: UserProfile, goal: NutritionGoal) -> some View {
        @Bindable var goal = goal
        return sectionCard(
            title: "Nutrition Targets",
            subtitle: "Planning estimates, not medical advice.",
            tint: CalnoraColors.calories,
            symbol: "target"
        ) {
            numericRow(label: "Calories", value: $goal.calories, unit: "kcal", tint: CalnoraColors.calories)
            divider
            numericRow(label: "Protein", value: $goal.protein, unit: "g", tint: CalnoraColors.protein)
            divider
            numericRow(label: "Carbs", value: $goal.carbs, unit: "g", tint: CalnoraColors.carbs)
            divider
            numericRow(label: "Fat", value: $goal.fat, unit: "g", tint: CalnoraColors.fat)
            divider
            numericRow(label: "Fiber", value: $goal.fiber, unit: "g", tint: CalnoraColors.success)
            divider
            numericRow(label: "Water", value: $goal.water, unit: profile.preferredUnits.waterUnit, tint: CalnoraColors.water)
            divider
            Button {
                nutritionGoalStore.recalculate(from: profile)
                notificationStore.show(
                    title: "Targets updated",
                    message: "Your starting targets were recalculated from your profile.",
                    symbolName: "target"
                )
            } label: {
                HStack(spacing: CalnoraSpacing.medium) {
                    Image(systemName: "wand.and.stars")
                        .font(.subheadline)
                        .foregroundStyle(CalnoraColors.coach)
                        .frame(width: 32, height: 32)
                        .background(CalnoraColors.coach.opacity(0.16), in: .circle)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Recalculate from profile")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("Uses age, weight, activity, goal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, CalnoraSpacing.small + 2)
                .padding(.horizontal, CalnoraSpacing.medium)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Building blocks

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        subtitle: String? = nil,
        tint: Color,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(spacing: CalnoraSpacing.small) {
                Image(systemName: symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 22, height: 22)
                    .background(tint.opacity(0.16), in: .circle)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, CalnoraSpacing.xSmall)

            VStack(spacing: 0) {
                content()
            }
            .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius, tint: tint)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.secondary.opacity(0.12))
            .frame(height: 0.5)
            .padding(.leading, CalnoraSpacing.medium)
    }

    private func fieldRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: CalnoraSpacing.medium) {
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            Spacer(minLength: CalnoraSpacing.small)
            content()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, CalnoraSpacing.small + 2)
        .padding(.horizontal, CalnoraSpacing.medium)
    }

    private func pickerRow<Value: Hashable & CaseIterable & Identifiable, RowContent: View>(
        label: String,
        selection: Binding<Value>,
        @ViewBuilder content: @escaping (Value) -> RowContent
    ) -> some View where Value.AllCases == [Value] {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            Spacer()
            Picker(label, selection: selection) {
                ForEach(Value.allCases) { value in
                    content(value)
                }
            }
            .labelsHidden()
            .tint(CalnoraColors.coach)
        }
        .padding(.vertical, CalnoraSpacing.small)
        .padding(.horizontal, CalnoraSpacing.medium)
    }

    private func numericRow(label: String, value: Binding<Double>, unit: String, tint: Color) -> some View {
        HStack(spacing: CalnoraSpacing.small) {
            Circle()
                .fill(tint.gradient)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            Spacer()
            HStack(spacing: 4) {
                TextField("0", value: value, format: .number)
                    .textFieldStyle(.plain)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.trailing)
                    .monospacedDigit()
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .frame(maxWidth: 80)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, CalnoraSpacing.small + 2)
        .padding(.horizontal, CalnoraSpacing.medium)
    }

    private func multilineRow(
        label: String,
        placeholder: String,
        text: Binding<String>,
        commit: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            TextField(placeholder, text: text, axis: .vertical)
                .font(.system(.subheadline, design: .rounded))
                .lineLimit(1...3)
                .textFieldStyle(.plain)
                .onChange(of: text.wrappedValue) { _, newValue in
                    commit(newValue)
                }
        }
        .padding(.vertical, CalnoraSpacing.small)
        .padding(.horizontal, CalnoraSpacing.medium)
    }

    // MARK: - Helpers

    private func animateIn() {
        guard !hasAppeared else { return }
        withAnimation(.smooth(duration: 0.7)) {
            hasAppeared = true
        }
    }

    private static func splitCommaSeparatedList(_ text: String) -> [String] {
        text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
