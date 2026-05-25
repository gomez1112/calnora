import SwiftData

enum CalnoraSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static let models: [any PersistentModel.Type] = [
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
}

enum CalnoraMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        CalnoraSchemaV1.self
    ]

    static let stages: [MigrationStage] = []
}
