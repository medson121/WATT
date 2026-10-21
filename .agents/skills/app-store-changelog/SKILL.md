---
name: app-store-changelog
description: Generate user-facing App Store release notes and "What's New" text from git commit history and product features.
---

# App Store Changelog Skill

## When to Use This Skill
- Preparing App Store submission metadata, "What's New in this Version" release notes, and TestFlight release notes.
- Translating technical git commits and PRs into punchy, benefit-focused bullet points for end users.
- Formatting release announcements for marketing, Twitter/X, and product updates.

## Guidelines & Tone

### 1. User Benefit First
- Never include technical jargon (e.g. "fixed nil pointer exception", "refactored view model", "updated podfile").
- Frame every change as a tangible user benefit:
  - *Bad*: "Refactored DashboardView with GeometryReader"
  - *Good*: "✨ Smoother animations and instant progress tracking on your daily dashboard."
  - *Bad*: "Integrated PaywallManager with UserDefaults"
  - *Good*: "⚡️ Unlocked full home protection with effortless annual plans and offline habit streaks."

### 2. Standard Structure
- **Headline / Hook**: 1 sentence summarizing the update (e.g. "Introducing your daily energy savings dashboard!").
- **Key Highlights**: 3–6 emoji-bulleted points grouped by impact:
  - 🌟 **New**: Major new features and screens.
  - ⚡️ **Improved**: Performance enhancements and design polish.
  - 🛠️ **Fixed**: Bug fixes and stability improvements.
- **Closing**: Encouraging call-to-action (e.g. "Keep saving energy and growing your forest!").
