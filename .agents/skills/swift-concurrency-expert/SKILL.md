---
name: swift-concurrency-expert
description: Review and fix Swift concurrency issues such as actor isolation, data races, and Sendable violations in Swift 6+.
---

# Swift Concurrency Expert Skill

## When to Use This Skill
- Resolving Swift compiler errors and warnings regarding concurrency, data races, and actor isolation.
- Deciding between `@MainActor`, `actor`, and `nonisolated` functions.
- Designing thread-safe observable view models and singleton services.
- Implementing background async tasks without blocking the main UI thread.

## Concurrency Rules & Patterns

### 1. UI & State Binding with `@MainActor`
- Annotate `ObservableObject` classes or `@Observable` classes with `@MainActor`:
  ```swift
  @MainActor
  final class MyViewModel: ObservableObject {
      @Published var items: [Item] = []
  }
  ```
- Any property that updates SwiftUI views must be mutated exclusively on the `@MainActor`.
- For background work inside a `@MainActor` class, perform the computation or network fetch detached or in a non-isolated helper, then resume or assign on the main actor.

### 2. Sendable Conformance
- Make data models and transfer objects immutable structs with `Sendable` conformance where possible.
- Avoid passing mutable reference types across actor boundaries.
- If a class must cross concurrency boundaries, consider making it an `actor` instead of a `class`.

### 3. Asynchronous Tasks in SwiftUI
- Use `.task` view modifiers which inherit the `@MainActor` context by default and are bound to the view's lifecycle.
- When spawning unconstrained asynchronous work from UI buttons, use `Task { await performAction() }`.
- Always handle cancellation gracefully (`try Task.checkCancellation()`).

### 4. Singletons & Shared Services
- If a shared service interacts with SwiftUI state (e.g. `PaywallManager`, `SupabaseManager`), annotate the class with `@MainActor`:
  ```swift
  @MainActor
  public class SharedManager: ObservableObject {
      public static let shared = SharedManager()
  }
  ```
- This guarantees all notifications, `@Published` updates, and property mutations occur safely without thread hops.
