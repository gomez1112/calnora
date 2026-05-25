import SwiftData
import SwiftUI

struct MealEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MealStore.self) private var mealStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var model = MealEditorModel()

    var body: some View {
        @Bindable var model = model

        Form {
            Section("Meal") {
                TextField("Name", text: $model.name)
                TextField("Serving", text: $model.servingDescription)
                DatePicker("Date", selection: $model.date)
                Picker("Meal type", selection: $model.mealType) {
                    ForEach(MealType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
            }

            Section("Nutrition") {
                TextField("Calories", value: $model.calories, format: .number)
                TextField("Protein", value: $model.protein, format: .number)
                TextField("Carbs", value: $model.carbs, format: .number)
                TextField("Fat", value: $model.fat, format: .number)
                TextField("Fiber", value: $model.fiber, format: .number)
                TextField("Sugar", value: $model.sugar, format: .number)
            }

            Section("Notes") {
                TextField("Optional note", text: $model.notes, axis: .vertical)
                    .lineLimit(3...6)
                Toggle("Save as favorite", isOn: $model.saveAsFavorite)
            }
        }
        .navigationTitle("Add Meal")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let meal = model.makeMealEntry()
                    mealStore.save(meal)
                    if model.saveAsFavorite {
                        mealStore.saveFavorite(from: meal)
                    }
                    notificationStore.mealSaved()
                    dismiss()
                }
                .disabled(!model.canSave)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MealEditorView()
    }
    .environment(MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext))
    .environment(NotificationStore())
}
