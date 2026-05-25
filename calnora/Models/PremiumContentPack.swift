import Foundation
import SwiftData

@Model
final class PremiumContentPack {
    var id = UUID()
    var productID = ""
    var title = ""
    var isUnlocked = false

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
