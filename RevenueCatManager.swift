// RevenueCatManager.swift - Gerenciador de Assinatura (mock por enquanto, depois RevenueCat real)
// Funciona no Windows (mock) e depois conecta no iPhone real

import Foundation
import SwiftUI

// MARK: - Gerenciador de Assinatura (mock por enquanto, depois RevenueCat real)
@MainActor
class PaywallManager: ObservableObject {
    static let shared = PaywallManager()
    
    enum AppTab: Int, Hashable, CaseIterable {
        case home = 0
        case vampires = 1
    }
    
    @Published var isPro: Bool {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "watt_is_pro")
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
        self.isPro = UserDefaults.standard.bool(forKey: "watt_is_pro")
        self.hasCompletedFirstFix = UserDefaults.standard.bool(forKey: "watt_has_completed_first_fix")
        self.selectedPlanId = "watt_yearly_29_99"
    }
    
    // MARK: - Lógica $100k: só mostra paywall DEPOIS da primeira vitória
    func triggerPaywallAfterFirstFix() {
        if hasCompletedFirstFix && !isPro {
            // Delay de 1.5s pra deixar a dopamina da moeda voando agir
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
    
    // MARK: - Compra (mock por enquanto - depois RevenueCat)
    func purchase() async -> Bool {
        // TODO: Quando tiver Apple Developer, conectar RevenueCat aqui:
        // let result = try await RevenueCat.shared.purchase(selectedPlanId)
        
        // MOCK pra testar no Windows agora:
        print("🛒 Comprando \(selectedPlan.name) por \(selectedPlan.price)...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s loading
        
        self.isPro = true
        self.showPaywall = false
        self.selectedTab = .home
        self.navigateToDashboard = true
        
        // Salva que virou Pro no Supabase
        print("✅ Virou PRO! Plano: \(selectedPlan.name) - Navegando para DashboardView")
        return true
    }
    
    func restore() async {
        // Mock restore
        print("🔄 Restaurando compras...")
        self.isPro = true
        self.showPaywall = false
        self.selectedTab = .home
        self.navigateToDashboard = true
    }
    
    func resetForTesting() {
        self.isPro = false
        self.hasCompletedFirstFix = false
        self.showPaywall = false
        self.selectedTab = .home
        self.navigateToDashboard = false
        UserDefaults.standard.removeObject(forKey: "watt_is_pro")
        UserDefaults.standard.removeObject(forKey: "watt_has_completed_first_fix")
    }
}

// MARK: - Typealias de conveniência para RevenueCatManager
typealias RevenueCatManager = PaywallManager
