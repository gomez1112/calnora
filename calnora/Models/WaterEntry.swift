import Foundation
import SwiftData

@Model
final class WaterEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Double

    init(id: UUID = UUID(), date: Date = .now, amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}
