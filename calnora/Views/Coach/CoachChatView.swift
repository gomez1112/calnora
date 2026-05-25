import SwiftData
import SwiftUI

struct CoachChatView: View {
    @Environment(AppRouter.self) private var router
    @Environment(CoachStore.self) private var coachStore
    @Environment(PurchaseStore.self) private var purchaseStore
    @Environment(NotificationStore.self) private var notificationStore
    let quotaManager: QuotaManager
    @State private var model = CoachChatModel()
    @State private var remainingUses: Int?

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            quotaBanner

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
        .task {
            coachStore.load()
            model.load(from: coachStore.messages)
            await refreshQuota()
        }
        .onChange(of: purchaseStore.entitlements) { _, _ in
            Task { await refreshQuota() }
        }
    }

    private var quotaBanner: some View {
        HStack(spacing: CalnoraSpacing.small) {
            Label(quotaText, systemImage: purchaseStore.entitlements.unlocksPro ? "infinity" : "sparkles")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(purchaseStore.entitlements.unlocksPro ? CalnoraColors.success : CalnoraColors.coach)
            Spacer()
            if !purchaseStore.entitlements.unlocksPro {
                Button("Upgrade") {
                    router.push(.paywall, in: .coach)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(CalnoraColors.groupedBackground)
    }

    private var quotaText: String {
        if purchaseStore.entitlements.unlocksPro {
            "Unlimited coach questions"
        } else if let remainingUses {
            "\(remainingUses) free coach questions left this week"
        } else {
            "Checking coach quota"
        }
    }

    private func send() async {
        let question = model.input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        guard purchaseStore.entitlements.unlocksPro || (remainingUses ?? 1) > 0 else {
            notificationStore.quotaLimitReached()
            router.push(.paywall, in: .coach)
            return
        }
        model.input = ""
        model.localMessages.append(CoachChatBubble(role: .user, text: question))
        let answer = await coachStore.answer(
            question,
            entitlements: purchaseStore.entitlements,
            quotaManager: quotaManager
        )
        if answer == QuotaError.limitReached.localizedDescription {
            notificationStore.quotaLimitReached()
        }
        model.localMessages.append(CoachChatBubble(role: .assistant, text: answer))
        await refreshQuota()
    }

    private func refreshQuota() async {
        remainingUses = await quotaManager.remainingUses(
            for: .coachQuestion,
            entitlements: purchaseStore.entitlements
        )
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
        .environment(AppRouter())
        .environment(CoachStore(engine: MockCoachEngine(), mealStore: MealStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext), nutritionGoalStore: NutritionGoalStore(context: PersistenceController.makeModelContainer(inMemory: true).mainContext)))
        .environment(PurchaseStore())
        .environment(NotificationStore())
}
