---
name: ios-developer
description: Develop native iOS applications with Swift and SwiftUI. Masters iOS 18+, SwiftUI, UIKit integration, Swift Concurrency, networking, and App Store optimization.
---

# iOS Developer Skill

## When to Use This Skill
- Building, refining, or debugging native iOS applications in Swift and SwiftUI.
- Implementing state management, navigation architectures, and responsive view composition.
- Integrating networking (URLSession, async/await), caching, and local persistence.
- Ensuring HIG (Human Interface Guidelines) compliance and App Store readiness.

## Capabilities & Directives

### 1. Modern SwiftUI & State Management
- Use Swift 6 strict concurrency patterns (`@MainActor`, `Sendable`, actors).
- Prefer SwiftUI native state primitives:
  - `@State` for local value types owned by the view.
  - `@Binding` for two-way state references passed from parents.
  - `@Observable` (iOS 17+) for clean observable models, or `ObservableObject` with `@StateObject` (creation) / `@ObservedObject` (injected) for iOS 16 compatibility.
  - `@Environment` and `@EnvironmentObject` for shared app-wide state.
- Keep view bodies declarative, lightweight, and focused on presentation. Extract subviews early to avoid invalidation storms.

### 2. Navigation & Architecture
- Use `NavigationStack` with type-safe `.navigationDestination(for:)` or `.navigationDestination(isPresented:)`.
- Implement clean tabbed navigation using `TabView(selection:)` paired with dedicated enums.
- Present sheets cleanly with `.sheet(isPresented:)` or `.sheet(item:)`, ensuring sheets manage their own dismissal via `@Environment(\.dismiss)`.

### 3. Networking & Storage
- Use `URLSession.shared.data(for:)` with `async/await` and robust HTTP status error handling.
- Decode responses using `JSONDecoder()` and `Codable` models with explicit `CodingKeys`.
- Use `UserDefaults` with property wrappers or `@AppStorage` for lightweight flags (e.g. user preferences, first-fix completion).
- Handle offline resilience and loading states with explicit indicators (`ProgressView`).

### 4. Apple Design & Polish
- Implement rich, modern aesthetics: subtle shadows, glassmorphism, curated color palettes, SF Symbols with hierarchical or palette rendering.
- Add tactile feedback using `UIImpactFeedbackGenerator` or `sensoryFeedback` modifiers.
- Ensure all interactive controls have minimum 44x44 pt tap targets.
