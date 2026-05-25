import Foundation

actor DataExportService {
    func export(_ snapshot: CalnoraExportSnapshot) throws -> URL {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(snapshot)
        let directory = URL.documentsDirectory.appending(path: "CalnoraExports")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

        let fileURL = directory.appending(path: "CalnoraExport.json")
        try data.write(to: fileURL, options: [.atomic])
        return fileURL
    }
}

nonisolated struct CalnoraExportSnapshot: Codable, Sendable {
    var exportedAt: Date
    var appName: String
    var bundleID: String
    var safetyNote: String
    var profile: ExportedUserProfile?
    var goal: ExportedNutritionGoal?
    var meals: [ExportedMealEntry]
    var foods: [ExportedFoodItem]
    var favorites: [ExportedFavoriteMeal]
    var waterEntries: [ExportedWaterEntry]
    var weightEntries: [ExportedWeightEntry]
    var coachMessages: [ExportedCoachMessage]
    var coachInsights: [ExportedCoachInsight]
    var purchaseSnapshots: [ExportedPurchaseSnapshot]
    var premiumPacks: [ExportedPremiumContentPack]
}

extension CalnoraExportSnapshot {
    init(
        userProfileStore: UserProfileStore,
        nutritionGoalStore: NutritionGoalStore,
        mealStore: MealStore,
        coachStore: CoachStore,
        purchaseStore: PurchaseStore
    ) {
        self.init(
            exportedAt: .now,
            appName: "Calnora",
            bundleID: "com.gerardgomez.calnora",
            safetyNote: "Nutrition values are approximate and informational. Calnora does not provide medical advice.",
            profile: userProfileStore.profile.map(ExportedUserProfile.init),
            goal: nutritionGoalStore.goal.map(ExportedNutritionGoal.init),
            meals: mealStore.meals.map(ExportedMealEntry.init),
            foods: mealStore.foodItems.map(ExportedFoodItem.init),
            favorites: mealStore.favorites.map(ExportedFavoriteMeal.init),
            waterEntries: mealStore.waterEntries.map(ExportedWaterEntry.init),
            weightEntries: mealStore.weightEntries.map(ExportedWeightEntry.init),
            coachMessages: coachStore.messages.map(ExportedCoachMessage.init),
            coachInsights: coachStore.insights.map(ExportedCoachInsight.init),
            purchaseSnapshots: purchaseStore.purchaseSnapshots(),
            premiumPacks: purchaseStore.premiumPacks()
        )
    }
}

nonisolated struct ExportedUserProfile: Codable, Sendable {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var displayName: String
    var goal: String
    var ageRange: String
    var height: Double
    var weight: Double
    var activityLevel: String
    var dietaryPreference: String
    var allergies: [String]
    var avoidedFoods: [String]
    var preferredUnits: String
    var hasCompletedOnboarding: Bool

    init(_ profile: UserProfile) {
        id = profile.id
        createdAt = profile.createdAt
        updatedAt = profile.updatedAt
        displayName = profile.displayName
        goal = profile.goal.rawValue
        ageRange = profile.ageRange.rawValue
        height = profile.height
        weight = profile.weight
        activityLevel = profile.activityLevel.rawValue
        dietaryPreference = profile.dietaryPreference.rawValue
        allergies = profile.allergies
        avoidedFoods = profile.avoidedFoods
        preferredUnits = profile.preferredUnits.rawValue
        hasCompletedOnboarding = profile.hasCompletedOnboarding
    }
}

nonisolated struct ExportedNutritionGoal: Codable, Sendable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var water: Double
    var goalType: String
    var createdAt: Date
    var updatedAt: Date

    init(_ goal: NutritionGoal) {
        calories = goal.calories
        protein = goal.protein
        carbs = goal.carbs
        fat = goal.fat
        fiber = goal.fiber
        water = goal.water
        goalType = goal.goalType.rawValue
        createdAt = goal.createdAt
        updatedAt = goal.updatedAt
    }
}

nonisolated struct ExportedMealEntry: Codable, Sendable {
    var id: UUID
    var date: Date
    var mealType: String
    var name: String
    var servingDescription: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var notes: String
    var source: String
    var confidence: Double
    var isFavorite: Bool

    init(_ meal: MealEntry) {
        id = meal.id
        date = meal.date
        mealType = meal.mealType.rawValue
        name = meal.name
        servingDescription = meal.servingDescription
        calories = meal.calories
        protein = meal.protein
        carbs = meal.carbs
        fat = meal.fat
        fiber = meal.fiber
        sugar = meal.sugar
        notes = meal.notes
        source = meal.source.rawValue
        confidence = meal.confidence
        isFavorite = meal.isFavorite
    }
}

nonisolated struct ExportedFoodItem: Codable, Sendable {
    var name: String
    var caloriesPerServing: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var servingDescription: String
    var isCustom: Bool

    init(_ item: FoodItem) {
        name = item.name
        caloriesPerServing = item.caloriesPerServing
        protein = item.protein
        carbs = item.carbs
        fat = item.fat
        fiber = item.fiber
        sugar = item.sugar
        servingDescription = item.servingDescription
        isCustom = item.isCustom
    }
}

nonisolated struct ExportedFavoriteMeal: Codable, Sendable {
    var name: String
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double

    init(_ favorite: FavoriteMeal) {
        name = favorite.name
        totalCalories = favorite.totalCalories
        totalProtein = favorite.totalProtein
        totalCarbs = favorite.totalCarbs
        totalFat = favorite.totalFat
    }
}

nonisolated struct ExportedWaterEntry: Codable, Sendable {
    var date: Date
    var amount: Double

    init(_ entry: WaterEntry) {
        date = entry.date
        amount = entry.amount
    }
}

nonisolated struct ExportedWeightEntry: Codable, Sendable {
    var date: Date
    var weight: Double

    init(_ entry: WeightEntry) {
        date = entry.date
        weight = entry.weight
    }
}

nonisolated struct ExportedCoachMessage: Codable, Sendable {
    var date: Date
    var role: String
    var content: String

    init(_ message: CoachMessage) {
        date = message.date
        role = message.role.rawValue
        content = message.content
    }
}

nonisolated struct ExportedCoachInsight: Codable, Sendable {
    var date: Date
    var title: String
    var message: String
    var insightType: String

    init(_ insight: CoachInsight) {
        date = insight.date
        title = insight.title
        message = insight.message
        insightType = insight.insightType.rawValue
    }
}

nonisolated struct ExportedPurchaseSnapshot: Codable, Sendable {
    var date: Date
    var hasPro: Bool
    var hasLifetime: Bool
    var hasHighProteinPack: Bool
    var activeProductIDs: [String]

    init(_ snapshot: PurchaseSnapshot) {
        date = snapshot.date
        hasPro = snapshot.hasPro
        hasLifetime = snapshot.hasLifetime
        hasHighProteinPack = snapshot.hasHighProteinPack
        activeProductIDs = snapshot.activeProductIDs
    }
}

nonisolated struct ExportedPremiumContentPack: Codable, Sendable {
    var productID: String
    var title: String
    var isUnlocked: Bool

    init(_ pack: PremiumContentPack) {
        productID = pack.productID
        title = pack.title
        isUnlocked = pack.isUnlocked
    }
}
