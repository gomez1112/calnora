import Foundation
import Observation

@Observable
final class CoachChatModel {
    var input = ""
    var localMessages: [CoachChatBubble] = [
        CoachChatBubble(role: .assistant, text: "Ask about patterns, meal ideas, or how to adjust today. I will keep it supportive and non-medical.")
    ]

    var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

nonisolated struct CoachChatBubble: Identifiable, Equatable, Sendable {
    let id = UUID()
    var role: CoachRole
    var text: String
}
