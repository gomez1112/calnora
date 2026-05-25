import Foundation
import SwiftData

@Model
final class CoachMessage {
    @Attribute(.unique) var id: UUID
    var date: Date
    var role: CoachRole
    var content: String

    init(
        id: UUID = UUID(),
        date: Date = .now,
        role: CoachRole,
        content: String
    ) {
        self.id = id
        self.date = date
        self.role = role
        self.content = content
    }
}
