// RevenueCatManager.swift - Gerenciador de Assinatura (mock por enquanto, depois RevenueCat real)
// Funciona no Windows (mock) e depois conecta no iPhone real

import Foundation
import SwiftUI

// MARK: - Gerenciador de Assinatura (mock por enquanto, depois RevenueCat real)
@MainActor
class PaywallManager: ObservableObject {
    static let shared = PaywallManager()
    
    @Published var isPro = false
    @Published var hasCompletedFirstFix = false
    @Published var showPaywall = false
    
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
        
        await MainActor.run {
            self.isPro = true
            self.showPaywall = false
        }
        
        // Salva que virou Pro no Supabase
        print("✅ Virou PRO! Plano: \(selectedPlan.name)")
        return true
    }
    
    func restore() async {
        // Mock restore
        print("🔄 Restaurando compras...")
        await MainActor.run { self.isPro = true }
    }
}

// MARK: - Typealias de conveniência para RevenueCatManager
typealias RevenueCatManager = PaywallManager
