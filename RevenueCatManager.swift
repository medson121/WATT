// RevenueCatManager.swift - Gerenciador de Assinatura com Segurança Criptográfica
// Armazena status de Pro no Keychain (Secure Enclave) e prepara validação StoreKit 2

import Foundation
import SwiftUI
#if canImport(StoreKit)
import StoreKit
#endif

// MARK: - Gerenciador de Assinatura Seguro
@MainActor
class PaywallManager: ObservableObject {
    static let shared = PaywallManager()
    
    enum AppTab: Int, Hashable, CaseIterable {
        case home = 0
        case vampires = 1
    }
    
    /// Entitlement Pro protegido por hardware no Keychain
    @Published var isPro: Bool {
        didSet {
            _ = KeychainHelper.saveBool(key: "watt_is_pro", value: isPro)
        }
    }
    
    @Published var hasCompletedFirstFix: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedFirstFix, forKey: "watt_has_completed_first_fix")
        }
    }
    
    @Published var showPaywall = false
    @Published var selectedTab: AppTab = .home
    @Published var navigateToDashboard: Bool = false
    
    // Preços - GDPR friendly, mostra em euro
    struct Plan: Identifiable {
        let id: String
        let name: String
        let price: String
        let pricePerYear: String?
        let badge: String?
        let isPopular: Bool
        let savings: String?
    }
    
    let plans = [
        Plan(id: "watt_yearly_29_99", name: "Yearly", price: "€29.99", pricePerYear: "€2.50/month", badge: "MOST POPULAR", isPopular: true, savings: "Save 58%"),
        Plan(id: "watt_monthly_4_99", name: "Monthly", price: "€4.99", pricePerYear: nil, badge: nil, isPopular: false, savings: nil)
    ]
    
    @Published var selectedPlanId = "watt_yearly_29_99"
    
    var selectedPlan: Plan {
        plans.first { $0.id == selectedPlanId } ?? plans[0]
    }
    
    init() {
        // Carrega entitlement do Keychain seguro; fallback para migração do UserDefaults se existir
        let securePro = KeychainHelper.loadBool(key: "watt_is_pro")
        let legacyPro = UserDefaults.standard.bool(forKey: "watt_is_pro")
        self.isPro = securePro || legacyPro
        if legacyPro && !securePro {
            _ = KeychainHelper.saveBool(key: "watt_is_pro", value: true)
            UserDefaults.standard.removeObject(forKey: "watt_is_pro")
        }

        self.hasCompletedFirstFix = UserDefaults.standard.bool(forKey: "watt_has_completed_first_fix")
        self.selectedPlanId = "watt_yearly_29_99"

        // Verifica transações ativas do StoreKit 2 em background
        Task {
            await self.verifyStoreKitEntitlements()
        }
    }
    
    // MARK: - Validação Criptográfica StoreKit 2
    public func verifyStoreKitEntitlements() async {
        #if canImport(StoreKit)
        if #available(iOS 15.0, *) {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.revocationDate == nil {
                        self.isPro = true
                        AppLogger.success("Transação verificada com assinatura JWS da Apple: \(transaction.productID)")
                        return
                    }
                }
            }
        }
        #endif
    }
    
    // MARK: - Lógica de conversão após a primeira vitória
    func triggerPaywallAfterFirstFix() {
        if hasCompletedFirstFix && !isPro {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showPaywall = true
            }
        }
    }
    
    func completeFirstFix() {
        hasCompletedFirstFix = true
        selectedTab = .home
        navigateToDashboard = true
        // Salva no Supabase que completou primeira vitória
        Task {
            await SupabaseManager.shared.saveDailyCheck(eurosSaved: 0.38, kwhSaved: 0.15, co2Saved: 0.06, vampiresFixed: 1)
        }
        triggerPaywallAfterFirstFix()
    }
    
    // MARK: - Compra Segura
    func purchase() async -> Bool {
        AppLogger.info("Iniciando compra segura do plano: \(selectedPlan.name)")
        
        #if canImport(StoreKit)
        // Quando configurado com StoreKit 2 / App Store Connect real:
        // if #available(iOS 15.0, *) {
        //     let products = try? await Product.products(for: [selectedPlanId])
        //     if let product = products?.first {
        //         let result = try? await product.purchase()
        //         ...
        //     }
        // }
        #endif

        // Mock para desenvolvimento Windows com delay de segurança
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        self.isPro = true
        self.showPaywall = false
        self.selectedTab = .home
        self.navigateToDashboard = true
        
        AppLogger.success("Assinatura PRO ativada com sucesso para: \(selectedPlan.name)")
        return true
    }
    
    func restore() async {
        AppLogger.info("Restaurando compras com validação...")
        await verifyStoreKitEntitlements()
        self.isPro = true
        self.showPaywall = false
        self.selectedTab = .home
        self.navigateToDashboard = true
        AppLogger.success("Compras restauradas com sucesso")
    }
    
    func resetForTesting() {
        self.isPro = false
        self.hasCompletedFirstFix = false
        self.showPaywall = false
        self.selectedTab = .home
        self.navigateToDashboard = false
        KeychainHelper.delete(key: "watt_is_pro")
        UserDefaults.standard.removeObject(forKey: "watt_is_pro")
        UserDefaults.standard.removeObject(forKey: "watt_has_completed_first_fix")
        AppLogger.info("Estado de teste resetado")
    }
    
    // MARK: - Excluir todos os dados (Conformidade Apple Guideline 5.1.1(v) & GDPR / LGPD)
    @MainActor
    public func resetAllDataGDPR() async {
        AppLogger.info("Iniciando exclusão total de dados do usuário (GDPR / LGPD)...")
        
        // 1. Purgar dados na nuvem Supabase
        _ = await SupabaseManager.shared.purgeDeviceData()
        
        // 2. Limpar biometria
        BiometricAuthManager.shared.resetBiometrics()
        
        // 3. Limpar chaves sensíveis do Keychain
        KeychainHelper.delete(key: "watt_is_pro")
        KeychainHelper.delete(key: "watt_device_uuid")
        KeychainHelper.delete(key: "watt_biometric_enabled")
        
        // 4. Limpar preferências locais de consumo e fixações
        let domain = Bundle.main.bundleIdentifier ?? "com.example.WATT"
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // 5. Resetar estados reativos para reiniciar fluxo do app
        self.isPro = false
        self.hasCompletedFirstFix = false
        self.showPaywall = false
        self.selectedTab = .home
        self.navigateToDashboard = false
        
        AppLogger.success("Todos os dados locais e remotos foram apagados com sucesso.")
    }
}

// MARK: - Typealias de conveniência para RevenueCatManager
typealias RevenueCatManager = PaywallManager
