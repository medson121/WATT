import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 1. MODELO DE DADOS: VampireDevice
struct VampireDevice: Identifiable, Equatable {
    let id: UUID
    var name: String
    var room: String
    var iconName: String
    var watts: Double
    var yearlyCost: Double
    var isFixed: Bool

    // Calculated daily savings: yearlyCost / 365.0
    var dailySavingsFormatted: String {
        let daily = yearlyCost / 365.0
        return String(format: "€%.2f", daily)
    }

    // Default 6 vampires summing to exactly €86.40
    static let defaultDevices: [VampireDevice] = [
        VampireDevice(
            id: UUID(),
            name: "TV LED 55\"",
            room: "Living Room",
            iconName: "tv.fill",
            watts: 15.0,
            yearlyCost: 20.80,
            isFixed: false
        ),
        VampireDevice(
            id: UUID(),
            name: "Gaming Console",
            room: "Living Room",
            iconName: "gamecontroller.fill",
            watts: 13.5,
            yearlyCost: 18.60,
            isFixed: false
        ),
        VampireDevice(
            id: UUID(),
            name: "Desktop PC Setup",
            room: "Office",
            iconName: "desktopcomputer",
            watts: 16.0,
            yearlyCost: 22.40,
            isFixed: false
        ),
        VampireDevice(
            id: UUID(),
            name: "Wi-Fi & Mesh Pods",
            room: "Hallway",
            iconName: "wifi",
            watts: 9.0,
            yearlyCost: 12.50,
            isFixed: false
        ),
        VampireDevice(
            id: UUID(),
            name: "Microwave Oven",
            room: "Kitchen",
            iconName: "microwave.fill",
            watts: 5.0,
            yearlyCost: 6.90,
            isFixed: false
        ),
        VampireDevice(
            id: UUID(),
            name: "Soundbar & Sub",
            room: "Living Room",
            iconName: "hifispeaker.fill",
            watts: 3.8,
            yearlyCost: 5.20,
            isFixed: false
        )
    ]
}

// MARK: - 2. TELA PRINCIPAL: VampireListView
struct VampireListView: View {
    @StateObject private var viewModel: SavingsViewModel
    @StateObject var paywall = PaywallManager.shared
    @State private var deviceToFix: VampireDevice? = nil
    @State private var showSupabaseTest: Bool = false
    @State private var auditPulsing: Bool = false

    init(devices: [VampireDevice] = VampireDevice.defaultDevices, country: CountryPrice = .germany) {
        _viewModel = StateObject(wrappedValue: SavingsViewModel(devices: devices, country: country))
    }

    var totalLeaking: Double {
        viewModel.liveTotalLeaking
    }

    var activeCount: Int {
        viewModel.activeCount
    }

    var fixedCount: Int {
        viewModel.fixedCount
    }

    var remainingPotentialSavings: Double {
        viewModel.remainingPotentialSavings
    }

    var body: some View {
        ZStack {
            // Background color #FFF9F0 with ambient light
            Color(hex: "FFF9F0")
                .ignoresSafeArea()

            // Soft diffuse ambient lighting (blue & amber blobs)
            VStack {
                HStack {
                    Circle()
                        .fill(Color(hex: "3B82F6").opacity(0.08))
                        .frame(width: 260, height: 260)
                        .blur(radius: 50)
                        .offset(x: -80, y: -40)
                    Spacer()
                    Circle()
                        .fill(Color(hex: "F59E0B").opacity(0.08))
                        .frame(width: 240, height: 240)
                        .blur(radius: 45)
                        .offset(x: 60, y: 30)
                }
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header Fixo Superior
                VStack(spacing: 12) {
                    // Header Top Row: LIVE AUDIT Badge + Supabase Cloud Status
                    HStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(activeCount > 0 ? Color(hex: "EF4444") : Color(hex: "10B981"))
                                .frame(width: 8, height: 8)
                                .scaleEffect(auditPulsing ? 1.35 : 0.85)
                                .opacity(auditPulsing ? 1.0 : 0.4)

                            Text(activeCount > 0 ? "LIVE AUDIT • LEAKS ACTIVE" : "AUDIT COMPLETE • PROTECTED")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(activeCount > 0 ? Color(hex: "B91C1C") : Color(hex: "065F46"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(activeCount > 0 ? Color(hex: "FEE2E2") : Color(hex: "D1FAE5"))
                        )

                        Spacer()

                        Button {
                            showSupabaseTest = true
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "externaldrive.badge.icloud")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("DB")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(Color(hex: "059669"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "D1FAE5"))
                            )
                        }
                    }

                    // Dynamic Title
                    Text(activeCount == 0 ? "All vampires eliminated! 🎉" : "Found \(activeCount) vampires leaking €\(String(format: "%.0f", totalLeaking))/year")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235"))
                        .multilineTextAlignment(.center)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: activeCount)

                    // Live Total Counter
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("Total leaking:")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "0F2235").opacity(0.65))

                        Text("€\(String(format: "%.2f", totalLeaking))")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(activeCount == 0 ? Color(hex: "10B981") : Color(hex: "D97706"))
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: totalLeaking)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 16)
                .background(
                    Color(hex: "FFF9F0").opacity(0.92)
                )

                // MARK: - Lista de Cards em Glassmorphism
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.devices) { device in
                            let isLocked = !paywall.isPro && (paywall.hasCompletedFirstFix || fixedCount >= 1) && !device.isFixed
                            VampireCardView(device: device, isLocked: isLocked) {
                                triggerTapHaptic()
                                if isLocked {
                                    paywall.showPaywall = true
                                } else {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        deviceToFix = device
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, fixedCount >= 1 ? 140 : 40)
                }
            }

            // MARK: - Gatilho Pro (Após o 1º Fix Grátis se não for Pro)
            if !paywall.isPro && (paywall.hasCompletedFirstFix || fixedCount >= 1) && activeCount > 0 {
                VStack {
                    Spacer()

                    Button(action: {
                        triggerTapHaptic()
                        paywall.showPaywall = true
                    }) {
                        HStack(spacing: 12) {
                            // Crown icon
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "crown.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "FBBF24"))
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text("Fix \(activeCount) more?")
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)

                                    Text("PRO")
                                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                                        .foregroundColor(Color(hex: "1E40AF"))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(Color(hex: "FBBF24")))
                                }

                                Text("Save up to €\(String(format: "%.2f", remainingPotentialSavings))/year with 1-tap automations")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "1E40AF"), Color(hex: "3B82F6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "1E40AF").opacity(0.35), radius: 18, x: 0, y: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // MARK: - 3. FixAnimationView Overlay
            if let device = deviceToFix {
                FixAnimationView(
                    deviceName: device.name,
                    room: device.room,
                    watts: device.watts,
                    yearlyCost: device.yearlyCost,
                    dailySavingsFormatted: device.dailySavingsFormatted,
                    onComplete: {
                        viewModel.fixVampire(device)
                        paywall.completeFirstFix()
                        deviceToFix = nil
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(100)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                auditPulsing = true
            }
        }
        .sheet(isPresented: $paywall.showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showSupabaseTest) {
            SupabaseTestView()
        }
    }

    private func triggerTapHaptic() {
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Vampire Card in Glassmorphism
struct VampireCardView: View {
    let device: VampireDevice
    var isLocked: Bool = false
    let onFix: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Icon Container - Volt Companion
            ZStack {
                VampireCharacterView(
                    mood: device.isFixed ? .fixed : .leaking,
                    size: 48,
                    showBubble: false
                )
            }
            .frame(width: 54, height: 54)

            // Info Column
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(device.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(isLocked ? Color(hex: "0F2235").opacity(0.65) : Color(hex: "0F2235"))

                    Text(device.room)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235").opacity(0.55))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(hex: "F3F4F6")))
                }

                HStack(spacing: 8) {
                    // Consumption tag in Watts
                    Text(String(format: "%.1fW", device.watts))
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(isLocked ? Color(hex: "9CA3AF") : Color(hex: "D97706"))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(isLocked ? Color(hex: "F3F4F6") : Color(hex: "FEF3C7")))

                    // Annual cost
                    Text("€\(String(format: "%.2f", device.yearlyCost))/year")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(device.isFixed ? Color(hex: "10B981") : Color(hex: "0F2235").opacity(isLocked ? 0.5 : 0.85))
                }
            }

            Spacer()

            // Action Button / State Indicator
            if device.isFixed {
                // Done state
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .heavy))
                        Text("FIXED!")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "059669"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: "D1FAE5"))
                    )

                    Text("Saved \(device.dailySavingsFormatted) today")
                        .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "059669").opacity(0.85))
                }
            } else if isLocked {
                // Locked State with Lock Icon
                Button(action: onFix) {
                    HStack(spacing: 5) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("FIX")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "4B5563"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "E5E7EB"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
                    )
                }
            } else {
                // Active FIX Button
                Button(action: onFix) {
                    Text("FIX")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "2563EB").opacity(0.38), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(device.isFixed ? Color(hex: "ECFDF5").opacity(0.95) : (isLocked ? Color.white.opacity(0.65) : Color.white.opacity(0.85)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(device.isFixed ? Color(hex: "A7F3D0") : (isLocked ? Color(hex: "E5E7EB") : Color.white), lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "0F2235").opacity(0.05), radius: 12, x: 0, y: 6)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: device.isFixed)
    }
}

// MARK: - Paywall Modal Sheet
struct PaywallModalSheet: View {
    let remainingSavings: Double
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "FFF9F0").ignoresSafeArea()

            VStack(spacing: 24) {
                // Header Crown
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FEF3C7"))
                            .frame(width: 64, height: 64)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "F59E0B"))
                    }
                    .padding(.top, 16)

                    Text("WATT Pro ⚡️")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235"))

                    Text("Save up to €\(String(format: "%.2f", remainingSavings))/year with automations")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235").opacity(0.70))
                }

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    ProFeatureRow(icon: "bolt.badge.automatic.fill", title: "1-Tap Auto-Standby Kill", desc: "Cuts power automatically when not in use")
                    ProFeatureRow(icon: "shield.lefthalf.filled", title: "24/7 Smart Leak Monitor", desc: "Instant alert when an appliance starts leaking")
                    ProFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Live EUR Savings Tracker", desc: "Detailed breakdown per room and socket")
                    ProFeatureRow(icon: "infinity", title: "Unlimited Devices & Rooms", desc: "Protect your whole house forever")
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
                .padding(.horizontal, 20)

                // Plan Box (€2.99/mo with 7-day trial)
                VStack(spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Annual VIP • 7 Days Free")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235"))

                            Text("Then just €2.99 / month, billed annually")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235").opacity(0.60))
                        }

                        Spacer()

                        Text("7 DAYS FREE")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color(hex: "10B981")))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(hex: "EFF6FF"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(hex: "3B82F6"), lineWidth: 2)
                )
                .padding(.horizontal, 20)

                // CTA Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Start 7-Day Free Trial")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "3B82F6"), Color(hex: "1D4ED8")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color(hex: "1D4ED8").opacity(0.35), radius: 14, x: 0, y: 7)
                }
                .padding(.horizontal, 20)

                Text("Cancel anytime in Apple App Store. Zero commitment.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.50))
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Pro Feature Row
struct ProFeatureRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "3B82F6"))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13.5, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235"))

                Text(desc)
                    .font(.system(size: 11.5, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.60))
            }
        }
    }
}

// MARK: - SwiftUI Preview
#Preview("VampireListView") {
    VampireListView()
}
