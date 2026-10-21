// BiometricAuthManager.swift - Gerenciador de Autenticação Biométrica (Face ID / Touch ID)
// Proteção de privacidade e dados confidenciais do usuário com hardware da Apple

import SwiftUI
import Combine
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

public final class BiometricAuthManager: ObservableObject {
    public static let shared = BiometricAuthManager()
    
    public enum BiometricType {
        case none
        case touchID
        case faceID
        
        public var title: String {
            switch self {
            case .none: return "Senha do Dispositivo"
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            }
        }
        
        public var systemIcon: String {
            switch self {
            case .none: return "lock.fill"
            case .touchID: return "touchid"
            case .faceID: return "faceid"
            }
        }
    }
    
    @Published public var isUnlocked: Bool = false
    @Published public var isBiometricEnabled: Bool = false {
        didSet {
            let data = isBiometricEnabled ? "true".data(using: .utf8) : nil
            if let data = data {
                KeychainHelper.shared.save(key: "watt_biometric_enabled", data: data)
            } else {
                KeychainHelper.shared.delete(key: "watt_biometric_enabled")
            }
        }
    }
    @Published public var biometricType: BiometricType = .none
    @Published public var authErrorMessage: String?
    
    private init() {
        // Carrega preferência do Keychain
        if let data = KeychainHelper.shared.read(key: "watt_biometric_enabled"),
           let string = String(data: data, encoding: .utf8) {
            self.isBiometricEnabled = (string == "true")
        }
        
        // Se a biometria não estiver ativada pelo usuário, o app inicia desbloqueado
        self.isUnlocked = !self.isBiometricEnabled
        
        detectBiometricType()
    }
    
    public func detectBiometricType() {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                self.biometricType = .faceID
            case .touchID:
                self.biometricType = .touchID
            default:
                self.biometricType = .none
            }
        } else {
            self.biometricType = .none
        }
        #else
        self.biometricType = .none
        #endif
    }
    
    @MainActor
    public func authenticate() async -> Bool {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"
        context.localizedFallbackTitle = "Usar Código"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            AppLogger.debug("Biometria não disponível: \(error?.localizedDescription ?? "desconhecido")")
            self.isUnlocked = true
            return true
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Desbloqueie o WATT para acessar seu painel de economia e proteção de dados."
            )
            if success {
                self.isUnlocked = true
                self.authErrorMessage = nil
                AppLogger.success("Autenticação biométrica concluída com sucesso")
                return true
            } else {
                self.authErrorMessage = "Autenticação não concluída"
                return false
            }
        } catch {
            self.authErrorMessage = error.localizedDescription
            AppLogger.error("Falha na autenticação biométrica: \(error.localizedDescription)")
            return false
        }
        #else
        self.isUnlocked = true
        return true
        #endif
    }
    
    public func lock() {
        if isBiometricEnabled {
            self.isUnlocked = false
        }
    }
    
    public func resetBiometrics() {
        self.isBiometricEnabled = false
        self.isUnlocked = true
        KeychainHelper.shared.delete(key: "watt_biometric_enabled")
    }
}
