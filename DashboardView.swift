// DashboardView.swift - Tela que evita cancelamento e cria hábito diário
// Design $100k/mês: mostra economia acumulada, streak, e progresso viciante

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct DashboardView: View {
    @StateObject var supabase = SupabaseManager.shared
    @StateObject var paywall = PaywallManager.shared
    
    var onNavigateToVampires: (() -> Void)? = nil
    @State private var navigateToVampires = false
    @State private var showPrivacySettings = false
    
    // Mock data - depois vem do Supabase daily_checks
    @State var totalEurosSaved: Double = 12.40
    @State var totalKwhSaved: Double = 32.1
    @State var totalCo2Saved: Double = 12.8
    @State var streakDays: Int = 5
    @State var vampiresFixed: Int = 3
    @State var totalVampires: Int = 6
    @State private var companionMood: VampireMood = .happy
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF9F0").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Companion Card - Volt com floresta crescendo atrás baseada no streak
                    ZStack {
                        // Floresta crescendo atrás do Volt
                        HStack(spacing: -14) {
                            ForEach(0..<max(1, min(streakDays, 7)), id: \.self) { i in
                                Text("🌳")
                                    .font(.system(size: 36))
                                    .offset(y: i % 2 == 0 ? -16 : -8)
                                    .opacity(0.88)
                                    .scaleEffect(1.0 + CGFloat(i) * 0.04)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.08), value: streakDays)
                            }
                        }
                        .offset(y: -24)
                        
                        // Volt Companion
                        VStack(spacing: 8) {
                            VampireCharacterView(
                                mood: streakDays > 3 ? .happy : .idle,
                                size: 100,
                                showBubble: true
                            )
                            
                            // Streak pill
                            HStack(spacing: 6) {
                                Text("🔥 \(streakDays) day streak!")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#0F2235"))
                                
                                Text("•")
                                    .foregroundColor(.gray)
                                
                                Text("\(streakDays) trees planted")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#10B981"))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                            )
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 6)
                    
                    // Cards de economia acumulada
                    VStack(spacing: 12) {
                        Text("You've saved so far")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#0F2235"))
                        
                        HStack(spacing: 12) {
                            SavingsCard(icon: "eurosign.circle.fill", value: String(format: "€%.2f", totalEurosSaved), label: "Money saved", color: Color(hex: "#3B82F6"))
                            SavingsCard(icon: "bolt.fill", value: String(format: "%.1f kWh", totalKwhSaved), label: "Energy", color: .orange)
                            SavingsCard(icon: "leaf.fill", value: String(format: "%.1f kg", totalCo2Saved), label: "CO2 saved", color: .green)
                        }
                    }
                    
                    // Progresso - barra viciante
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Home protection")
                                .font(.headline)
                            Spacer()
                            Text("\(vampiresFixed)/\(totalVampires) fixed")
                                .font(.caption.bold())
                                .foregroundColor(Color(hex: "#3B82F6"))
                        }
                        
                        // Barra de progresso
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#3B82F6"))
                                    .frame(width: geo.size.width * CGFloat(vampiresFixed) / CGFloat(totalVampires), height: 12)
                                    .animation(.spring(), value: vampiresFixed)
                            }
                        }
                        .frame(height: 12)
                        
                        Text("Fix \(totalVampires - vampiresFixed) more to save €\(String(format: "%.2f", (Double(totalVampires - vampiresFixed) * 14.4)))/year")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    
                    // Desafio diário (gamificação)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("🎯 Today's challenge")
                                .font(.headline)
                            Spacer()
                            Text("+€0.52")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(6)
                        }
                        Text("Fix your microwave standby (2.5W leaking)")
                            .font(.subheadline)
                        Button {
                            // Navega pra VampireList (Requisito 3)
                            withAnimation(.easeInOut(duration: 0.25)) {
                                paywall.selectedTab = .vampires
                            }
                            if let onNavigate = onNavigateToVampires {
                                onNavigate()
                            } else {
                                navigateToVampires = true
                            }
                        } label: {
                            Text("Fix now")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(hex: "#0F2235"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    
                    // Compartilhar (viral loop)
                    Button {
                        #if canImport(UIKit)
                        let text = "I've saved €12.40 and 32.1 kWh from vampire power leaks with WATT! 🌳"
                        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                        #endif
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share my forest: 5 trees saved! 🌳")
                        }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(hex: "#FFF9F0"))
                        .foregroundColor(Color(hex: "#0F2235"))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#0F2235"), lineWidth: 1.5))
                    }
                    
                    if !paywall.isPro {
                        // Upsell se não é Pro
                        Button {
                            paywall.showPaywall = true
                        } label: {
                            Text("Unlock all vampires - €29.99/year")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "#3B82F6"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $navigateToVampires) {
            VampireListView()
        }
        .sheet(isPresented: $paywall.showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showPrivacySettings) {
            PrivacySettingsView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showPrivacySettings = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#059669"))
                    }
                    .padding(6)
                    .background(Color(hex: "#10B981").opacity(0.12))
                    .clipShape(Circle())
                }
            }
        }
        .task {
            // Busca dados reais do Supabase quando conecta
            _ = await supabase.fetchCountries()
        }
    }
}

struct SavingsCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(Color(hex: "#0F2235"))
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    DashboardView()
}
