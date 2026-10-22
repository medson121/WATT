// FixAnimationView.swift - A animação que faz usuário compartilhar no TikTok
// Skills: ios-screens (haptics nativos, spring 0.8, detents), high-end-visual-design (moedas com motion blur),
// anti-ui-slop (referência Finch celebration, Duolingo confetti), build-ui (estados: leaking → fixing → celebrating → fixed)
//
// FLUXO TIKTOKÁVEL (4 segundos que viraliza):
// 1. Volt culpado "Ops, deixei ligado 🙈" + plug vazando + -€0.02 piscando
// 2. TAP FIX -> haptic medium + plug desconecta com *pop* + moedas voam pro cofrinho
// 3. Volt transforma: vermelho -> brilho ✨ -> verde guardião 🌿 + 6 moedas voando + confetti + forest +3
// 4. Card "Você salvou €8.40/ano!" + share "Meu Volt virou guardião!"

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - FixAnimationView (TikTok Viral Redesign)
public struct FixAnimationView: View {
    public var vampire: VampireItem
    public var onFixed: () -> Void
    public var onClose: (() -> Void)? = nil
    
    // Estados da animação - conta história
    public enum FixPhase {
        case idle       // Volt culpado, vazando
        case fixing     // Plug desconectando, moedas começam voar
        case celebrating // Volt brilhando, moedas voando, confetti
        case fixed      // Volt guardião, economia salva
    }
    
    @State private var phase: FixPhase = .idle
    @State private var voltMood: VampireMood = .leaking
    @State private var coins: [Coin] = []
    @State private var showConfetti = false
    @State private var forestScale: CGFloat = 0.8
    @State private var savingsCount: Double = 0
    @State private var plugOffset: CGFloat = 0
    @State private var plugOpacity: Double = 1
    @State private var buttonScale: CGFloat = 1
    
    private let ink = Color(hex: "#0F2235")
    private let electric = Color(hex: "#3B82F6")
    private let cream = Color(hex: "#FFF9F0")
    
    // Economia desse vampiro (calculada ou definida)
    public var yearlySavings: Double {
        if vampire.yearlyCost > 0 {
            return vampire.yearlyCost
        }
        return vampire.watts * 0.25 * 24 * 365 / 1000 * 0.35
    }
    
    public init(vampire: VampireItem, onFixed: @escaping () -> Void, onClose: (() -> Void)? = nil) {
        self.vampire = vampire
        self.onFixed = onFixed
        self.onClose = onClose
    }
    
    public init(
        deviceName: String,
        room: String = "Casa",
        watts: Double,
        yearlyCost: Double? = nil,
        dailySavingsFormatted: String? = nil,
        onComplete: (() -> Void)? = nil,
        onFixed: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        let cost = yearlyCost ?? (watts * 0.25 * 24 * 365 / 1000 * 0.35)
        self.vampire = VampireItem(name: deviceName, room: room, watts: watts, icon: "bolt.fill", yearlyCost: cost)
        let completion = onFixed ?? onComplete ?? {}
        self.onFixed = completion
        self.onClose = onClose
    }
    
    public var body: some View {
        ZStack {
            cream.ignoresSafeArea()
            
            // Confetti atrás - só quando celebra
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
            }
            
            VStack(spacing: 0) {
                // Header iOS nativo
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                Spacer()
                
                // Palco do Volt - centro da atenção
                ZStack {
                    // Forest atrás que cresce quando fixa
                    forestBackground
                    
                    // Volt - protagonista
                    VampireCharacterView(
                        mood: voltMood,
                        size: phase == .celebrating ? 160 : 140,
                        showBubble: phase != .fixing
                    )
                    .scaleEffect(phase == .celebrating ? 1.15 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: voltMood)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: phase)
                    
                    // Plug desconectando - animação física
                    if phase == .idle || phase == .fixing {
                        plugLeak
                            .offset(y: 60 + plugOffset)
                            .opacity(plugOpacity)
                    }
                    
                    // Moedas voando - a mágica que faz TikTok
                    ForEach(coins) { coin in
                        Text(coin.emoji)
                            .font(.system(size: 24))
                            .offset(x: coin.x, y: coin.y)
                            .scaleEffect(coin.scale)
                            .opacity(coin.opacity)
                    }
                }
                .frame(height: 280)
                
                // Contador de economia - ticker animado (high-end)
                savingsTicker
                    .padding(.top, 8)
                
                Spacer()
                
                // CTA - Fix button premium
                fixButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            startIdle()
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(vampire.name)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(ink)
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                        .foregroundColor(Color(hex: "#F59E0B"))
                    Text("\(String(format: "%.1fW", vampire.watts)) • Vazando 24h")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(ink.opacity(0.6))
                }
            }
            Spacer()
            Button {
                if let onClose = onClose {
                    onClose()
                } else {
                    onFixed()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(ink.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
            }
        }
    }
    
    private var forestBackground: some View {
        HStack(spacing: -8) {
            ForEach(0..<6, id: \.self) { i in
                Text("🌳")
                    .font(.system(size: i < 3 ? 28 : 20))
                    .scaleEffect(forestScale)
                    .opacity(i < 3 ? 1 : 0.6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(i) * 0.05), value: forestScale)
            }
        }
        .offset(y: 80)
        .opacity(phase == .fixed || phase == .celebrating ? 1 : 0.3)
    }
    
    private var plugLeak: some View {
        VStack(spacing: 4) {
            // Fio vazando energia
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#EF4444").opacity(0.8), Color(hex: "#EF4444").opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 24)
                .blur(radius: 1)
            
            HStack(spacing: 2) {
                Text("-€0.02")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#EF4444"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "#FEE2E2"))
                    .clipShape(Capsule())
                    .opacity(phase == .idle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: phase)
                
                Image(systemName: "powerplug.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#0F2235"))
            }
        }
    }
    
    private var savingsTicker: some View {
        VStack(spacing: 8) {
            if phase == .fixed || phase == .celebrating {
                Text("Você salvou")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(ink.opacity(0.6))
                
                HStack(spacing: 4) {
                    Text("€\(String(format: "%.2f", savingsCount))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(ink)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: savingsCount)
                    
                    Text("/ano")
                        .font(.system(.headline, design: .rounded).weight(.medium))
                        .foregroundColor(ink.opacity(0.5))
                        .padding(.top, 8)
                }
                
                let kwh = vampire.watts * 24 * 365 / 1000
                let co2 = vampire.watts * 0.4
                Text("= \(String(format: "%.0f kWh", kwh)) • \(String(format: "%.1f kg CO₂", co2)) • 1 árvore 🌳")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(ink.opacity(0.5))
            } else {
                Text("Vazando €\(String(format: "%.2f", yearlySavings))/ano")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundColor(Color(hex: "#EF4444"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#FEE2E2"))
                    .clipShape(Capsule())
            }
        }
        .frame(height: 80)
    }
    
    private var fixButton: some View {
        VStack(spacing: 12) {
            if phase == .fixed {
                // Pós-fix - share viral
                VStack(spacing: 12) {
                    Button {
                        // Share TikTok: "Meu Volt virou guardião!"
                        #if canImport(UIKit)
                        let text = "Meu \(vampire.name) virou guardião! Economizei €\(String(format: "%.2f", yearlySavings))/ano com WATT 🌳✨"
                        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? windowScene.windows.first?.rootViewController {
                            var topController = rootVC
                            while let presented = topController.presentedViewController {
                                topController = presented
                            }
                            topController.present(av, animated: true)
                        }
                        #endif
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Compartilhar: Volt virou guardião!")
                        }
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .foregroundColor(ink)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(ink.opacity(0.12), lineWidth: 1))
                    }
                    
                    Button {
                        onFixed()
                    } label: {
                        Text("Continuar")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(ink)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            } else {
                Button {
                    triggerFix()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: phase == .fixing ? "powerplug.fill" : "bolt.fill")
                            .font(.headline)
                        Text(phase == .idle ? "Fixar agora" : "Desconectando...")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: phase == .idle ? [ink, Color(hex: "#1E3A5F")] : [Color(hex: "#6B7280"), Color(hex: "#9CA3AF")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: ink.opacity(0.2), radius: 12, x: 0, y: 6)
                    .scaleEffect(buttonScale)
                }
                .disabled(phase != .idle)
            }
            
            if phase == .idle {
                Text("1 toque • Leva 5 segundos • Economia imediata")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(ink.opacity(0.4))
            }
        }
    }
    
    // MARK: - Animações que criam vínculo (TikTok moment)
    private func startIdle() {
        voltMood = .leaking
    }
    
    private func triggerFix() {
        // 1. Haptic + button press
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { buttonScale = 0.96 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { buttonScale = 1 }
        }
        
        // 2. Fase fixing - plug desconecta
        phase = .fixing
        voltMood = .guilty
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            plugOffset = 24
            plugOpacity = 0
        }
        
        // 3. Moedas voam - 400ms depois (o dinheiro saindo do vazamento)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            spawnCoins()
            voltMood = .celebrating
            phase = .celebrating
            showConfetti = true
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            #endif
            
            // Ticker conta até economia
            withAnimation(.easeOut(duration: 1.2)) {
                savingsCount = yearlySavings
                forestScale = 1.15
            }
            
            // Forest cresce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    forestScale = 1.0
                }
            }
        }
        
        // 4. Fixado - guardião
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                phase = .fixed
                voltMood = .fixed
                showConfetti = false
            }
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }
    }
    
    private func spawnCoins() {
        // 6 moedas com trajetórias diferentes - motion blur premium
        for i in 0..<6 {
            let coin = Coin(
                id: i,
                emoji: ["💸", "✨", "💰"][i % 3],
                x: CGFloat.random(in: -60...60),
                y: 100,
                scale: 0.5,
                opacity: 1
            )
            coins.append(coin)
            
            // Anima cada moeda voando pra cima com spring
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double(i) * 0.08)) {
                if let index = coins.firstIndex(where: { $0.id == i }) {
                    coins[index].y = CGFloat.random(in: -120 ... -80)
                    coins[index].x += CGFloat.random(in: -40...40)
                    coins[index].scale = 1.1
                    coins[index].opacity = 0
                }
            }
        }
    }
}

// Preview checks at 390px (iPhone 12/13/14/15/16) and 430px (iPhone 14/15/16 Pro Max)
#Preview("FixAnimation - 390px") {
    FixAnimationView(vampire: VampireItem()) {
        print("Fixed!")
    }
    .frame(width: 390, height: 844)
}

#Preview("FixAnimation - 430px") {
    FixAnimationView(vampire: VampireItem()) {
        print("Fixed!")
    }
    .frame(width: 430, height: 932)
}
