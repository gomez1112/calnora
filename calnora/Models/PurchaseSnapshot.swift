import Foundation
import SwiftData

@Model
final class PurchaseSnapshot {
    var id = UUID()
    var date = Date()
    var hasPro = false
    var hasLifetime = false
    var hasHighProteinPack = false
    var activeProductIDs: [String] = []

    init(
        id: UUID = UUID(),
        date: Date = .now,
        hasPro: Bool = false,
        hasLifetime: Bool = false,
        hasHighProteinPack: Bool = false,
        activeProductIDs: [String] = []
    ) {
        self.id = id
        self.date = date
        self.hasPro = hasPro
        self.hasLifetime = hasLifetime
        self.hasHighProteinPack = hasHighProteinPack
        self.activeProductIDs = activeProductIDs
    }
}
