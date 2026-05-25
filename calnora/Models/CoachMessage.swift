import Foundation
import SwiftData

@Model
final class CoachMessage {
    var date = Date()
    var role: CoachRole = CoachRole.assistant
    var content = ""

    init(
        date: Date = .now,
        role: CoachRole,
        content: String
    ) {
        self.date = date
        self.role = role
        self.content = content
    }
}
