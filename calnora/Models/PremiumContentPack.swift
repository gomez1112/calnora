import Foundation
import SwiftData

@Model
final class PremiumContentPack {
    @Attribute(.unique) var id: UUID
    var productID: String
    var title: String
    var isUnlocked: Bool

    init(
        id: UUID = UUID(),
        productID: String,
        title: String,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.productID = productID
        self.title = title
        self.isUnlocked = isUnlocked
    }
}
