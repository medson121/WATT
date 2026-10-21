import SwiftUI

// MARK: - OnboardingView
struct OnboardingView: View {
    // Animation states for the two floating ghosts
    @State private var ghost1Floating = false
    @State private var ghost2Floating = false
    @State private var teardropAnimating = false

    var body: some View {
        ZStack {
            // Background color #FFF9F0 covering the entire screen
            Color(hex: "FFF9F0")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Text
                VStack(spacing: 6) {
                    Text("Your home is leaking\n€86/year")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)

                Spacer()

                // MARK: - Middle: Sad Power Outlet & Floating Ghosts
                ZStack {
                    // Ambient power leakage glow behind the outlet
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "3B82F6").opacity(0.12),
                                    Color(hex: "FFF9F0").opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)

                    // Power Outlet Illustration (SwiftUI shapes)
                    SadOutletView(teardropAnimating: teardropAnimating)

                    // Ghost 1 (Top Left)
                    Text("👻")
                        .font(.system(size: 34))
                        .rotationEffect(.degrees(ghost1Floating ? -12 : 4))
                        .offset(x: -95, y: ghost1Floating ? -85 : -65)
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)

                    // Ghost 2 (Right Side)
                    Text("👻")
                        .font(.system(size: 28))
                        .rotationEffect(.degrees(ghost2Floating ? 10 : -6))
                        .offset(x: 95, y: ghost2Floating ? -25 : -5)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .frame(height: 290)

                Spacer()

                // MARK: - Bottom Section
                VStack(spacing: 22) {
                    // "12,482 homes fixed" with stacked circle avatars
                    HStack(spacing: 12) {
                        // Stacked Circle Avatars
                        HStack(spacing: -10) {
                            AvatarCircle(
                                gradientColors: [Color(hex: "FF6B6B"), Color(hex: "FFA07A")],
                                systemIcon: "person.fill"
                            )
                            AvatarCircle(
                                gradientColors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
                                systemIcon: "leaf.fill"
                            )
                            AvatarCircle(
                                gradientColors: [Color(hex: "8B5CF6"), Color(hex: "6366F1")],
                                systemIcon: "bolt.fill"
                            )
                            AvatarCircle(
                                gradientColors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                                systemIcon: "sparkles"
                            )
                        }

                        // Text next to avatars
                        Text("12,482 homes fixed")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "0F2235").opacity(0.85))
                    }

                    // Big Blue Button: "Find my vampires"
                    Button(action: {
                        // Action for discovering vampire energy drains
                    }) {
                        HStack(spacing: 8) {
                            Text("Find my vampires")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(hex: "3B82F6"))
                        )
                        .shadow(color: Color(hex: "3B82F6").opacity(0.38), radius: 14, x: 0, y: 8)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            // Floating animation for Ghost 1 (smooth up and down)
            withAnimation(
                .easeInOut(duration: 2.1)
                .repeatForever(autoreverses: true)
            ) {
                ghost1Floating = true
            }

            // Floating animation for Ghost 2 (independent timing and travel)
            withAnimation(
                .easeInOut(duration: 1.7)
                .repeatForever(autoreverses: true)
            ) {
                ghost2Floating = true
            }

            // Animated teardrop on the sad outlet
            withAnimation(
                .easeInOut(duration: 1.9)
                .repeatForever(autoreverses: false)
            ) {
                teardropAnimating = true
            }
        }
    }
}

// MARK: - Sad Power Outlet View (Built purely with SwiftUI shapes)
struct SadOutletView: View {
    var teardropAnimating: Bool

    var body: some View {
        ZStack {
            // Outer Faceplate (Rounded Rectangle)
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFFFFF"), Color(hex: "F7F4EB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 190, height: 235)
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(Color(hex: "E8E2D2"), lineWidth: 1.5)
                )
                .shadow(color: Color(hex: "0F2235").opacity(0.08), radius: 24, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)

            // Top and Bottom Faceplate Screws
            VStack {
                FaceplateScrew()
                Spacer()
                FaceplateScrew()
            }
            .frame(height: 206)

            // Inner Recessed Socket Basin
            ZStack {
                // Socket Inset Circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "EAE4D5"), Color(hex: "F4EFE3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "D8D0BD"), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)

                // Outlet Sad Face Features
                VStack(spacing: 12) {
                    // Sad Eyes (Angled vertical plug socket prongs)
                    HStack(spacing: 34) {
                        SadOutletEye(eyebrowAngle: 12)
                        SadOutletEye(eyebrowAngle: -12)
                    }
                    .padding(.top, 4)

                    // Sad Frown Mouth & Ground Hole
                    ZStack {
                        // Downturned curved mouth
                        FrownPath()
                            .stroke(
                                Color(hex: "1F2937"),
                                style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                            )
                            .frame(width: 26, height: 10)

                        // Ground slot / chin notch
                        Capsule()
                            .fill(Color(hex: "1F2937"))
                            .frame(width: 7, height: 5)
                            .offset(y: 16)
                    }

                    // Soft pink blush on cheeks
                    HStack(spacing: 62) {
                        Circle()
                            .fill(Color(hex: "FF8A8A").opacity(0.45))
                            .frame(width: 14, height: 14)
                            .blur(radius: 1.5)

                        Circle()
                            .fill(Color(hex: "FF8A8A").opacity(0.45))
                            .frame(width: 14, height: 14)
                            .blur(radius: 1.5)
                    }
                    .offset(y: -14)
                }

                // Tiny falling teardrop
                TeardropShape()
                    .fill(Color(hex: "60A5FA"))
                    .frame(width: 6, height: 9)
                    .offset(x: 24, y: teardropAnimating ? 14 : -2)
                    .opacity(teardropAnimating ? 0.1 : 0.85)
            }
        }
    }
}

// MARK: - Sad Outlet Eye (Socket Prong + Droopy Brow)
struct SadOutletEye: View {
    var eyebrowAngle: Double

    var body: some View {
        VStack(spacing: 3) {
            // Sad tilted eyebrow notch
            Capsule()
                .fill(Color(hex: "243342").opacity(0.65))
                .frame(width: 14, height: 2.5)
                .rotationEffect(.degrees(eyebrowAngle))

            // Socket prong slot (vertical capsule)
            Capsule()
                .fill(Color(hex: "1F2937"))
                .frame(width: 7, height: 22)
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "111827"), lineWidth: 1)
                )
        }
    }
}

// MARK: - Faceplate Screw Shape
struct FaceplateScrew: View {
    var body: some View {
        Circle()
            .fill(Color(hex: "DBD3BF"))
            .frame(width: 9, height: 9)
            .overlay(
                Rectangle()
                    .fill(Color(hex: "9F9580"))
                    .frame(width: 6, height: 1.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Frown Curve Shape (Inverted Arc)
struct FrownPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        return path
    }
}

// MARK: - Teardrop Shape
struct TeardropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY + rect.height * 0.2),
            control: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.2)
        )
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.2),
            radius: rect.width / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.2)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Avatar Circle (For Social Proof Stack)
struct AvatarCircle: View {
    var gradientColors: [Color]
    var systemIcon: String

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: systemIcon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 32, height: 32)
        .overlay(
            Circle()
                .stroke(Color(hex: "FFF9F0"), lineWidth: 2.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1.5)
    }
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - SwiftUI Preview
#Preview {
    OnboardingView()
}
