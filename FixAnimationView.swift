import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - ShakeEffect (GeometryEffect for violent spooked shake)
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 6
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

// MARK: - Radial Star Particle for Victory Explosion
struct StarParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: CGFloat
    let color: Color
    let size: CGFloat
}

// MARK: - FixAnimationView
struct FixAnimationView: View {
    let deviceName: String
    let room: String
    let watts: Double
    let yearlyCost: Double
    let dailySavingsFormatted: String
    let onComplete: () -> Void

    // MARK: - Animation Phase States
    // Phase 0: Leaking (initial)
    // Phase 1: Spooked / Shake (0.5s)
    // Phase 2: Wrench Repair (360° spring spin)
    // Phase 3: Victory (Happy smile, dissipated ghost, coin launch, star explosion)
    @State private var phase: Int = 0

    // Shake animation trigger
    @State private var shakeProgress: CGFloat = 0

    // Wrench repair states
    @State private var wrenchScale: CGFloat = 0.0
    @State private var wrenchRotation: Double = 0.0
    @State private var wrenchOpacity: Double = 0.0

    // Ghost / Volt Companion states
    @State private var voltMood: VampireMood = .leaking
    @State private var ghostScale: CGFloat = 1.0
    @State private var ghostOpacity: Double = 1.0
    @State private var ghostOffsetY: CGFloat = 0.0

    // Outlet face expression (false = sad, true = happy)
    @State private var isOutletHappy: Bool = false

    // Lightning bolts sucking energy
    @State private var lightningPulsing: Bool = false

    // Coin & Victory states
    @State private var coinOffsetY: CGFloat = 20
    @State private var coinScale: CGFloat = 0.4
    @State private var coinOpacity: Double = 0.0
    @State private var cardScale: CGFloat = 1.0

    // Victory particle explosion
    @State private var particlesExploded: Bool = false
    @State private var particles: [StarParticle] = []

    var body: some View {
        ZStack {
            // Darkened frosted backdrop
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {
                    if phase == 3 {
                        onComplete()
                    }
                }

            // Main Animation Card
            VStack(spacing: 20) {
                // Top Tag
                HStack(spacing: 6) {
                    Text(room.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235").opacity(0.6))

                    Text("•")
                        .foregroundColor(Color(hex: "0F2235").opacity(0.3))

                    Text(String(format: "%.1fW Standby", watts))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "D97706"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(hex: "FEF3C7"))
                )

                // Device Title
                Text(deviceName)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235"))
                    .multilineTextAlignment(.center)

                // MARK: - Central Illustration Stage
                ZStack {
                    // Particle Explosion in Phase 3
                    ForEach(particles) { p in
                        Image(systemName: "star.fill")
                            .font(.system(size: p.size))
                            .foregroundColor(p.color)
                            .offset(
                                x: particlesExploded ? cos(p.angle * .pi / 180) * p.distance : 0,
                                y: particlesExploded ? sin(p.angle * .pi / 180) * p.distance : 0
                            )
                            .opacity(particlesExploded ? 0.0 : 1.0)
                            .scaleEffect(particlesExploded ? 0.2 : 1.2)
                            .animation(
                                .easeOut(duration: 0.85),
                                value: particlesExploded
                            )
                    }

                    // Ambient Outlet Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    isOutletHappy ? Color(hex: "10B981").opacity(0.20) : Color(hex: "3B82F6").opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 130
                            )
                        )
                        .frame(width: 240, height: 240)

                    // Expressive Wall Socket
                    AnimatedOutletView(isHappy: isOutletHappy)

                    // Lightning Bolts (sucking energy in Phase 0)
                    if phase == 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "FACC15"))
                                .rotationEffect(.degrees(lightningPulsing ? 15 : -15))
                                .offset(x: -36, y: -28)

                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "F59E0B"))
                                .rotationEffect(.degrees(lightningPulsing ? -20 : 10))
                                .offset(x: -24, y: 15)
                        }
                        .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true), value: lightningPulsing)
                    }

                    // The Volt Companion Character
                    VampireCharacterView(
                        mood: voltMood,
                        size: 80,
                        showBubble: phase == 3
                    )
                    .offset(x: 55, y: -25 + ghostOffsetY)
                    .scaleEffect(ghostScale)
                    .modifier(ShakeEffect(animatableData: shakeProgress))

                    // Spinning Wrench (Phase 2)
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color(hex: "3B82F6"))
                        .shadow(color: Color(hex: "1D4ED8").opacity(0.35), radius: 12, x: 0, y: 6)
                        .scaleEffect(wrenchScale)
                        .rotationEffect(.degrees(wrenchRotation))
                        .opacity(wrenchOpacity)

                    // Flying Golden Coin (Phase 3)
                    HStack(spacing: 6) {
                        Image(systemName: "eurosign.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "F59E0B"))

                        Text("+\(dailySavingsFormatted) today")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "0F2235"))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "FEF3C7"))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "FCD34D"), lineWidth: 1.5)
                    )
                    .shadow(color: Color(hex: "F59E0B").opacity(0.35), radius: 10, x: 0, y: 4)
                    .offset(y: coinOffsetY)
                    .scaleEffect(coinScale)
                    .opacity(coinOpacity)
                }
                .frame(height: 220)

                // Bottom Status / Callout
                VStack(spacing: 14) {
                    if phase < 3 {
                        Text(phase == 0 ? "Leaking €\(String(format: "%.2f", yearlyCost))/year on standby..." : "Eliminating vampire...")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "0F2235").opacity(0.7))

                        // Button to trigger or auto-running indicator
                        Button(action: {
                            if phase == 0 {
                                startFixSequence()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "wrench.fill")
                                    .font(.system(size: 16, weight: .bold))

                                Text(phase == 0 ? "FIX THIS VAMPIRE" : "FIXING...")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "3B82F6"), Color(hex: "1D4ED8")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color(hex: "1D4ED8").opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .disabled(phase > 0)
                    } else {
                        // Success View
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color(hex: "10B981"))
                                    .font(.system(size: 20))

                                Text("Vampire Eliminated!")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(hex: "0F2235"))
                            }

                            Text("You save €\(String(format: "%.2f", yearlyCost)) every year.")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235").opacity(0.7))
                        }

                        Button(action: {
                            onComplete()
                        }) {
                            Text("Done")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(hex: "10B981"))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color(hex: "10B981").opacity(0.35), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(hex: "FFF9F0"))
                    .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
            )
            .padding(.horizontal, 24)
            .scaleEffect(cardScale)
        }
        .onAppear {
            generateParticles()
            lightningPulsing = true
            // Auto start the sequence shortly after appearing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if phase == 0 {
                    startFixSequence()
                }
            }
        }
    }

    // MARK: - Fix Sequence Choreography
    private func startFixSequence() {
        // === FASE 1: SUSTO (Ghost gets shocked and shakes) ===
        phase = 1
        voltMood = .guilty
        lightningPulsing = false

        withAnimation(.easeInOut(duration: 0.5)) {
            shakeProgress = 1.0
        }

        // === FASE 2: REPARO (Wrench appears, spins 360°) ===
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            phase = 2

            // Pop wrench in with spring
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                wrenchScale = 1.2
                wrenchRotation = 360
                wrenchOpacity = 1.0
            }

            // Squash card slightly
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardScale = 0.96
            }
        }

        // === FASE 3: VITÓRIA ===
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            phase = 3

            // Double haptic feedback
            triggerDoubleHaptic()

            // 1. Outlet becomes happy and Volt celebrates with particles
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                isOutletHappy = true
                cardScale = 1.0
                voltMood = .celebrating
            }

            // 2. Hide wrench smoothly
            withAnimation(.easeOut(duration: 0.3)) {
                wrenchScale = 0.0
                wrenchOpacity = 0.0
            }

            // 3. Launch golden coin upwards with bounce spring
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                coinScale = 1.15
                coinOffsetY = -95
                coinOpacity = 1.0
            }

            // 4. Explode 360° particles
            particlesExploded = true

            // 5. Transform Volt into fixed guardian (folha 🌿)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    voltMood = .fixed
                }
            }
        }
    }

    private func generateParticles() {
        var items: [StarParticle] = []
        let colors = [
            Color(hex: "FACC15"),
            Color(hex: "F59E0B"),
            Color(hex: "10B981"),
            Color(hex: "3B82F6"),
            Color(hex: "EC4899")
        ]
        for i in 0..<20 {
            let angle = Double(i) * (360.0 / 20.0)
            let dist = CGFloat.random(in: 75...115)
            let color = colors[i % colors.count]
            let size = CGFloat.random(in: 12...18)
            items.append(StarParticle(angle: angle, distance: dist, color: color, size: size))
        }
        self.particles = items
    }

    private func triggerDoubleHaptic() {
        #if canImport(UIKit)
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        heavy.prepare()
        heavy.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            let notif = UINotificationFeedbackGenerator()
            notif.notificationOccurred(.success)
        }
        #endif
    }
}

// MARK: - Animated Outlet View (Sad vs Happy)
struct AnimatedOutletView: View {
    let isHappy: Bool

    var body: some View {
        ZStack {
            // Faceplate
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(hex: "F7F4EB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 150, height: 180)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(isHappy ? Color(hex: "A7F3D0") : Color(hex: "E8E2D2"), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 7)

            // Inset circular basin
            Circle()
                .fill(Color(hex: isHappy ? "F0FDF4" : "EFEAE0"))
                .frame(width: 112, height: 112)
                .overlay(
                    Circle()
                        .stroke(Color(hex: isHappy ? "BBF7D0" : "D8D0BD"), lineWidth: 1.2)
                )

            // Face Features
            VStack(spacing: 8) {
                // Eyes (Prongs)
                HStack(spacing: 28) {
                    if isHappy {
                        // Happy curved wink / cheerful eyes
                        HappyEyeShape()
                            .stroke(Color(hex: "1F2937"), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .frame(width: 14, height: 8)
                        HappyEyeShape()
                            .stroke(Color(hex: "1F2937"), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .frame(width: 14, height: 8)
                    } else {
                        // Sad vertical prongs
                        Capsule()
                            .fill(Color(hex: "1F2937"))
                            .frame(width: 6, height: 18)
                        Capsule()
                            .fill(Color(hex: "1F2937"))
                            .frame(width: 6, height: 18)
                    }
                }
                .padding(.top, isHappy ? 4 : 0)

                // Mouth
                ZStack {
                    if isHappy {
                        // Wide happy smile
                        HappySmileShape()
                            .stroke(Color(hex: "1F2937"), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .frame(width: 24, height: 10)
                    } else {
                        // Sad frown
                        FrownPath()
                            .stroke(Color(hex: "1F2937"), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .frame(width: 22, height: 8)
                    }

                    // Ground hole
                    Capsule()
                        .fill(Color(hex: "1F2937"))
                        .frame(width: 6, height: 4)
                        .offset(y: 13)
                }

                // Cheeks (Rosy blush)
                HStack(spacing: 50) {
                    Circle()
                        .fill(Color(hex: isHappy ? "F472B6" : "FF8A8A").opacity(isHappy ? 0.65 : 0.35))
                        .frame(width: 12, height: 12)
                        .blur(radius: 1)

                    Circle()
                        .fill(Color(hex: isHappy ? "F472B6" : "FF8A8A").opacity(isHappy ? 0.65 : 0.35))
                        .frame(width: 12, height: 12)
                        .blur(radius: 1)
                }
                .offset(y: -10)
            }
        }
    }
}

// MARK: - Shapes for Happy Expression
struct HappyEyeShape: Shape {
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

struct HappySmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

// MARK: - Preview
#Preview("FixAnimationView") {
    FixAnimationView(
        deviceName: "Gaming Console",
        room: "Living Room",
        watts: 13.5,
        yearlyCost: 18.60,
        dailySavingsFormatted: "€0.05",
        onComplete: {}
    )
}
