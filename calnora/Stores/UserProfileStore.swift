import Foundation
import Observation
import SwiftData

@Observable
final class UserProfileStore {
    @ObservationIgnored private let context: ModelContext
    var profile: UserProfile?

    init(context: ModelContext) {
        self.context = context
        loadProfile()
    }

    func loadProfile() {
        let descriptor = FetchDescriptor<UserProfile>(sortBy: [SortDescriptor(\.createdAt)])
        profile = try? context.fetch(descriptor).first
    }

    @discardableResult
    func ensureProfile() -> UserProfile {
        if let profile { return profile }
        let profile = UserProfile()
        context.insert(profile)
        try? context.save()
        self.profile = profile
        return profile
    }

    func completeOnboarding() {
        let profile = ensureProfile()
        profile.hasCompletedOnboarding = true
        profile.updatedAt = .now
        try? context.save()
        self.profile = profile
    }

    func saveChanges() {
        profile?.updatedAt = .now
        try? context.save()
        loadProfile()
    }

    func update(from draft: OnboardingProfileDraft, completesOnboarding: Bool) {
        let profile = ensureProfile()
        profile.displayName = draft.displayName
        profile.goal = draft.goal
        profile.ageRange = draft.ageRange
        profile.height = draft.height
        profile.weight = draft.weight
        profile.activityLevel = draft.activityLevel
        profile.dietaryPreference = draft.dietaryPreference
        profile.allergies = draft.allergyList
        profile.avoidedFoods = draft.avoidedFoodList
        profile.preferredUnits = draft.preferredUnits
        profile.hasCompletedOnboarding = completesOnboarding
        profile.updatedAt = .now
        try? context.save()
        self.profile = profile
    }
}
