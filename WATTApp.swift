import SwiftUI

@main
struct WATTApp: App {
    @StateObject private var paywall = PaywallManager.shared
    @StateObject private var supabase = SupabaseManager.shared
    @StateObject private var biometric = BiometricAuthManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var isObscured: Bool = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(paywall)
                    .environmentObject(supabase)
                    .environmentObject(biometric)
                
                // MARK: - Bloqueio Biométrico (Face ID / Touch ID)
                if biometric.isBiometricEnabled && !biometric.isUnlocked {
                    BiometricLockOverlayView(biometric: biometric)
                        .transition(.opacity)
                        .zIndex(998)
                }
                
                // MARK: - Privacy Screen Shield (Desfoque no App Switcher do iOS)
                if isObscured {
                    PrivacyScreenShieldView()
                        .transition(.opacity)
                        .zIndex(999)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isObscured)
            .animation(.easeInOut(duration: 0.25), value: biometric.isUnlocked)
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background:
                    isObscured = true
                    biometric.lock()
                case .inactive:
                    isObscured = true
                case .active:
                    withAnimation(.easeOut(duration: 0.2)) {
                        isObscured = false
                    }
                    if biometric.isBiometricEnabled && !biometric.isUnlocked {
                        Task {
                            _ = await biometric.authenticate()
                        }
                    }
                @unknown default:
                    break
                }
            }
        }
    }
}

// MARK: - PrivacyScreenShieldView (Proteção visual contra espionagem no multitarefas)
struct PrivacyScreenShieldView: View {
    var body: some View {
        ZStack {
            Color(hex: "#0F2235")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#10B981").opacity(0.15))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "#10B981"))
                }
                
                Text("WATT")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                    Text("Proteção de Privacidade Ativa")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - BiometricLockOverlayView (Tela de desbloqueio Face ID)
struct BiometricLockOverlayView: View {
    @ObservedObject var biometric: BiometricAuthManager
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF9F0")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "#3B82F6").opacity(0.12))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: biometric.biometricType.systemIcon)
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(Color(hex: "#3B82F6"))
                }
                
                VStack(spacing: 8) {
                    Text("WATT Protegido")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "#0F2235"))
                    
                    Text("Autentique-se com \(biometric.biometricType.title) para acessar seu painel.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#0F2235").opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                if let error = biometric.authErrorMessage {
                    Text(error)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    Task {
                        _ = await biometric.authenticate()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: biometric.biometricType.systemIcon)
                        Text("Desbloquear com \(biometric.biometricType.title)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#0F2235"))
                    .cornerRadius(14)
                }
                .padding(.horizontal, 36)
                .padding(.top, 12)
                
                Spacer()
            }
        }
    }
}
