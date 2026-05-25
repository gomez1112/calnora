import Foundation
import SwiftData

@Model
final class CoachInsight {
    @Attribute(.unique) var id: UUID
    var date: Date
    var title: String
    var message: String
    var insightType: CoachInsightType

    init(
        id: UUID = UUID(),
        date: Date = .now,
        title: String,
        message: String,
        insightType: CoachInsightType
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.message = message
        self.insightType = insightType
    }
}
