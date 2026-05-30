import Observation
import FlexStore
import SwiftUI

@Observable
final class PaywallModel {
    let features = [
        FlexPaywallFeature(
            systemImage: "sparkles",
            title: "Unlimited AI estimates",
            subtitle: "Parse meals from a sentence — editable totals.",
            tint: .yellow
        ),
        FlexPaywallFeature(
            systemImage: "brain.head.profile",
            title: "Personalized coaching",
            subtitle: "Daily guidance from your local meals and goals.",
            tint: .mint
        ),
        FlexPaywallFeature(
            systemImage: "chart.xyaxis.line",
            title: "Premium trends",
            subtitle: "Macros, water, weight and habits over time.",
            tint: .cyan
        )
    ]
}
