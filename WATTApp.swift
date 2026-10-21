import SwiftUI

@main
struct WATTApp: App {
    @StateObject private var paywall = PaywallManager.shared
    @StateObject private var supabase = SupabaseManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(paywall)
                .environmentObject(supabase)
        }
    }
}
