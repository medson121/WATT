// PaywallView.swift - $100k/month redesign
// Skills: ios-screens (native StoreKit sheet, detents, Dynamic Type, haptics), 
// frontend-design (distinctive, not generic paywall), high-end-visual-design (calibrated motion),
// anti-ui-slop (real paywalls from Finch/Cal AI, not AI slop), build-ui (states, check 390/430px)
// 
// REFERENCE: Finch, Cal AI, Oura, Duolingo - 3-day trial + annual most popular + social proof

import SwiftUI
#if canImport(StoreKit)
import StoreKit
#endif
#if canImport(UIKit)
import UIKit
#endif

public struct PaywallView: View {
    @StateObject var paywall = PaywallManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State var selectedPlan: Plan = .annual
    @State var appeared = false
    @State var annualBounce = false
    
    public enum Plan { case annual, monthly }
    
    private let ink = Color(hex: "#0F2235")
    private let electric = Color(hex: "#3B82F6")
    private let cream = Color(hex: "#FFF9F0")
    private let border = Color(hex: "#0F2235").opacity(0.06)
    
    public init() {}
    
    public var body: some View {
        ZStack {
            cream.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Header - iOS native close + social proof
                    header
                        .padding(.top, 8)
                    
                    // 2. Hero - The transformation
                    hero
                        .padding(.top, 16)
                    
                    // 3. Features - What you get (checkmarks, not paragraphs)
                    features
                        .padding(.top, 24)
                    
                    // 4. Pricing - Annual MOST POPULAR (Finch pattern)
                    pricing
                        .padding(.top, 24)
                    
                    // 5. CTA - Spring + haptic
                    cta
                        .padding(.top, 20)
                    
                    // 6. Trust + Legal - GDPR, restore, terms (native bottom)
                    trustFooter
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appeared = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.8).repeatForever(autoreverses: true)) {
                annualBounce = true
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                paywall.showPaywall = false
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(ink.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(border, lineWidth: 1))
            }
            
            Spacer()
            
            // Social proof pill - anti-slop real pattern
            HStack(spacing: 6) {
                HStack(spacing: -6) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill([Color(hex: "#F59E0B"), Color(hex: "#10B981"), Color(hex: "#8B5CF6")][i])
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                Text("12k+ saving")
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundColor(ink.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(border, lineWidth: 0.5))
        }
    }
    
    private var hero: some View {
        VStack(spacing: 14) {
            // Icon orb with gradient - high-end, not emoji
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [electric, Color(hex: "#60A5FA"), Color(hex: "#93C5FD")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: electric.opacity(0.3), radius: 16, x: 0, y: 8)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appeared)
            
            VStack(spacing: 8) {
                Text("Unlock your full forest")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text("Fix all 12 energy vampires and save\n€86.40/year on average")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(ink.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
    }
    
    private var features: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach([
                ("infinity", "Unlimited vampire fixes", "All devices, forever"),
                ("chart.line.uptrend.xyaxis", "Real-time cost tracking", "See € saved daily"),
                ("bell.badge.fill", "Smart alerts", "Never waste again"),
                ("leaf.fill", "CO₂ impact", "Track your forest")
            ], id: \.0) { icon, title, subtitle in
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(electric.opacity(0.12)).frame(width: 36, height: 36)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(electric)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundColor(ink)
                        Text(subtitle)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(ink.opacity(0.55))
                    }
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#10B981"))
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(border, lineWidth: 0.5))
            }
        }
    }
    
    private var pricing: some View {
        VStack(spacing: 12) {
            // Annual - MOST POPULAR (Finch pattern, not generic)
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedPlan = .annual
                }
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            } label: {
                HStack(spacing: 14) {
                    // Radio - native iOS
                    ZStack {
                        Circle().stroke(selectedPlan == .annual ? electric : Color.black.opacity(0.15), lineWidth: 2).frame(width: 22, height: 22)
                        if selectedPlan == .annual {
                            Circle().fill(electric).frame(width: 12, height: 12)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text("Annual")
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                                .foregroundColor(ink)
                            // MOST POPULAR badge - subtle bounce, not garish
                            Text("MOST POPULAR")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(electric)
                                .clipShape(Capsule())
                                .offset(y: annualBounce ? -1 : 1)
                        }
                        Text("€2.49/month, billed yearly")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(ink.opacity(0.55))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("€29.99")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundColor(ink)
                        Text("€0.08/day")
                            .font(.system(.caption2, design: .rounded).weight(.medium))
                            .foregroundColor(Color(hex: "#10B981"))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(selectedPlan == .annual ? electric.opacity(0.06) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedPlan == .annual ? electric : border, lineWidth: selectedPlan == .annual ? 1.5 : 0.5)
                        )
                )
            }
            .buttonStyle(.plain)
            
            // Monthly - secondary
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedPlan = .monthly
                }
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(selectedPlan == .monthly ? electric : Color.black.opacity(0.15), lineWidth: 2).frame(width: 22, height: 22)
                        if selectedPlan == .monthly {
                            Circle().fill(electric).frame(width: 12, height: 12)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monthly")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundColor(ink)
                        Text("€5.99/month")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(ink.opacity(0.55))
                    }
                    
                    Spacer()
                    
                    Text("€5.99")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(ink)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(selectedPlan == .monthly ? electric.opacity(0.06) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedPlan == .monthly ? electric : border, lineWidth: selectedPlan == .monthly ? 1.5 : 0.5)
                        )
                )
            }
            .buttonStyle(.plain)
            
            // Savings callout - native iOS banner
            HStack(spacing: 6) {
                Image(systemName: "tag.fill").font(.caption2).foregroundColor(Color(hex: "#10B981"))
                Text("Save 58% with Annual • 3-day free trial, cancel anytime")
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundColor(ink.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "#D1FAE5").opacity(0.6))
            .clipShape(Capsule())
        }
    }
    
    private var cta: some View {
        VStack(spacing: 10) {
            Button {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
                Task {
                    await paywall.purchase()
                    dismiss()
                }
            } label: {
                HStack(spacing: 8) {
                    if paywall.isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(selectedPlan == .annual ? "Start 3-day free trial" : "Continue")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(colors: [ink, Color(hex: "#1E3A5F")], startPoint: .top, endPoint: .bottom)
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: ink.opacity(0.2), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(paywall.isPurchasing)
            .scaleEffect(appeared ? 1 : 0.96)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appeared)
            
            Text(selectedPlan == .annual ? "Then €29.99/year. Cancel anytime in Settings." : "€5.99/month. Cancel anytime.")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(ink.opacity(0.45))
                .multilineTextAlignment(.center)
        }
    }
    
    private var trustFooter: some View {
        VStack(spacing: 12) {
            // Trust badges - GDPR etc, anti-slop real pattern
            HStack(spacing: 16) {
                Label("GDPR", systemImage: "lock.shield.fill").font(.system(.caption2, design: .rounded).weight(.medium)).foregroundColor(ink.opacity(0.4))
                Label("No ads", systemImage: "eye.slash.fill").font(.system(.caption2, design: .rounded).weight(.medium)).foregroundColor(ink.opacity(0.4))
                Label("Offline", systemImage: "wifi.slash").font(.system(.caption2, design: .rounded).weight(.medium)).foregroundColor(ink.opacity(0.4))
            }
            
            // Native legal row - iOS convention bottom
            HStack(spacing: 16) {
                Button("Restore") { Task { await paywall.restore() } }
                Link("Terms", destination: AppConfiguration.shared.termsURL)
                Link("Privacy", destination: AppConfiguration.shared.privacyURL)
            }
            .font(.system(.caption2, design: .rounded))
            .foregroundColor(ink.opacity(0.4))
        }
    }
}

// Preview checks at 390px (iPhone 12/13/14/15/16) and 430px (iPhone 14/15/16 Pro Max)
#Preview("Paywall - 390px") {
    PaywallView()
        .frame(width: 390, height: 844)
}

#Preview("Paywall - 430px") {
    PaywallView()
        .frame(width: 430, height: 932)
}
