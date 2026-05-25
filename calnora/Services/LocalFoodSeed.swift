import Foundation

nonisolated enum LocalFoodSeed {
    static let items: [FoodSeedItem] = [
        FoodSeedItem(name: "Eggs", caloriesPerServing: 140, protein: 12, carbs: 1, fat: 10, fiber: 0, sugar: 0, servingDescription: "2 large eggs"),
        FoodSeedItem(name: "Chicken breast", caloriesPerServing: 165, protein: 31, carbs: 0, fat: 4, fiber: 0, sugar: 0, servingDescription: "3.5 oz cooked"),
        FoodSeedItem(name: "Salmon", caloriesPerServing: 206, protein: 22, carbs: 0, fat: 12, fiber: 0, sugar: 0, servingDescription: "3.5 oz cooked"),
        FoodSeedItem(name: "Greek yogurt", caloriesPerServing: 130, protein: 20, carbs: 8, fat: 0, fiber: 0, sugar: 6, servingDescription: "1 cup plain nonfat"),
        FoodSeedItem(name: "Oatmeal", caloriesPerServing: 150, protein: 5, carbs: 27, fat: 3, fiber: 4, sugar: 1, servingDescription: "1 cup cooked"),
        FoodSeedItem(name: "Rice", caloriesPerServing: 205, protein: 4, carbs: 45, fat: 0, fiber: 1, sugar: 0, servingDescription: "1 cup cooked"),
        FoodSeedItem(name: "Avocado", caloriesPerServing: 240, protein: 3, carbs: 13, fat: 22, fiber: 10, sugar: 1, servingDescription: "1 medium"),
        FoodSeedItem(name: "Banana", caloriesPerServing: 105, protein: 1, carbs: 27, fat: 0, fiber: 3, sugar: 14, servingDescription: "1 medium"),
        FoodSeedItem(name: "Apple", caloriesPerServing: 95, protein: 0, carbs: 25, fat: 0, fiber: 4, sugar: 19, servingDescription: "1 medium"),
        FoodSeedItem(name: "Broccoli", caloriesPerServing: 55, protein: 4, carbs: 11, fat: 1, fiber: 5, sugar: 2, servingDescription: "1 cup cooked"),
        FoodSeedItem(name: "Sweet potato", caloriesPerServing: 112, protein: 2, carbs: 26, fat: 0, fiber: 4, sugar: 5, servingDescription: "1 medium"),
        FoodSeedItem(name: "Black beans", caloriesPerServing: 227, protein: 15, carbs: 41, fat: 1, fiber: 15, sugar: 0, servingDescription: "1 cup cooked"),
        FoodSeedItem(name: "Protein shake", caloriesPerServing: 160, protein: 25, carbs: 6, fat: 3, fiber: 1, sugar: 2, servingDescription: "1 scoop with water"),
        FoodSeedItem(name: "Coffee with milk", caloriesPerServing: 35, protein: 2, carbs: 4, fat: 1, fiber: 0, sugar: 4, servingDescription: "12 oz coffee with milk"),
        FoodSeedItem(name: "Sourdough toast", caloriesPerServing: 190, protein: 7, carbs: 36, fat: 2, fiber: 2, sugar: 2, servingDescription: "2 slices")
    ]
}

nonisolated struct FoodSeedItem: Codable, Equatable, Sendable {
    var name: String
    var caloriesPerServing: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var servingDescription: String
}
