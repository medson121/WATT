---
name: swiftui-ui-patterns
description: Apply proven SwiftUI UI patterns for navigation, sheets, async state, and reusable screens.
---

# SwiftUI UI Patterns Skill

## When to Use This Skill
- Creating or refactoring SwiftUI screens, flows, or reusable UI components.
- Designing tabbed navigation with deep-linking and state switching.
- Wiring presentation sheets, modals, popovers, and bottom action bars.
- Managing asynchronous lifecycle with `.task`, loading states, and error presentation.

## Core Patterns

### 1. TabView + NavigationStack
- Pair `TabView(selection: $selectedTab)` with a dedicated enum:
  ```swift
  enum AppTab: Hashable {
      case home
      case list
      case settings
  }
  ```
- Wrap each tab's root view in its own `NavigationStack` so each tab maintains an independent navigation history.
- Tag each tab item with `.tag(AppTab.tabName)` matching the binding type.

### 2. Sheet Presentation Patterns
- Prefer `.sheet(item: $selectedItem)` when presenting detail for a specific model instance to avoid race conditions.
- For modal flows (like Paywalls or Settings), use `.sheet(isPresented: $showSheet)`.
- Sheets should manage their own dismissal via `@Environment(\.dismiss) private var dismiss`.
- Add `presentationDetents([.medium, .large])` and `presentationDragIndicator(.visible)` for interactive partial sheets.

### 3. Asynchronous Data & Task Lifecycle
- Use `.task { await loadData() }` rather than `.onAppear { Task { ... } }` to ensure automatic cancellation when views disappear.
- Represent async operations with explicit states: `idle`, `loading`, `success`, `failure(Error)`.
- Use `ProgressView()` with appropriate tinting for inline and overlay loading indicators.

### 4. Floating Action Bars & Overlays
- For bottom-anchored actions or floating bars, overlay on top of ScrollViews with bottom content padding (`.padding(.bottom, 80)` or similar) so content is never obscured.
- Use `ZStack(alignment: .bottom)` with `.transition(.move(edge: .bottom).combined(with: .opacity))`.
