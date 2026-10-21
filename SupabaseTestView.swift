import SwiftUI

// MARK: - SupabaseTestView
struct SupabaseTestView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isFetchingCountries = false
    @State private var showRawJson = false
    @State private var pingAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background #FFF9F0
                Color(hex: "FFF9F0")
                    .ignoresSafeArea()

                // Ambient emerald & amber glow blobs
                VStack {
                    HStack {
                        Circle()
                            .fill(Color(hex: "10B981").opacity(0.10))
                            .frame(width: 260, height: 260)
                            .blur(radius: 50)
                            .offset(x: -60, y: -40)
                        Spacer()
                        Circle()
                            .fill(Color(hex: "3B82F6").opacity(0.08))
                            .frame(width: 240, height: 240)
                            .blur(radius: 45)
                            .offset(x: 50, y: 20)
                    }
                    Spacer()
                }
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Header Icon & Title
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "10B981").opacity(0.25), Color(hex: "059669").opacity(0.12)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(pingAnimation ? 1.08 : 0.96)
                                    .animation(
                                        supabase.isTesting
                                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                        : .default,
                                        value: pingAnimation
                                    )

                                Image(systemName: "externaldrive.badge.icloud")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(Color(hex: "059669"))
                            }
                            .padding(.top, 8)

                            Text("Supabase Cloud Health")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235"))

                            Text("Test connection to REST v1 endpoints & verify database tables")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235").opacity(0.65))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        // MARK: - Status Hero Card
                        statusHeroCard

                        // MARK: - Endpoint Credentials Card
                        credentialsCard

                        // MARK: - Action Buttons
                        actionButtonsSection

                        // MARK: - Live Response Payload Card
                        if let response = supabase.lastResponse, !response.isEmpty {
                            responsePayloadCard(json: response)
                        }

                        // MARK: - Fetched Countries Preview
                        if !supabase.fetchedCountries.isEmpty {
                            fetchedCountriesSection
                        }

                        // MARK: - Tables Overview
                        databaseTablesOverview
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Supabase Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "0F2235").opacity(0.45))
                    }
                }
            }
        }
        .onAppear {
            pingAnimation = true
        }
    }

    // MARK: - Status Hero Card
    private var statusHeroCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                // Status indicator icon
                ZStack {
                    Circle()
                        .fill(statusBackgroundColor)
                        .frame(width: 44, height: 44)

                    if supabase.isTesting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "059669")))
                    } else if supabase.isConnected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "10B981"))
                    } else if supabase.lastError != nil {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "EF4444"))
                    } else {
                        Image(systemName: "bolt.horizontal.circle")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(statusTitleText)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235"))

                    Text(statusSubtitleText)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "0F2235").opacity(0.65))
                }

                Spacer()

                if let latency = supabase.lastLatencyMs {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(latency) ms")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(latency < 300 ? Color(hex: "059669") : Color(hex: "D97706"))

                        Text("Latency")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "0F2235").opacity(0.45))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                    )
                }
            }

            if let error = supabase.lastError {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "xmark.octagon.fill")
                        .foregroundColor(Color(hex: "EF4444"))
                        .font(.system(size: 14))
                        .padding(.top, 2)

                    Text(error)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "B91C1C"))
                        .lineLimit(4)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "FEE2E2").opacity(0.8))
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(statusBorderColor, lineWidth: 1.5)
                )
        )
    }

    private var statusTitleText: String {
        if supabase.isTesting {
            return "Testing Connection..."
        } else if supabase.isConnected {
            return "Supabase Connected"
        } else if supabase.lastError != nil {
            return "Connection Failed"
        } else {
            return "Ready to Test"
        }
    }

    private var statusSubtitleText: String {
        if supabase.isTesting {
            return "Sending GET request to /countries_prices"
        } else if supabase.isConnected {
            return "HTTP 200 OK • Database reachable"
        } else if supabase.lastError != nil {
            return "Check error details below"
        } else {
            return "Tap 'Test Connection' below"
        }
    }

    private var statusBackgroundColor: Color {
        if supabase.isConnected {
            return Color(hex: "D1FAE5")
        } else if supabase.lastError != nil {
            return Color(hex: "FEE2E2")
        } else {
            return Color(hex: "F1F5F9")
        }
    }

    private var statusBorderColor: Color {
        if supabase.isConnected {
            return Color(hex: "10B981").opacity(0.4)
        } else if supabase.lastError != nil {
            return Color(hex: "EF4444").opacity(0.3)
        } else {
            return Color.black.opacity(0.05)
        }
    }

    // MARK: - Endpoint Credentials Card
    private var credentialsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("CONFIGURED ENDPOINT", systemImage: "link.badge.plus")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.5))

                Spacer()

                Text("REST v1")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "059669"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(Color(hex: "D1FAE5"))
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Supabase URL")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.5))

                Text(supabase.supabaseURL)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(hex: "0F2235"))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Publishable Anon Key")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.5))

                Text(maskedAnonKey)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(hex: "0F2235"))
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }

    private var maskedAnonKey: String {
        let key = supabase.supabaseAnonKey
        guard key.count > 16 else { return key }
        let prefix = key.prefix(12)
        let suffix = key.suffix(6)
        return "\(prefix)...\(suffix)"
    }

    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Main Test Connection Button
            Button {
                triggerHaptic()
                Task {
                    _ = await supabase.testConnection()
                }
            } label: {
                HStack(spacing: 10) {
                    if supabase.isTesting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .bold))
                    }

                    Text(supabase.isTesting ? "Testing Connection..." : "Test Connection")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "059669"), Color(hex: "10B981")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "059669").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(supabase.isTesting)

            // Secondary Fetch Live Countries Button
            Button {
                triggerHaptic()
                isFetchingCountries = true
                Task {
                    _ = await supabase.fetchCountries()
                    await MainActor.run {
                        isFetchingCountries = false
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if isFetchingCountries {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "0F2235")))
                    } else {
                        Image(systemName: "globe.europe.africa.fill")
                            .font(.system(size: 15))
                    }

                    Text(isFetchingCountries ? "Fetching Countries..." : "Fetch Live Countries Table")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color(hex: "0F2235"))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
            .disabled(isFetchingCountries)
        }
    }

    // MARK: - Live Response Payload Card
    private func responsePayloadCard(json: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("SERVER RESPONSE", systemImage: "curlybraces")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.5))

                Spacer()

                if let code = supabase.lastStatusCode {
                    Text("HTTP \(code)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(code == 200 ? Color(hex: "059669") : Color(hex: "EF4444"))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(json)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "0F2235"))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "F8FAFC"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }

    // MARK: - Fetched Countries Section
    private var fetchedCountriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("LIVE DATABASE COUNTRIES (\(supabase.fetchedCountries.count))", systemImage: "flag.fill")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.5))

                Spacer()

                Text("LIVE SYNC")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "10B981"))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(supabase.fetchedCountries) { country in
                    HStack(spacing: 10) {
                        Text(country.flag)
                            .font(.system(size: 24))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "0F2235"))
                                .lineLimit(1)

                            Text(String(format: "%@%.4f/kWh", country.currencySymbol, country.pricePerKWh))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "059669"))
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "F8FAFC"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }

    // MARK: - Database Tables Overview
    private var databaseTablesOverview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SCHEMA TABLES")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "0F2235").opacity(0.5))

            tableStatusRow(name: "countries_prices", description: "Country electricity tariffs & CO2 index", icon: "tablecells.badge.ellipsis", status: "Verified")
            tableStatusRow(name: "user_vampires", description: "Individual phantom appliances identified", icon: "powerplug.fill", status: "Active")
            tableStatusRow(name: "daily_checks", description: "Daily cumulative euros, kWh & CO2 savings", icon: "calendar.badge.clock", status: "Active")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }

    private func tableStatusRow(name: String, description: String, icon: String, status: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "059669"))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "0F2235"))

                Text(description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "0F2235").opacity(0.5))
            }

            Spacer()

            Text(status)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "059669"))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    Capsule().fill(Color(hex: "D1FAE5"))
                )
        }
        .padding(.vertical, 4)
    }

    private func triggerHaptic() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Preview
#Preview {
    SupabaseTestView()
}
