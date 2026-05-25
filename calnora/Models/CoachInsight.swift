import Foundation
import SwiftData

@Model
final class CoachInsight {
    var date = Date()
    var title = ""
    var message = ""
    var insightType = CoachInsightType.calorieTrend

    init(
        date: Date = .now,
        title: String,
        message: String,
        insightType: CoachInsightType
    ) {
        self.date = date
        self.title = title
        self.message = message
        self.insightType = insightType
    }
}
