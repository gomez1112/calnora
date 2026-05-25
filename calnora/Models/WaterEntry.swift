import Foundation
import SwiftData

@Model
final class WaterEntry {
    var id = UUID()
    var date = Date()
    var amount = 0.0

    init(id: UUID = UUID(), date: Date = .now, amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}
