import SwiftData
import SwiftUI

struct MealEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MealStore.self) private var mealStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = MealEditorModel()

    var body: some View {
        @Bindable var model = model

        ScrollView {
            VStack(spacing: CalnoraSpacing.large) {
                mealSection(model: model)
                nutritionSection(model: model)
                notesSection(model: model)
            }
            .calnoraScreenContent(maxWidth: CalnoraSpacing.readableMaxWidth)
        }
        .calnoraAmbientBackground()
        .scrollIndicators(.hidden)
        .navigationTitle("Add Meal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: saveMeal)
                    .disabled(!model.canSave)
                    .bold()
            }
        }
    }

    private func mealSection(model: MealEditorModel) -> some View {
        @Bindable var model = model

        return MealEditorSection(title: "Meal", systemImage: "fork.knife", tint: CalnoraColors.calories) {
            VStack(spacing: 0) {
                MealTextFieldRow(title: "Name", placeholder: "Chicken rice bowl", text: $model.name)
                MealEditorDivider()
                MealTextFieldRow(title: "Serving", placeholder: "1 serving", text: $model.servingDescription)
                MealEditorDivider()
                DatePicker("Date", selection: $model.date)
                    .datePickerStyle(.compact)
                    .font(.system(.subheadline, design: .rounded))
                    .padding(.vertical, CalnoraSpacing.small + 2)
                MealEditorDivider()
                Picker("Meal type", selection: $model.mealType) {
                    ForEach(MealType.allCases) { type in
                        Label(type.title, systemImage: type.symbolName)
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(.subheadline, design: .rounded))
                .padding(.vertical, CalnoraSpacing.small + 2)
            }
        }
    }

    private func nutritionSection(model: MealEditorModel) -> some View {
        @Bindable var model = model

        return MealEditorSection(title: "Nutrition", systemImage: "chart.bar.fill", tint: CalnoraColors.protein) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: CalnoraSpacing.small),
                    GridItem(.flexible(), spacing: CalnoraSpacing.small)
                ],
                spacing: CalnoraSpacing.small
            ) {
                MealNumberTile(title: "Calories", unit: "kcal", tint: CalnoraColors.calories, value: $model.calories)
                MealNumberTile(title: "Protein", unit: "g", tint: CalnoraColors.protein, value: $model.protein)
                MealNumberTile(title: "Carbs", unit: "g", tint: CalnoraColors.carbs, value: $model.carbs)
                MealNumberTile(title: "Fat", unit: "g", tint: CalnoraColors.fat, value: $model.fat)
                MealNumberTile(title: "Fiber", unit: "g", tint: CalnoraColors.success, value: $model.fiber)
                MealNumberTile(title: "Sugar", unit: "g", tint: CalnoraColors.coach, value: $model.sugar)
            }
        }
    }

    private func notesSection(model: MealEditorModel) -> some View {
        @Bindable var model = model

        return MealEditorSection(title: "Notes", systemImage: "text.bubble.fill", tint: CalnoraColors.coach) {
            VStack(spacing: 0) {
                TextField("Optional note", text: $model.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.system(.subheadline, design: .rounded))
                    .padding(CalnoraSpacing.medium)
                    .background(.secondary.opacity(0.08), in: .rect(cornerRadius: CalnoraSpacing.tileRadius, style: .continuous))
                MealEditorDivider()
                Toggle("Save as favorite", isOn: $model.saveAsFavorite)
                    .font(.system(.subheadline, design: .rounded))
                    .tint(CalnoraColors.carbs)
                    .padding(.vertical, CalnoraSpacing.small + 2)
            }
        }
    }

    private func saveMeal() {
        let meal = model.makeMealEntry()
        mealStore.save(meal)
        if model.saveAsFavorite {
            mealStore.saveFavorite(from: meal)
        }
        notificationStore.mealSaved()
        dismiss()
    }
}

private struct MealEditorSection<Content: View>: View {
    var title: String
    var systemImage: String
    var tint: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            Label(title, systemImage: systemImage)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(tint)
                .padding(.horizontal, CalnoraSpacing.xSmall)

            VStack(spacing: 0) {
                content
            }
            .padding(CalnoraSpacing.medium)
            .calnoraCard(cornerRadius: CalnoraSpacing.cardRadius, tint: tint)
        }
    }
}

private struct MealTextFieldRow: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.xSmall) {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .font(.system(.body, design: .rounded))
                .textFieldStyle(.plain)
                .submitLabel(.next)
        }
        .padding(.vertical, CalnoraSpacing.small + 2)
    }
}

private struct MealNumberTile: View {
    var title: String
    var unit: String
    var tint: Color
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack {
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Text(unit)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(tint)
            }

            TextField("0", value: $value, format: .number)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
                .textFieldStyle(.plain)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
        }
        .padding(CalnoraSpacing.medium)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(tint.opacity(0.10), in: .rect(cornerRadius: CalnoraSpacing.tileRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CalnoraSpacing.tileRadius, style: .continuous)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MealEditorDivider: View {
    var body: some View {
        Rectangle()
            .fill(.secondary.opacity(0.12))
            .frame(height: 0.5)
    }
}

#Preview {
    NavigationStack {
        MealEditorView()
    }
    .environment(MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
    .environment(NotificationStore())
}
