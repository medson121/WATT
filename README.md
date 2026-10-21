# WATT - iOS App (SwiftUI)

An iOS application built in **SwiftUI** designed to detect and eliminate phantom power loss ("vampire energy") in European households.

## Architecture & Complete Flow

```text
├── WATTApp.swift            # @main app entry point with @StateObject PaywallManager & SupabaseManager
├── ContentView.swift        # Root router: displays MainTabView if isPro or hasCompletedFirstFix; else Onboarding flow
├── OnboardingView.swift     # Onboarding screen with sad outlet & animated floating ghosts
├── QuizView.swift           # Vampire appliance selection & European country energy price picker
├── AhaCalculationView.swift # Calculation screen with dynamic counter, metrics & cognitive anchor
├── VampireListView.swift    # Vampires list with live audit, Pro gating & Supabase sync
├── FixAnimationView.swift   # 4-phase fix animation (shock, wrench repair, coin launch & victory)
├── PaywallView.swift        # High-converting paywall (€29.99/year or €4.99/month, 3-day free trial)
├── DashboardView.swift      # Retention dashboard: streak, forest growth, metrics & daily challenge
├── RevenueCatManager.swift  # PaywallManager singleton managing subscription, tabs & navigation
├── SupabaseManager.swift    # Supabase cloud REST client for country prices & daily checks
├── SavingsViewModel.swift   # Reactive calculation engine & PostHog analytics
├── PriceData.swift          # European country energy tariff presets & calculation formulas
├── Color+Hex.swift          # Hex color parsing utility
├── Assets.xcassets/         # App icon & global accent asset catalog
└── WATT.xcodeproj/          # Xcode project configuration
```

## User Journey

1. **Onboarding**: User is introduced to vampire power leaks (€86/year) and taps *Find my vampires*.
2. **Quiz**: User selects plugged-in appliances and their country (Germany, Ireland, Belgium, Denmark, UK, Netherlands).
3. **Aha Calculation**: Shows annual money leaking, carbon footprint, and cognitive equivalence anchor.
4. **First Free Fix**: User fixes their first vampire in `VampireListView` with a dopamine-rich animation (`FixAnimationView`).
5. **Paywall & Habit Loop**:
   - `PaywallManager.shared.completeFirstFix()` triggers the paywall after a 1.5s delay.
   - Root switches to `MainTabView` with **Home** (`DashboardView`) and **Vampires** (`VampireListView`).
   - On `DashboardView`, the "Today's challenge" button navigates directly to `VampireListView`.
   - When `purchase()` succeeds, `isPro` is set to `true`, paywall sheet dismisses, and user returns to `DashboardView`.
