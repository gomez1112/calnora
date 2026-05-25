import Testing
@testable import calnora

struct CoachFallbackTests {
    @Test func mockCoachProducesEditableEstimate() async throws {
        let estimate = try await MockCoachEngine().parseMealDescription(
            "2 eggs and sourdough toast",
            context: MealParsingContext(
                preferredUnits: .imperial,
                dietaryPreference: .balanced,
                allergies: [],
                avoidedFoods: []
            )
        )

        #expect(estimate.estimatedCalories > 0)
        #expect(estimate.confidence < 1)
        #expect(estimate.explanation.contains("Review"))
    }
}
