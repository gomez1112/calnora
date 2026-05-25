import Foundation

nonisolated struct HighProteinMealIdea: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var title: String
    var description: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
}

nonisolated enum PremiumContentService {
    static func highProteinIdeas() -> [HighProteinMealIdea] {
        HighProteinContentSeed.ideas
    }
}
