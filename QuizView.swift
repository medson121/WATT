import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Vampire Appliance Model
struct VampireAppliance: Identifiable, Equatable {
    let id: String
    let name: String
    let category: String
    let icon: String
    let standbyWatts: Double
    let hint: String

    static let defaultAppliances: [VampireAppliance] = [
        VampireAppliance(
            id: "tv",
            name: "Smart TV / OLED",
            category: "Living Room",
            icon: "tv.fill",
            standbyWatts: 15.0,
            hint: "Instant-on & sensor idle"
        ),
        VampireAppliance(
            id: "console",
            name: "Game Console",
            category: "Entertainment",
            icon: "gamecontroller.fill",
            standbyWatts: 13.0,
            hint: "PS5 / Xbox rest mode"
        ),
        VampireAppliance(
            id: "tv_box",
            name: "TV Streamer Box",
            category: "Living Room",
            icon: "play.tv.fill",
            standbyWatts: 8.5,
            hint: "Apple TV / Cable receiver"
        ),
        VampireAppliance(
            id: "pc",
            name: "Desktop & Screens",
            category: "Home Office",
            icon: "desktopcomputer",
            standbyWatts: 18.0,
            hint: "Dual monitors & PC sleep"
        ),
        VampireAppliance(
            id: "router",
            name: "Wi-Fi & Mesh Pods",
            category: "Network",
            icon: "wifi",
            standbyWatts: 10.0,
            hint: "Continuous standby"
        ),
        VampireAppliance(
            id: "microwave",
            name: "Microwave / Coffee",
            category: "Kitchen",
            icon: "microwave.fill",
            standbyWatts: 4.5,
            hint: "Clock LED & heating unit"
        ),
        VampireAppliance(
            id: "audio",
            name: "Soundbar / Audio",
            category: "Living Room",
            icon: "hifispeaker.fill",
            standbyWatts: 7.5,
            hint: "Bluetooth / Subwoofer idle"
        ),
        VampireAppliance(
            id: "chargers",
            name: "Idle Chargers",
            category: "Everywhere",
            icon: "bolt.badge.clock.fill",
            standbyWatts: 3.5,
            hint: "Phone / laptop bricks plugged in"
        )
    ]
}

// MARK: - QuizView
struct QuizView: View {
    // Selected Country (Defaults to Germany, user can change to DE, IE, BE, DK, UK, NL)
    @State private var selectedCountry: CountryPrice = .germany

    // Selected vampire devices (defaults to 3 common appliances)
    @State private var selectedIDs: Set<String> = ["tv", "console", "router"]

    // Navigation trigger to AhaCalculationView
    @State private var navigateToAha: Bool = false

    // Country Sheet Picker
    @State private var showCountrySheet: Bool = false

    let appliances: [VampireAppliance] = VampireAppliance.defaultAppliances

    // Calculate total watts from selected vampires
    var totalWatts: Double {
        appliances
            .filter { selectedIDs.contains($0.id) }
            .reduce(0.0) { $0 + $1.standbyWatts }
    }

    // Dynamic live cost calculation using PriceData formula
    var liveEstimatedCost: Double {
        PriceData.calculateCost(totalWatts: totalWatts, country: selectedCountry)
    }

    // Convert selected appliances to VampireDevice instances with localized yearly costs
    var selectedVampireDevices: [VampireDevice] {
        let filtered = appliances.filter { selectedIDs.contains($0.id) }
        let list = filtered.isEmpty ? appliances : filtered
        return list.map { app in
            let cost = PriceData.calculateCost(totalWatts: app.standbyWatts, country: selectedCountry)
            return VampireDevice(
                id: UUID(),
                name: app.name,
                room: app.category,
                iconName: app.icon,
                watts: app.standbyWatts,
                yearlyCost: cost,
                isFixed: false
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color #FFF9F0
                Color(hex: "FFF9F0")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Top Header & Country Selector
                    VStack(spacing: 14) {
                        // Country Selector Pill
                        Button(action: {
                            showCountrySheet = true
                        }) {
                            HStack(spacing: 8) {
                                Text(selectedCountry.flag)
                                    .font(.system(size: 16))

                                Text("\(selectedCountry.name) (\(selectedCountry.currencySymbol)\(String(format: "%.2f", selectedCountry.pricePerKWh))/kWh)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "0F2235"))

                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "0F2235").opacity(0.6))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "E5E7EB"), lineWidth: 1.2)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }

                        // Title & Subtitle
                        VStack(spacing: 6) {
                            Text("Which vampires live in\nyour home? 🧛")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)

                            Text("Tap each appliance you leave plugged in on standby.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235").opacity(0.65))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 12)

                    // MARK: - Appliance Grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(appliances) { item in
                                let isSelected = selectedIDs.contains(item.id)

                                ApplianceCard(
                                    item: item,
                                    isSelected: isSelected
                                ) {
                                    toggleAppliance(item.id)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 120) // space for floating bottom bar
                    }
                }

                // MARK: - Floating Bottom Bar & CTA
                VStack {
                    Spacer()

                    VStack(spacing: 12) {
                        // Live summary ticker
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(selectedIDs.count) vampires selected")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "0F2235"))

                                Text(String(format: "%.1fW total standby drain", totalWatts))
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "0F2235").opacity(0.60))
                            }

                            Spacer()

                            // Estimated annual cost pill
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Leaking ~")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "0F2235").opacity(0.55))

                                Text("\(selectedCountry.currencySymbol)\(String(format: "%.2f", liveEstimatedCost))/yr")
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(hex: "D97706"))
                            }
                        }
                        .padding(.horizontal, 6)

                        // Primary Action Button
                        Button(action: {
                            triggerHaptic()
                            navigateToAha = true
                        }) {
                            HStack(spacing: 8) {
                                Text("Calculate my leak")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
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
                            .shadow(color: Color(hex: "1D4ED8").opacity(0.38), radius: 14, x: 0, y: 7)
                        }
                        .disabled(selectedIDs.isEmpty)
                        .opacity(selectedIDs.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.96))
                            .shadow(color: Color(hex: "0F2235").opacity(0.08), radius: 20, x: 0, y: -6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                }
            }
            .navigationDestination(isPresented: $navigateToAha) {
                // Passes totalWatts, country, and selected vampires to AhaCalculationView
                AhaCalculationView(
                    totalWatts: totalWatts,
                    country: selectedCountry,
                    selectedDevices: selectedVampireDevices
                )
            }
            .sheet(isPresented: $showCountrySheet) {
                CountrySelectionSheet(
                    selectedCountry: $selectedCountry,
                    countries: PriceData.countries
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // Toggle appliance selection with haptics
    private func toggleAppliance(_ id: String) {
        triggerHaptic()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            if selectedIDs.contains(id) {
                selectedIDs.remove(id)
            } else {
                selectedIDs.insert(id)
            }
        }
    }

    private func triggerHaptic() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Appliance Grid Card
struct ApplianceCard: View {
    let item: VampireAppliance
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Icon and Selection Badge
                HStack {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color(hex: "3B82F6") : Color(hex: "F3F4F6"))
                            .frame(width: 40, height: 40)

                        Image(systemName: item.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isSelected ? .white : Color(hex: "0F2235"))
                    }

                    Spacer()

                    // Selection Indicator
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color(hex: "3B82F6") : Color.clear)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color(hex: "3B82F6") : Color(hex: "D1D5DB"), lineWidth: 1.8)
                            )

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Name and Standby Watts
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235"))
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(String(format: "%.1fW", item.standbyWatts))
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(isSelected ? Color(hex: "2563EB") : Color(hex: "D97706"))

                        Text("standby")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "0F2235").opacity(0.55))
                    }
                }

                // Subtitle hint
                Text(item.hint)
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.50))
                    .lineLimit(1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color(hex: "EFF6FF") : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color(hex: "3B82F6") : Color(hex: "E5E7EB"), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Color(hex: "3B82F6").opacity(0.12) : Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
            .scaleEffect(isSelected ? 1.015 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Country Selection Sheet
struct CountrySelectionSheet: View {
    @Binding var selectedCountry: CountryPrice
    let countries: [CountryPrice]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(countries) { country in
                Button(action: {
                    selectedCountry = country
                    dismiss()
                }) {
                    HStack(spacing: 14) {
                        Text(country.flag)
                            .font(.system(size: 26))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235"))

                            Text("\(country.currencySymbol)\(String(format: "%.4f", country.pricePerKWh)) per kWh")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235").opacity(0.60))
                        }

                        Spacer()

                        if selectedCountry == country {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "3B82F6"))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
        }
    }
}

// MARK: - SwiftUI Preview
#Preview("QuizView - Default") {
    QuizView()
}
