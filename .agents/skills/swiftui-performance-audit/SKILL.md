---
name: swiftui-performance-audit
description: Audit and optimize SwiftUI runtime performance issues, render bottlenecks, invalidation storms, and animation hitches.
---

# SwiftUI Performance Audit Skill

## When to Use This Skill
- Diagnosing slow rendering, janky scrolling, dropped frames, or high CPU/battery usage in SwiftUI.
- Investigating layout thrash and unexpected broad view re-evaluations.
- Profiling and streamlining memory consumption, image decoding, and complex view hierarchies.

## Audit Checklist & Diagnostics

### 1. View Invalidation Storms
- **Check View Identity**: Ensure items in `ForEach` have stable, unique `id` properties (e.g. `item.id`), never volatile indexes unless the collection is completely static.
- **Scope State Reads**: If a parent view observes a large object, every property change triggers parent re-rendering. Pass only the needed primitives or isolate child components so updates are localized.
- **Check Equatability**: Conform subviews to `Equatable` and apply `.equatable()` if parent body evaluates frequently but child input rarely changes.

### 2. Heavy Computations in `body`
- Never compute complex hashes, date formatters, or network requests directly inside the view's `body` property.
- Instantiate formatters (`DateFormatter`, `NumberFormatter`) once as `static let` constants, not inside `body`.
- Cache or derive values in a ViewModel or background task.

### 3. Layout Thrashing & Over-Nesting
- Avoid deeply nested `GeometryReader` instances; use them only where exact dynamic sizing is required.
- Limit heavy blur and shadow effects on scrollable lists. Prefer precomputed or subtle rasterized shadows for high-fps scrolling.

### 4. Image & Resource Management
- Downsample large images before display rather than rendering multi-megapixel images in small frame sizes.
- Use `AsyncImage` with placeholder states and appropriate caching for remote graphics.
