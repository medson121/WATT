// VampireCharacterView.swift - Companheiro que cria relacionamento (tipo Finch + Duolingo)
// Skills: ios-screens (haptics, gestures nativos), high-end-visual-design (motion spring 0.8),
// build-ui (estados + micro-interações), anti-ui-slop (referência Tamagotchi, Finch, Pou)
//
// CONCEITO: Volt - não é vilão, é um fantasma de energia atrapalhado que quer te ajudar
// mas às vezes esquece a tomada ligada. Você cuida dele, ele cuida da sua conta.
// Quanto mais você economiza, mais feliz e evoluído ele fica.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Modelo de humor (cria relacionamento)
public enum VampireMood: String, CaseIterable {
    case leaking      // Vazando - culpado, olha pro lado
    case guilty       // Culpa - "foi mal, esqueci de novo 😅"
    case sleepy       // Standby - roncando Zzz
    case happy        // Feliz - fixou!
    case celebrating  // Celebração - pulando com moedas
    case fixed        // Transformado - virou guardião da casa
    case idle         // Flutuando neutro
    
    public var message: String {
        switch self {
        case .leaking: return "Ops... deixei ligado de novo 🙈"
        case .guilty: return "Foi mal, eu tento melhorar!"
        case .sleepy: return "Zzz... economizando..."
        case .happy: return "Você me salvou! Obrigado! 💙"
        case .celebrating: return "EU TÔ BRILHANDO! ✨"
        case .fixed: return "Agora sou guardião da casa! 🌳"
        case .idle: return "Oi! Cuida de mim?"
        }
    }
    
    public var eyeLook: CGPoint {
        switch self {
        case .leaking: return CGPoint(x: -6, y: 2) // olha pro lado culpado
        case .guilty: return CGPoint(x: 0, y: 6) // olha pra baixo
        case .sleepy: return CGPoint(x: 0, y: 0)
        case .happy, .celebrating, .fixed: return CGPoint(x: 0, y: -2) // olha pra você feliz
        case .idle: return CGPoint(x: 0, y: 0)
        }
    }
}

public struct VampireCharacterView: View {
    public var mood: VampireMood = .idle
    public var size: CGFloat = 120
    public var showBubble: Bool = true
    public var onTap: (() -> Void)? = nil
    
    // Animação interna - respira, pisca, segue dedo
    @State private var floatOffset: CGFloat = 0
    @State private var isBlinking = false
    @State private var eyeOffset: CGPoint = .zero
    @State private var mouthScale: CGFloat = 1
    @State private var isPressed = false
    @State private var bubbleScale: CGFloat = 0
    
    // Interação
    @State private var dragLocation: CGPoint = .zero
    @GestureState private var isDragging = false
    
    private let ink = Color(hex: "#0F2235")
    
    public init(mood: VampireMood = .idle, size: CGFloat = 120, showBubble: Bool = true, onTap: (() -> Void)? = nil) {
        self.mood = mood
        self.size = size
        self.showBubble = showBubble
        self.onTap = onTap
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Speech bubble - aparece com spring
            if showBubble {
                bubble
                    .scaleEffect(bubbleScale)
                    .opacity(bubbleScale)
            }
            
            // Corpo do Volt
            ZStack {
                // Sombra flutuante (grounding)
                Ellipse()
                    .fill(Color.black.opacity(0.08))
                    .frame(width: size * 0.5, height: size * 0.12)
                    .offset(y: size * 0.55)
                    .scaleEffect(1 - floatOffset / 20)
                    .blur(radius: 4)
                
                // Fantasminha - custom drawing premium
                vampireBody
                    .frame(width: size, height: size)
                    .offset(y: floatOffset)
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isPressed)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: mood)
            }
            .frame(width: size * 1.2, height: size * 1.2)
            .contentShape(Circle())
            // Gestures que criam vínculo
            .gesture(
                SimultaneousGesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            dragLocation = value.location
                            // Olhos seguem dedo - cria conexão
                            let center = CGPoint(x: size/2, y: size/2)
                            let deltaX = (value.location.x - center.x) / (size/2) * 5
                            let deltaY = (value.location.y - center.y) / (size/2) * 4
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                eyeOffset = CGPoint(x: deltaX + mood.eyeLook.x, y: deltaY + mood.eyeLook.y)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                eyeOffset = mood.eyeLook
                            }
                        },
                    TapGesture()
                        .onEnded {
                            boop()
                        }
                )
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        pet()
                    }
            )
        }
        .onAppear {
            startIdleAnimations()
            eyeOffset = mood.eyeLook
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                bubbleScale = 1
            }
        }
        .onChange(of: mood) { _, newMood in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                eyeOffset = newMood.eyeLook
                bubbleScale = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    bubbleScale = 1
                }
            }
            // Haptic por humor
            #if canImport(UIKit)
            switch newMood {
            case .celebrating, .fixed:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .guilty, .leaking:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            case .happy:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            default: break
            }
            #endif
        }
    }
    
    // MARK: - Visual do Volt (high-end, não emoji)
    private var vampireBody: some View {
        ZStack {
            // Corpo - gradiente premium, não flat
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: mood == .fixed ? [Color(hex: "#8BA888"), Color(hex: "#6B8F71")] :
                                mood == .leaking ? [Color(hex: "#FEE2E2"), Color(hex: "#FECACA")] :
                                [Color.white, Color(hex: "#F8FAFC")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Ellipse()
                        .stroke(
                            mood == .fixed ? Color(hex: "#8BA888").opacity(0.3) :
                            mood == .leaking ? Color(hex: "#EF4444").opacity(0.2) :
                            Color.black.opacity(0.06),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            
            // Plug - rabinho fofo (detalhe que cria afeto)
            if mood != .fixed {
                Circle()
                    .fill(Color(hex: "#0F2235"))
                    .frame(width: size * 0.18, height: size * 0.18)
                    .overlay(
                        Image(systemName: "powerplug.fill")
                            .font(.system(size: size * 0.08, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(y: size * 0.42)
                    .rotationEffect(.degrees(mood == .leaking ? -8 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: mood)
            } else {
                // Quando fixo, plug vira folhinha
                Text("🌿")
                    .font(.system(size: size * 0.18))
                    .offset(y: size * 0.42)
            }
            
            // Olhos - seguem dedo + piscam
            HStack(spacing: size * 0.18) {
                ForEach(0..<2) { _ in
                    ZStack {
                        // Branco do olho
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.22, height: size * 0.26)
                            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                        
                        // Iris - segue
                        Circle()
                            .fill(ink)
                            .frame(width: size * 0.13, height: size * 0.13)
                            .offset(x: eyeOffset.x, y: eyeOffset.y)
                            .scaleEffect(isBlinking ? 0.1 : 1, anchor: .center)
                            .animation(.easeInOut(duration: 0.12), value: isBlinking)
                        
                        // Brilho - high-end detail
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.05, height: size * 0.05)
                            .offset(x: eyeOffset.x + size * 0.03, y: eyeOffset.y - size * 0.03)
                    }
                }
            }
            .offset(y: -size * 0.08)
            
            // Bochecha rosada quando feliz - cria afeto
            if mood == .happy || mood == .celebrating || mood == .fixed {
                HStack(spacing: size * 0.28) {
                    ForEach(0..<2) { _ in
                        Ellipse()
                            .fill(Color(hex: "#F9A8D4").opacity(0.5))
                            .frame(width: size * 0.12, height: size * 0.08)
                            .blur(radius: 2)
                    }
                }
                .offset(y: size * 0.08)
            }
            
            // Boca - muda por humor (desenha, não SF Symbol)
            Group {
                switch mood {
                case .leaking, .guilty:
                    // Boca culpada - ondulada
                    Capsule()
                        .fill(ink.opacity(0.7))
                        .frame(width: size * 0.12, height: size * 0.04)
                        .offset(y: size * 0.18)
                        .rotationEffect(.degrees(-8))
                case .sleepy:
                    // Boca roncando - o
                    Circle()
                        .fill(ink.opacity(0.6))
                        .frame(width: size * 0.10, height: size * 0.10)
                        .offset(y: size * 0.18)
                case .happy:
                    // Sorriso fofo
                    Image(systemName: "face.smiling")
                        .font(.system(size: size * 0.14, weight: .medium))
                        .foregroundColor(ink.opacity(0.7))
                        .offset(y: size * 0.18)
                        .scaleEffect(mouthScale)
                case .celebrating:
                    // Boca aberta feliz
                    Text("😆")
                        .font(.system(size: size * 0.18))
                        .offset(y: size * 0.18)
                case .fixed:
                    // Sorriso zen
                    Capsule()
                        .fill(ink.opacity(0.6))
                        .frame(width: size * 0.14, height: size * 0.05)
                        .offset(y: size * 0.18)
                case .idle:
                    Capsule()
                        .fill(ink.opacity(0.5))
                        .frame(width: size * 0.08, height: size * 0.04)
                        .offset(y: size * 0.18)
                }
            }
            
            // Presinhas quando leaking - sutil, não assustador
            if mood == .leaking {
                HStack(spacing: size * 0.06) {
                    ForEach(0..<2) { _ in
                        Triangle()
                            .fill(Color.white)
                            .frame(width: size * 0.04, height: size * 0.05)
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                }
                .offset(y: size * 0.22)
            }
            
            // Zzz quando sleepy
            if mood == .sleepy {
                Text("Zzz")
                    .font(.system(size: size * 0.14, weight: .bold, design: .rounded))
                    .foregroundColor(ink.opacity(0.25))
                    .offset(x: size * 0.32, y: -size * 0.22)
                    .opacity(isBlinking ? 0 : 1)
            }
            
            // Partículas quando celebrating - moedas voando
            if mood == .celebrating {
                ForEach(0..<6, id: \.self) { i in
                    Text(["✨", "💸", "🌟"][i % 3])
                        .font(.system(size: size * 0.12))
                        .offset(
                            x: CGFloat.random(in: -size*0.6...size*0.6),
                            y: CGFloat.random(in: -size*0.6...size*0.2)
                        )
                        .opacity(0.8)
                        .animation(
                            .easeOut(duration: Double.random(in: 0.8...1.2))
                            .delay(Double(i) * 0.08)
                            .repeatForever(autoreverses: false),
                            value: floatOffset
                        )
                }
            }
        }
    }
    
    private var bubble: some View {
        VStack(spacing: 0) {
            Text(mood.message)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 0.5))
                )
            
            // Setinha
            Triangle()
                .fill(Color.white)
                .frame(width: 12, height: 8)
                .offset(y: -1)
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 2)
        }
    }
    
    // MARK: - Interações que criam vínculo
    private func boop() {
        // Tap no nariz - ele ri
        isPressed = true
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            mouthScale = 1.3
            eyeOffset = CGPoint(x: 0, y: -3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isPressed = false
                mouthScale = 1
                eyeOffset = mood.eyeLook
            }
        }
        onTap?()
    }
    
    private func pet() {
        // Long press - faz carinho
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            floatOffset = -12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                floatOffset = 0
            }
        }
    }
    
    private func startIdleAnimations() {
        // Float infinito - respira
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            floatOffset = -6
        }
        
        // Pisca a cada 3-5s - parece vivo
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...5), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.12)) { isBlinking = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.12)) { isBlinking = false }
            }
        }
    }
}

// Helper triangle
public struct Triangle: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview com todos os humores - teste de relacionamento
public struct VampireCompanionDemo: View {
    @State var mood: VampireMood = .idle
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(hex: "#FFF9F0").ignoresSafeArea()
            
            VStack(spacing: 32) {
                VampireCharacterView(mood: mood, size: 140) {
                    // Boop callback
                }
                
                // Seletor de humor - testa vínculo
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach([VampireMood.leaking, .guilty, .sleepy, .happy, .celebrating, .fixed, .idle], id: \.message) { m in
                            Button {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    mood = m
                                }
                            } label: {
                                Text(m.message)
                                    .font(.caption2.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(mood.message == m.message ? Color(hex: "#0F2235") : Color.white)
                                    .foregroundColor(mood.message == m.message ? .white : Color(hex: "#0F2235"))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.black.opacity(0.06), lineWidth: 0.5))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Explicação do vínculo
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Como cria relacionamento:")
                        .font(.headline)
                    Text("• Ele te culpa fofo quando vaza: 'Ops, deixei ligado 🙈'\n• Você faz carinho (long press) e ele flutua feliz\n• Tap no nariz = boop + risada + haptic\n• Olhos seguem seu dedo (eye tracking)\n• Quando fixa, ele vira guardião 🌿 e cresce sua floresta")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    VampireCompanionDemo()
}
