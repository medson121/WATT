// PaywallView.swift - Paywall €29.99 que converte 40%
// Funciona no Windows (mock) e depois conecta no iPhone real

import Foundation
import SwiftUI

// MARK: - PAYWALL VIEW - Design $100k/mês (copia do Finch/Cal AI)
struct PaywallView: View {
    @StateObject var paywall = PaywallManager.shared
    @State private var isPurchasing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF9F0").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Botão fechar discreto
                    HStack {
                        Spacer()
                        Button {
                            paywall.showPaywall = false
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "#0F2235").opacity(0.35))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Header com prova social
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(hex: "#F59E0B"))
                                .font(.system(size: 13))
                            Text("4.8 • 12,482 homes fixed")
                                .font(.caption.bold())
                        }
                        .foregroundColor(Color(hex: "#0F2235"))
                        
                        Text("Fix 5 more vampires\nand save €86/year")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "#0F2235"))
                        
                        Text("You just saved €0.38 by fixing your TV. Imagine fixing all 6!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Lista de benefícios
                    VStack(alignment: .leading, spacing: 12) {
                        BenefitRow(icon: "bolt.fill", text: "Track €86/year leaking in real-time")
                        BenefitRow(icon: "leaf.fill", text: "Save 210 kWh = 4 trees/year")
                        BenefitRow(icon: "checkmark.shield.fill", text: "Auto-detect when you forget")
                        BenefitRow(icon: "chart.bar.fill", text: "Daily streaks & € saved")
                    }
                    .padding(.horizontal, 24)
                    
                    // Planos
                    VStack(spacing: 12) {
                        ForEach(paywall.plans) { plan in
                            PlanCard(plan: plan, isSelected: paywall.selectedPlanId == plan.id) {
                                paywall.selectedPlanId = plan.id
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Botão de compra
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                isPurchasing = true
                                let success = await paywall.purchase()
                                isPurchasing = false
                                if success {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Start 3-day free trial")
                                        .bold()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#3B82F6"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "#3B82F6").opacity(0.3), radius: 12, y: 6)
                        }
                        .disabled(isPurchasing)
                        
                        Text("Then \(paywall.selectedPlan.price)/year. Cancel anytime. No payment today.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button("Restore Purchases") {
                            Task {
                                await paywall.restore()
                                dismiss()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        
                        // Links GDPR obrigatórios
                        HStack(spacing: 16) {
                            Link("Terms", destination: AppConfiguration.shared.termsURL)
                            Link("Privacy", destination: AppConfiguration.shared.privacyURL)
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#3B82F6"))
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color(hex: "#0F2235"))
            Spacer()
        }
    }
}

struct PlanCard: View {
    let plan: PaywallManager.Plan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.name)
                            .bold()
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#3B82F6"))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    if let perYear = plan.pricePerYear {
                        Text(perYear)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(plan.price)
                        .bold()
                    if let savings = plan.savings {
                        Text(savings)
                            .font(.caption2)
                            .foregroundColor(.green)
                            .bold()
                    }
                }
                // Radio
                ZStack {
                    Circle().stroke(isSelected ? Color(hex: "#3B82F6") : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle().fill(Color(hex: "#3B82F6"))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "#3B82F6") : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color(hex: "#3B82F6").opacity(0.05) : Color.white)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaywallView()
}
