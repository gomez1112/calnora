import SwiftData
import SwiftUI

struct CoachChatView: View {
    @Environment(CoachStore.self) private var coachStore
    @Environment(PurchaseStore.self) private var purchaseStore
    let quotaManager: QuotaManager
    @State private var model = CoachChatModel()

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: CalnoraSpacing.medium) {
                    ForEach(model.localMessages) { message in
                        CoachBubbleView(message: message)
                    }
                }
                .padding()
            }

            HStack(spacing: CalnoraSpacing.small) {
                TextField("Ask your coach", text: $model.input, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(!model.canSend || coachStore.isResponding)
                .accessibilityLabel("Send coach question")
            }
            .padding()
            .background(.regularMaterial)
        }
        .navigationTitle("Coach")
    }

    private func send() async {
        let question = model.input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        model.input = ""
        model.localMessages.append(CoachChatBubble(role: .user, text: question))
        let answer = await coachStore.answer(
            question,
            entitlements: purchaseStore.entitlements,
            quotaManager: quotaManager
        )
        model.localMessages.append(CoachChatBubble(role: .assistant, text: answer))
    }
}

private struct CoachBubbleView: View {
    var message: CoachChatBubble

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer(minLength: 44)
            } else {
                Spacer(minLength: 44)
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.text)
            .font(.body)
            .padding()
            .foregroundStyle(message.role == .assistant ? Color.primary : Color.white)
            .background(
                message.role == .assistant ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(CalnoraColors.coach.gradient),
                in: .rect(cornerRadius: 20, style: .continuous)
            )
            .accessibilityLabel(message.role == .assistant ? "Coach response" : "Your question")
    }
}

#Preview {
    CoachChatView(quotaManager: QuotaManager())
        .environment(CoachStore(engine: MockCoachEngine(), mealStore: MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext), nutritionGoalStore: NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext)))
        .environment(PurchaseStore())
}
