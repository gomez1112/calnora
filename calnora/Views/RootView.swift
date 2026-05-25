import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router
    @Environment(UserProfileStore.self) private var userProfileStore
    @Environment(NotificationStore.self) private var notificationStore
    @State private var quotaManager = QuotaManager()

    var body: some View {
        @Bindable var appState = appState
        @Bindable var router = router

        Group {
            if appState.hasCompletedOnboarding {
                TabView(selection: $appState.selectedTab) {
                    Tab(AppTab.dashboard.title, systemImage: AppTab.dashboard.systemImage, value: AppTab.dashboard) {
                        NavigationStack(path: $router.dashboardPath) {
                            DashboardView()
                                .navigationDestination(for: AppRoute.self, destination: destination)
                        }
                    }

                    Tab(AppTab.meals.title, systemImage: AppTab.meals.systemImage, value: AppTab.meals) {
                        NavigationStack(path: $router.mealPath) {
                            MealLogView(quotaManager: quotaManager)
                                .navigationDestination(for: AppRoute.self, destination: destination)
                        }
                    }

                    Tab(AppTab.coach.title, systemImage: AppTab.coach.systemImage, value: AppTab.coach) {
                        NavigationStack(path: $router.coachPath) {
                            CoachChatView(quotaManager: quotaManager)
                                .navigationDestination(for: AppRoute.self, destination: destination)
                        }
                    }

                    Tab(AppTab.history.title, systemImage: AppTab.history.systemImage, value: AppTab.history) {
                        NavigationStack(path: $router.historyPath) {
                            HistoryView()
                                .navigationDestination(for: AppRoute.self, destination: destination)
                        }
                    }

                    Tab(AppTab.insights.title, systemImage: AppTab.insights.systemImage, value: AppTab.insights) {
                        NavigationStack(path: $router.insightsPath) {
                            InsightsView()
                                .navigationDestination(for: AppRoute.self, destination: destination)
                        }
                    }

                    Tab(AppTab.settings.title, systemImage: AppTab.settings.systemImage, value: AppTab.settings) {
                        NavigationStack(path: $router.settingsPath) {
                            SettingsView()
                                .navigationDestination(for: AppRoute.self, destination: destination)
                        }
                    }
                }
                .tabViewStyle(.sidebarAdaptable)
                .overlay(alignment: .top) {
                    if let banner = notificationStore.latestBanner {
                        CalnoraBannerView(banner: banner)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .task {
                    await appDidAppear()
                }
                .onChange(of: notificationStore.latestBanner?.id) { _, id in
                    guard let id else { return }
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        if notificationStore.latestBanner?.id == id {
                            notificationStore.latestBanner = nil
                        }
                    }
                }
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            appState.hasCompletedOnboarding = userProfileStore.profile?.hasCompletedOnboarding ?? false
        }
    }

    @ViewBuilder
    private func destination(_ route: AppRoute) -> some View {
        switch route {
        case .mealEditor:
            MealEditorView()
        case .aiMealParse:
            QuickAIMealParseView(quotaManager: quotaManager)
        case .paywall:
            PaywallView()
        case .profile:
            ProfileView()
        case .privacy:
            PrivacyView()
        case .premiumPack:
            PremiumPackView()
        }
    }

    private func appDidAppear() async {
        await notificationStore.refreshPermissionStatus()
    }
}

private struct CalnoraBannerView: View {
    var banner: CalnoraBanner

    var body: some View {
        HStack(spacing: CalnoraSpacing.small) {
            Image(systemName: banner.symbolName)
                .foregroundStyle(CalnoraColors.success)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(banner.title)
                    .font(.subheadline.weight(.semibold))
                Text(banner.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
