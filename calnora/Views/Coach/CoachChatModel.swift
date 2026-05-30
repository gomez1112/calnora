import Foundation
import Observation
import SwiftUI

@Observable
final class CoachChatModel {
    var input = ""
    var isStreamingResponse = false
    var localMessages: [CoachChatBubble] = [
        CoachChatBubble(role: .assistant, text: "Ask about patterns, meal ideas, or how to adjust today. I will keep it supportive and non-medical.")
    ]

    var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func load(from messages: [CoachMessage]) {
        let persisted = messages.map {
            CoachChatBubble(role: $0.role, text: $0.content)
        }
        localMessages = persisted.isEmpty ? [
            CoachChatBubble(role: .assistant, text: "Ask about patterns, meal ideas, or how to adjust today. I will keep it supportive and non-medical.")
        ] : persisted
    }

    func appendUserMessage(_ text: String) {
        localMessages.append(CoachChatBubble(role: .user, text: text))
    }

    func streamAssistantMessage(_ text: String) async {
        let bubble = CoachChatBubble(role: .assistant, text: "")
        localMessages.append(bubble)
        isStreamingResponse = true
        defer { isStreamingResponse = false }

        var rendered = ""
        let chunks = text.split(separator: " ", omittingEmptySubsequences: false).map(String.init)

        for chunk in chunks {
            rendered += rendered.isEmpty ? chunk : " \(chunk)"
            updateAssistantMessage(id: bubble.id, text: rendered)
            try? await Task.sleep(for: .milliseconds(28))
        }
    }

    private func updateAssistantMessage(id: UUID, text: String) {
        guard let index = localMessages.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.smooth(duration: 0.18)) {
            localMessages[index].text = text
        }
    }
}

nonisolated struct CoachChatBubble: Identifiable, Equatable, Sendable {
    let id = UUID()
    var role: CoachRole
    var text: String
}
