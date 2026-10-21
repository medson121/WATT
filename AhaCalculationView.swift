import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 1. MODELO DE DADOS: CountryPrice
struct CountryPrice: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let flag: String
    let currencySymbol: String
    let pricePerKWh: Double

    static let germany = CountryPrice(
        id: "DE",
        name: "Germany",
        flag: "🇩🇪",
        currencySymbol: "€",
        pricePerKWh: 0.3869
    )

    static let uk = CountryPrice(
        id: "GB",
        name: "United Kingdom",
        flag: "🇬🇧",
        currencySymbol: "£",
        pricePerKWh: 0.3400
    )

    static let france = CountryPrice(
        id: "FR",
        name: "France",
        flag: "🇫🇷",
        currencySymbol: "€",
        pricePerKWh: 0.2516
    )

    static let presets: [CountryPrice] = [.germany, .uk, .france]
}

// MARK: - Count-Up AnimatableModifier
struct CountUpModifier: AnimatableModifier {
    var value: Double
    var currencySymbol: String

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func body(content: Content) -> some View {
        Text("\(currencySymbol)\(String(format: "%.2f", value))")
            .font(.system(size: 54, weight: .heavy, design: .rounded))
            .foregroundColor(Color(hex: "0F2235"))
            .monospacedDigit()
    }
}

// MARK: - Confetti Particle Model & View
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let symbol: String
    let color: Color
    let size: CGFloat
    let xOffset: CGFloat
    let targetY: CGFloat
    let rotationTarget: Double
    let duration: Double
    let delay: Double
}

struct ConfettiShowerView: View {
    let particles: [ConfettiParticle]
    @State private var isFalling = false

    init() {
        let symbols = ["star.fill", "sparkle", "bolt.fill"]
        let colors = [
            Color(hex: "FACC15"),
            Color(hex: "F59E0B"),
            Color(hex: "FDE047"),
            Color(hex: "FB923C")
        ]

        var generated: [ConfettiParticle] = []
        for index in 0..<26 {
            let symbol = symbols[index % symbols.count]
            let color = colors[index % colors.count]
            let size = CGFloat.random(in: 10...20)
            let xOffset = CGFloat.random(in: -170...170)
            let targetY = CGFloat.random(in: 180...420)
            let rotation = Double.random(in: 180...720)
            let duration = Double.random(in: 1.8...3.0)
            let delay = Double.random(in: 0.05...0.65)

            generated.append(
                ConfettiParticle(
                    symbol: symbol,
                    color: color,
                    size: size,
                    xOffset: xOffset,
                    targetY: targetY,
                    rotationTarget: rotation,
                    duration: duration,
                    delay: delay
                )
            )
        }
        self.particles = generated
    }

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Image(systemName: p.symbol)
                    .font(.system(size: p.size))
                    .foregroundColor(p.color)
                    .offset(x: p.xOffset, y: isFalling ? p.targetY : -40)
                    .rotationEffect(.degrees(isFalling ? p.rotationTarget : 0))
                    .opacity(isFalling ? 0.0 : 0.95)
                    .animation(
                        .easeInOut(duration: p.duration)
                        .delay(p.delay),
                        value: isFalling
                    )
            }
        }
        .onAppear {
            isFalling = true
        }
    }
}

// MARK: - AhaCalculationView
struct AhaCalculationView: View {
    let totalWatts: Double
    let country: CountryPrice

    // MARK: - 2. FÓRMULAS MATEMÁTICAS & CÁLCULOS
    var kwhPerYear: Double {
        (totalWatts * 18.0 * 365.0) / 1000.0
    }

    var eurosPerYear: Double {
        kwhPerYear * country.pricePerKWh
    }

    var co2KgPerYear: Double {
        kwhPerYear * 0.40
    }

    var treesEquivalent: Int {
        max(1, Int(round(co2KgPerYear / 21.0)))
    }

    // Dynamic cognitive anchoring comparison based on cost
    var comparisonAnchor: (title: String, highlight: String, icon: String) {
        if eurosPerYear < 45.0 {
            return (
                "That's 4 months of Spotify Premium 🎵",
                "Small leak, but adds up silently every day!",
                "headphones"
            )
        } else if eurosPerYear < 110.0 {
            return (
                "That's 2 years of Netflix 🍿",
                "Or 2 flights Berlin → Paris ✈️",
                "popcorn.fill"
            )
        } else {
            return (
                "That's 4 flights Berlin → Paris ✈️",
                "Or a relaxing weekend getaway trip 🏖️",
                "airplane.departure"
            )
        }
    }

    // MARK: - 4. ESTADOS DE ANIMAÇÃO & COREOGRAFIA
    @State private var animatedEuros: Double = 0.0
    @State private var headerAppeared: Bool = false
    @State private var card1Appeared: Bool = false
    @State private var card2Appeared: Bool = false
    @State private var card3Appeared: Bool = false
    @State private var comparisonAppeared: Bool = false
    @State private var ctaAppeared: Bool = false
    @State private var ctaPulse: Bool = false

    var body: some View {
        ZStack {
            // Fundo creme #FFF9F0 com degradê vertical sutil para #FFF4E6
            LinearGradient(
                colors: [Color(hex: "FFF9F0"), Color(hex: "FFF4E6")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Efeito Confete no topo
            VStack {
                ConfettiShowerView()
                    .frame(height: 100)
                Spacer()
            }
            .ignoresSafeArea()

            // Conteúdo principal
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: - Topo WOW (Hero Metric)
                    VStack(spacing: 12) {
                        // Badge discreto: "⚡️ Vampire Leak Detected" com bandeira
                        HStack(spacing: 6) {
                            Text(country.flag)
                                .font(.system(size: 14))
                            Text("⚡️ Vampire Leak Detected")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "D97706"))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color(hex: "FEF3C7"))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "FCD34D"), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "F59E0B").opacity(0.12), radius: 6, x: 0, y: 2)

                        // Número Principal com Count-Up animado
                        Color.clear
                            .frame(height: 60)
                            .modifier(
                                CountUpModifier(
                                    value: animatedEuros,
                                    currencySymbol: country.currencySymbol
                                )
                            )

                        // Subtítulo
                        Text("per year leaking from your outlets 👻")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "0F2235").opacity(0.70))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 18)
                    .scaleEffect(headerAppeared ? 1.0 : 0.88)
                    .opacity(headerAppeared ? 1.0 : 0.0)

                    // MARK: - 3 Cards em Linha (Métricas)
                    HStack(spacing: 10) {
                        // Card 1: Energy Wasted
                        MetricCardView(
                            iconName: "bolt.fill",
                            iconColor: Color(hex: "F59E0B"),
                            iconBackground: Color(hex: "FEF3C7"),
                            metricValue: String(format: "%.0f kWh", kwhPerYear),
                            title: "Energy wasted",
                            subtitle: "Standby power"
                        )
                        .offset(y: card1Appeared ? 0 : 32)
                        .opacity(card1Appeared ? 1 : 0)

                        // Card 2: Money Lost
                        MetricCardView(
                            iconName: "eurosign.circle.fill",
                            iconColor: Color(hex: "3B82F6"),
                            iconBackground: Color(hex: "DBEAFE"),
                            metricValue: "\(country.currencySymbol)\(String(format: "%.0f", eurosPerYear))",
                            title: "Money lost",
                            subtitle: "\(country.currencySymbol)\(String(format: "%.2f", country.pricePerKWh))/kWh"
                        )
                        .offset(y: card2Appeared ? 0 : 32)
                        .opacity(card2Appeared ? 1 : 0)

                        // Card 3: Carbon / Trees
                        MetricCardView(
                            iconName: "leaf.fill",
                            iconColor: Color(hex: "10B981"),
                            iconBackground: Color(hex: "D1FAE5"),
                            metricValue: String(format: "%.0fkg CO2", co2KgPerYear),
                            title: "= \(treesEquivalent) trees",
                            subtitle: "To absorb it"
                        )
                        .offset(y: card3Appeared ? 0 : 32)
                        .opacity(card3Appeared ? 1 : 0)
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Comparação Divertida (Meio)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FEF3C7"))
                                    .frame(width: 38, height: 38)

                                Image(systemName: comparisonAnchor.icon)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color(hex: "D97706"))
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(comparisonAnchor.title)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "0F2235"))

                                Text(comparisonAnchor.highlight)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "0F2235").opacity(0.65))
                            }

                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.88))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(hex: "FDE68A"), lineWidth: 1.5)
                    )
                    .shadow(color: Color(hex: "F59E0B").opacity(0.08), radius: 14, x: 0, y: 6)
                    .padding(.horizontal, 20)
                    .offset(y: comparisonAppeared ? 0 : 30)
                    .opacity(comparisonAppeared ? 1 : 0)

                    Spacer(minLength: 12)

                    // MARK: - Botão de Ação Primária (CTA)
                    VStack(spacing: 12) {
                        Button(action: {
                            triggerHapticFeedback()
                        }) {
                            HStack(spacing: 10) {
                                Text("Fix my first vampire for free")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "3B82F6"), Color(hex: "1D4ED8")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color(hex: "1D4ED8").opacity(0.40), radius: 18, x: 0, y: 9)
                            .scaleEffect(ctaPulse ? 1.018 : 0.985)
                        }

                        // Microcópia de alívio com escudo verde
                        HStack(spacing: 6) {
                            Image(systemName: "shield.checkmark.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "10B981"))

                            Text("Zero commitment • Instant savings guide")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235").opacity(0.72))
                        }
                    }
                    .padding(.horizontal, 20)
                    .offset(y: ctaAppeared ? 0 : 35)
                    .opacity(ctaAppeared ? 1 : 0)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            startAnimationChoreography()
        }
    }

    // MARK: - Coreografia de Animações
    private func startAnimationChoreography() {
        // Disparo do Cabeçalho com Spring
        withAnimation(.spring(response: 0.60, dampingFraction: 0.72)) {
            headerAppeared = true
        }

        // Count-Up do número em 1.6s
        withAnimation(.easeOut(duration: 1.6)) {
            animatedEuros = eurosPerYear
        }

        // Card 1: delay 0.35s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                card1Appeared = true
            }
        }

        // Card 2: delay 0.55s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                card2Appeared = true
            }
        }

        // Card 3: delay 0.75s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                card3Appeared = true
            }
        }

        // Card de comparação: delay 0.95s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                comparisonAppeared = true
            }
        }

        // Botão CTA: delay 1.15s + pulso leve contínuo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                ctaAppeared = true
            }

            withAnimation(
                .easeInOut(duration: 1.4)
                .repeatForever(autoreverses: true)
            ) {
                ctaPulse = true
            }
        }
    }

    // MARK: - Feedback Háptico
    private func triggerHapticFeedback() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Subview: MetricCardView
struct MetricCardView: View {
    let iconName: String
    let iconColor: Color
    let iconBackground: Color
    let metricValue: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            // Icon Pill
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 36, height: 36)

                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(iconColor)
            }

            // Metric Value
            Text(metricValue)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "0F2235"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Titles
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.85))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.55))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: Color(hex: "0F2235").opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

// MARK: - 5. PREVIEW & MODULARIDADE (#Preview)
#Preview("AhaCalculationView - Germany 35.2W") {
    AhaCalculationView(
        totalWatts: 35.2,
        country: .germany
    )
}

#Preview("AhaCalculationView - UK 50.0W") {
    AhaCalculationView(
        totalWatts: 50.0,
        country: .uk
    )
}

#Preview("AhaCalculationView - France 20.0W") {
    AhaCalculationView(
        totalWatts: 20.0,
        country: .france
    )
}
