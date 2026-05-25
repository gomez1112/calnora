import Observation
import FlexStore
import SwiftUI

@Observable
final class PaywallModel {
    let features = [
        FlexPaywallFeature(
            systemImage: "sparkles",
            title: "Unlimited AI meal estimates",
            subtitle: "Parse meals faster with editable nutrition estimates.",
            tint: CalnoraColors.coach
        ),
        FlexPaywallFeature(
            systemImage: "brain.head.profile",
            title: "Personalized coaching",
            subtitle: "Get daily guidance based on your meals and goals.",
            tint: CalnoraColors.success
        ),
        FlexPaywallFeature(
            systemImage: "chart.xyaxis.line",
            title: "Premium trends",
            subtitle: "Follow calorie, macro, water, and habit patterns.",
            tint: CalnoraColors.warning
        )
    ]
}
