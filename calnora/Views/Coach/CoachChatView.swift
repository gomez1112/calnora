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
    @State private var hasAppeared = false
    @FocusState private var inputFocused: Bool

    private let bottomAnchorID = "calnora.coach.bottom"

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: CalnoraSpacing.large) {
                        greetingHeader

                        statusCard
                            .stagger(0, hasAppeared: hasAppeared)

                        if model.localMessages.count <= 1 {
                            suggestedPromptsView
                                .stagger(1, hasAppeared: hasAppeared)
                        }

                        LazyVStack(spacing: CalnoraSpacing.medium) {
                            ForEach(model.localMessages) { message in
                                CoachBubbleView(message: message)
                                    .id(message.id)
                                    .transition(messageTransition(for: message.role))
                            }
                            if coachStore.isResponding && !model.isStreamingResponse {
                                TypingBubble()
                                    .transition(.opacity.combined(with: .scale(scale: 0.85, anchor: .bottomLeading)))
                            }
                        }
                        .animation(.smooth(duration: 0.45), value: model.localMessages.count)
                        .animation(.smooth(duration: 0.35), value: coachStore.isResponding)
                        .animation(.smooth(duration: 0.25), value: model.isStreamingResponse)

                        Color.clear
                            .frame(height: 1)
                            .id(bottomAnchorID)
                    }
                    .padding(.horizontal, CalnoraSpacing.medium)
                    .padding(.top, CalnoraSpacing.medium)
                    .padding(.bottom, CalnoraSpacing.medium)
                }
                .scrollIndicators(.hidden)
                .onChange(of: model.localMessages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: coachStore.isResponding) { _, isResponding in
                    if isResponding { scrollToBottom(proxy: proxy) }
                }
                .onChange(of: model.isStreamingResponse) { _, isStreaming in
                    if isStreaming { scrollToBottom(proxy: proxy) }
                }
                .task {
                    try? await Task.sleep(for: .milliseconds(250))
                    proxy.scrollTo(bottomAnchorID, anchor: .bottom)
                }
            }

            inputBar
        }
        .calnoraAmbientBackground()
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task {
            coachStore.load()
            model.load(from: coachStore.messages)
            await refreshQuota()
        }
        .onAppear { animateIn() }
        .onChange(of: purchaseStore.entitlements) { _, _ in
            Task { await refreshQuota() }
        }
    }

    // MARK: - Header

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Coach")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.4)
                Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
            Spacer()
            quotaChip
        }
        .padding(.horizontal, CalnoraSpacing.xSmall)
    }

    @ViewBuilder
    private var quotaChip: some View {
        if purchaseStore.entitlements.unlocksPro {
            HStack(spacing: 6) {
                Image(systemName: "infinity")
                    .font(.caption.weight(.semibold))
                Text("Unlimited")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(CalnoraColors.success)
            .padding(.horizontal, CalnoraSpacing.small)
            .padding(.vertical, 6)
            .background(CalnoraColors.success.opacity(0.16), in: .capsule)
            .accessibilityLabel(quotaText)
        } else {
            Button {
                router.push(.paywall, in: .dashboard)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.semibold))
                    Text(quotaShort)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(CalnoraColors.coach)
                .padding(.horizontal, CalnoraSpacing.small)
                .padding(.vertical, 6)
                .background(CalnoraColors.coach.opacity(0.16), in: .capsule)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(quotaText). Tap to upgrade.")
        }
    }

    // MARK: - Status

    private var statusCard: some View {
        HStack(alignment: .top, spacing: CalnoraSpacing.medium) {
            ZStack {
                Circle()
                    .fill(CalnoraColors.coach.opacity(0.16))
                    .frame(width: 42, height: 42)
                Image(systemName: "sparkles")
                    .font(.system(.headline, weight: .semibold))
                    .foregroundStyle(CalnoraColors.coach.gradient)
                    .symbolEffect(.pulse, options: .repeating, isActive: hasAppeared)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Coach")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                Text(CoachEngineAvailability.userFacingStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
        }
        .padding(CalnoraSpacing.medium)
        .calnoraCard(tint: CalnoraColors.coach)
    }

    // MARK: - Suggested prompts

    private var suggestedPrompts: [String] {
        [
            "Plan dinner around my macros",
            "Why might I feel tired today?",
            "Quick high-protein snack ideas",
            "How is my week going?"
        ]
    }

    private var suggestedPromptsView: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            Text("Try asking")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
                .padding(.horizontal, CalnoraSpacing.xSmall)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CalnoraSpacing.small) {
                    ForEach(suggestedPrompts, id: \.self) { prompt in
                        Button {
                            model.input = prompt
                            Task { await send() }
                        } label: {
                            Text(prompt)
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                                .foregroundStyle(CalnoraColors.coach)
                                .padding(.horizontal, CalnoraSpacing.medium)
                                .padding(.vertical, 9)
                                .background(CalnoraColors.coach.opacity(0.14), in: .capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Suggested prompt: \(prompt)")
                    }
                }
                .padding(.horizontal, 1)
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: CalnoraSpacing.small) {
            TextField("Ask your coach", text: $model.input, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .submitLabel(.send)
                .padding(.vertical, 8)
                .padding(.horizontal, CalnoraSpacing.small)

            Button {
                Task { await send() }
            } label: {
                Image(systemName: coachStore.isResponding ? "ellipsis" : "arrow.up")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill((model.canSend && !coachStore.isResponding) ? AnyShapeStyle(CalnoraColors.coach.gradient) : AnyShapeStyle(Color.gray.opacity(0.45)))
                    )
                    .scaleEffect((model.canSend && !coachStore.isResponding) ? 1 : 0.92)
                    .animation(.smooth(duration: 0.25), value: model.canSend)
                    .animation(.smooth(duration: 0.25), value: coachStore.isResponding)
            }
            .disabled(!model.canSend || coachStore.isResponding)
            .accessibilityLabel("Send coach question")
        }
        .padding(.horizontal, CalnoraSpacing.small)
        .padding(.vertical, 6)
        .calnoraCard(cornerRadius: 26, tint: CalnoraColors.coach, isInteractive: true)
        .padding(.horizontal, CalnoraSpacing.medium)
        .padding(.bottom, CalnoraSpacing.small)
    }

    // MARK: - Helpers

    private var quotaText: String {
        if purchaseStore.entitlements.unlocksPro {
            "Unlimited coach questions"
        } else if let remainingUses {
            "\(remainingUses) free coach questions left this week"
        } else {
            "Checking coach quota"
        }
    }

    private var quotaShort: String {
        if let remainingUses {
            "\(remainingUses) left"
        } else {
            "Free tier"
        }
    }

    private func messageTransition(for role: CoachRole) -> AnyTransition {
        let edge: Edge = role == .user ? .trailing : .leading
        return .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .opacity
        )
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.smooth(duration: 0.4)) {
            proxy.scrollTo(bottomAnchorID, anchor: .bottom)
        }
    }

    private func send() async {
        let question = model.input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        guard purchaseStore.entitlements.unlocksPro || (remainingUses ?? 1) > 0 else {
            notificationStore.quotaLimitReached()
            router.push(.paywall, in: .dashboard)
            return
        }
        model.input = ""
        model.appendUserMessage(question)
        let answer = await coachStore.answer(
            question,
            entitlements: purchaseStore.entitlements,
            quotaManager: quotaManager
        )
        if answer == QuotaError.limitReached.localizedDescription {
            notificationStore.quotaLimitReached()
        }
        await model.streamAssistantMessage(answer)
        await refreshQuota()
    }

    private func refreshQuota() async {
        remainingUses = await quotaManager.remainingUses(
            for: .coachQuestion,
            entitlements: purchaseStore.entitlements
        )
    }

    private func animateIn() {
        guard !hasAppeared else { return }
        withAnimation(.smooth(duration: 0.7)) {
            hasAppeared = true
        }
    }
}

// MARK: - Bubble

private struct CoachBubbleView: View {
    var message: CoachChatBubble

    var body: some View {
        HStack(alignment: .bottom, spacing: CalnoraSpacing.small) {
            if message.role == .assistant {
                avatar
                bubble
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubble
            }
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(CalnoraColors.coach.opacity(0.16))
                .frame(width: 30, height: 30)
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(CalnoraColors.coach)
        }
        .accessibilityHidden(true)
    }

    private var bubble: some View {
        Text(message.text)
            .font(.system(.callout, design: .rounded))
            .padding(.horizontal, CalnoraSpacing.medium)
            .padding(.vertical, CalnoraSpacing.small + 2)
            .foregroundStyle(message.role == .assistant ? Color.primary : Color.white)
            .background {
                if message.role == .assistant {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 6,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 20,
                        style: .continuous
                    )
                    .fill(.regularMaterial)
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 6,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: 20,
                            style: .continuous
                        )
                        .stroke(CalnoraColors.coach.opacity(0.15), lineWidth: 1)
                    )
                } else {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 6,
                        topTrailingRadius: 20,
                        style: .continuous
                    )
                    .fill(CalnoraColors.coach.gradient)
                    .shadow(color: CalnoraColors.coach.opacity(0.32), radius: 10, y: 4)
                }
            }
            .multilineTextAlignment(.leading)
            .textSelection(.enabled)
            .accessibilityLabel(message.role == .assistant ? "Coach response" : "Your question")
    }
}

// MARK: - Typing bubble

private struct TypingBubble: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: CalnoraSpacing.small) {
            ZStack {
                Circle()
                    .fill(CalnoraColors.coach.opacity(0.16))
                    .frame(width: 30, height: 30)
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(CalnoraColors.coach)
                    .symbolEffect(.pulse, options: .repeating)
            }
            TimelineView(.animation(minimumInterval: 0.08, paused: false)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                HStack(spacing: 5) {
                    ForEach(0..<3) { i in
                        let phase = sin(t * 4 + Double(i) * 0.7)
                        Circle()
                            .fill(CalnoraColors.coach)
                            .frame(width: 7, height: 7)
                            .opacity(0.35 + (phase + 1) * 0.3)
                            .scaleEffect(0.8 + (phase + 1) * 0.15)
                    }
                }
                .padding(.horizontal, CalnoraSpacing.medium)
                .padding(.vertical, CalnoraSpacing.small + 4)
            }
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 6,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 20,
                    style: .continuous
                )
                .fill(.regularMaterial)
            )
            Spacer(minLength: 40)
        }
        .accessibilityLabel("Coach is typing")
    }
}

#Preview {
    let container = PersistenceController.makeModelContainer(inMemory: true)
    let mealStore = MealStore(context: container.mainContext)
    let nutritionGoalStore = NutritionGoalStore(context: container.mainContext)
    return CoachChatView(quotaManager: QuotaManager())
        .environment(AppRouter())
        .environment(CoachStore(engine: MockCoachEngine(), mealStore: mealStore, nutritionGoalStore: nutritionGoalStore))
        .environment(PurchaseStore())
        .environment(NotificationStore())
}
