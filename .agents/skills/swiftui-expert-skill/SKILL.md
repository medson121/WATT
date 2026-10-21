---
name: swiftui-expert-skill
description: Write, review, and refactor SwiftUI for iOS and macOS, covering data flow, view composition, performance, identity, environment, localization, animation, and UI patterns.
---

# SwiftUI Expert Skill

## When to Use This Skill
- Writing, reviewing, or refactoring SwiftUI views, layouts, and components.
- Designing data flow between `@State`, `@Binding`, `@Observable`, and environment dependencies.
- Eliminating excessive view re-evaluations, layout hitches, and animation bugs.
- Structuring complex screens into decoupled, reusable, and testable subviews.

## Operating Principles

### 1. View Composition & Data Flow
- Separate view identity from view state: provide stable identifiers for lists and `ForEach`.
- Derive values directly during body evaluation when calculation is trivial, but avoid heavy computations or object instantiations inside `body`.
- Break monolithic views into subviews: each subview should observe only the slice of state it needs to render.
- Keep state local to the view that needs it; pass data down via parameters or `@Binding`.

### 2. Animations & Micro-Interactions
- Use explicit animations (`withAnimation(.spring(...)) { ... }`) when changes are triggered by user actions.
- Use `.animation(_:value:)` tied to specific equatable state values rather than unconstrained `.animation(...)`.
- Prefer spring animations (`.spring(response:dampingFraction:)`) for natural physical motion (scale, translation, bounce).
- For numeric changes, use `.contentTransition(.numericText())` to animate digits smoothly.

### 3. Glassmorphism & Visual Polish
- Use layered backgrounds with translucent gradients and subtle material blurs (`.background(.ultraThinMaterial)` or `Color.opacity()`).
- Add depth with double borders: a subtle outer border (`Color.white.opacity(0.2)`) and light ambient shadows (`radius: 10-20, y: 4-10`).
- Ensure dark mode and light mode contrast remain WCAG AA compliant.

### 4. Code Quality & Modern APIs
- Always gate OS-specific APIs with `#available` checks when necessary.
- Prefer `Button` for all tappable controls to ensure proper accessibility traits and pressed states.
- Cleanly handle safe areas using `.ignoresSafeArea()` where background color or hero visuals bleed to the screen edges.
