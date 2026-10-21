# WATT - iOS App (SwiftUI)

An iOS application built in **SwiftUI** designed to detect and eliminate phantom power loss ("vampire energy") in homes.

## Project Structure

```text
├── WATTApp.swift            # @main application entry point
├── ContentView.swift        # Root container hosting OnboardingView with #Preview
├── OnboardingView.swift     # Onboarding screen featuring:
│                            #  - Top title: "Your home is leaking €86/year" (#0F2235)
│                            #  - Custom sad outlet illustration using SwiftUI shapes
│                            #  - 2 animated floating ghost emojis (👻)
│                            #  - Social proof avatars + "12,482 homes fixed"
│                            #  - "Find my vampires" button (#3B82F6) with shadow
│                            #  - Background color #FFF9F0
│                            #  - Modern #Preview support
├── Assets.xcassets/         # App icon & global accent color asset catalog
└── WATT.xcodeproj/          # Xcode project configuration
```

## Highlights & Features

- **Pure SwiftUI**: 100% SwiftUI implementation with **zero UIKit dependencies**.
- **Sad Outlet Illustration**: Built entirely with native SwiftUI vectors and shapes (`RoundedRectangle`, `Circle`, `Capsule`, and custom `FrownPath` & `TeardropShape`).
- **Smooth Micro-Animations**: Two floating ghost emojis (`👻`) animate up and down with independent timing and rotation.
- **Accurate Color Palette**:
  - Background: `#FFF9F0` (warm ivory)
  - Text & Accents: `#0F2235` (deep midnight navy)
  - Action Button: `#3B82F6` (vibrant electric blue) with shadow
- **Interactive Previews**: Works out of the box with `#Preview` in Xcode 15+ / iOS 17+.

## Opening the Project in Xcode

1. Open `WATT.xcodeproj` in Xcode (or open the project folder in Swift Playgrounds).
2. Select any iOS Simulator (e.g., iPhone 15 / 16 Pro).
3. Open `OnboardingView.swift` or `ContentView.swift` to see the live Canvas `#Preview`, or press **⌘R** to build and run.
