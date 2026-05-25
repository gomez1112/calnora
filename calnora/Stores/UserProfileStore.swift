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
}
