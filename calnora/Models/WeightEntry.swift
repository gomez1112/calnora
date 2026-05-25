import Foundation
import SwiftData

@Model
final class WeightEntry {
    var id = UUID()
    var date = Date()
    var weight = 0.0

    init(id: UUID = UUID(), date: Date = .now, weight: Double) {
        self.id = id
        self.date = date
        self.weight = weight
    }
}
