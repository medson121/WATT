import SwiftUI

struct ContentView: View {
    @ObservedObject var paywall = PaywallManager.shared
    @State private var hasStartedQuiz = false

    var body: some View {
        Group {
            if paywall.isPro || paywall.hasCompletedFirstFix {
                MainTabView()
                    .transition(.opacity)
            } else {
                if hasStartedQuiz {
                    QuizView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    OnboardingView(onFindVampires: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            hasStartedQuiz = true
                        }
                    })
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: paywall.isPro || paywall.hasCompletedFirstFix)
    }
}

// MARK: - Main Tab View (Home & Vampires) - Only shown after first fix or Pro
struct MainTabView: View {
    @ObservedObject var paywall = PaywallManager.shared

    var body: some View {
        TabView(selection: $paywall.selectedTab) {
            NavigationStack {
                DashboardView(onNavigateToVampires: {
                    withAnimation {
                        paywall.selectedTab = .vampires
                    }
                })
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(PaywallManager.AppTab.home)

            NavigationStack {
                VampireListView()
            }
            .tabItem {
                Label("Vampires", systemImage: "bolt.badge.automatic.fill")
            }
            .tag(PaywallManager.AppTab.vampires)
        }
        .tint(Color(hex: "#3B82F6"))
    }
}

#Preview {
    ContentView()
}
