import SwiftUI
import Combine

// MARK: - PostHog Analytics Tracker
public struct PostHogAnalytics {
    /// Captures event with custom properties for PostHog
    public static func capture(event: String, properties: [String: Any]? = nil) {
        #if canImport(PostHog)
        // PostHog SDK integration when package is imported
        PostHogSDK.shared.capture(event, properties: properties)
        #else
        // Structured telemetry logging
        let propString = properties?.map { "\($0.key): \($0.value)" }.joined(separator: ", ") ?? "none"
        print("📊 [PostHog Event] '\(event)' -> [\(propString)]")
        #endif
    }
}

// MARK: - SavingsViewModel
@MainActor
final class SavingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var devices: [VampireDevice]
    @Published var country: CountryPrice
    @Published var totalSavedToday: Double = 0.0

    // Tracks whether first fix event has already fired to prevent duplicate events
    @Published private(set) var hasTrackedFirstFix: Bool = false

    // MARK: - Initializer
    init(
        devices: [VampireDevice] = VampireDevice.defaultDevices,
        country: CountryPrice = .germany
    ) {
        self.devices = devices
        self.country = country
    }

    // MARK: - 1. Live Total Calculation
    /// Sum of unfixed vampires watts * 18 * 365 / 1000 * country.pricePerKWh
    var liveTotalLeaking: Double {
        let unfixedWatts = devices
            .filter { !$0.isFixed }
            .reduce(0.0) { $0 + $1.watts }

        return (unfixedWatts * 18.0 * 365.0 / 1000.0) * country.pricePerKWh
    }

    /// Formatted live total string with country currency symbol
    var formattedLiveTotalLeaking: String {
        String(format: "%@%.2f", country.currencySymbol, liveTotalLeaking)
    }

    /// Total count of remaining active unfixed vampires
    var activeCount: Int {
        devices.filter { !$0.isFixed }.count
    }

    /// Total count of fixed vampires
    var fixedCount: Int {
        devices.filter { $0.isFixed }.count
    }

    /// Total potential savings for remaining unfixed devices
    var remainingPotentialSavings: Double {
        liveTotalLeaking
    }

    /// Formatted daily savings accumulated today
    var formattedTotalSavedToday: String {
        String(format: "%@%.2f", country.currencySymbol, totalSavedToday)
    }

    // MARK: - 2. Function fixVampire(vampire)
    /// Marks vampire as fixed, adds euros saved today (watts * 18 / 1000 * price) to totalSavedToday with animation,
    /// and tracks firstFixCompleted event for PostHog.
    func fixVampire(_ vampire: VampireDevice) {
        guard let index = devices.firstIndex(where: { $0.id == vampire.id }) else {
            return
        }

        // 1. Calculate euros saved today: (watts * 18 / 1000) * pricePerKWh
        let eurosSavedToday = (vampire.watts * 18.0 / 1000.0) * country.pricePerKWh

        // 2. Mark as fixed and accumulate daily savings with animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            devices[index].isFixed = true
            totalSavedToday += eurosSavedToday
        }

        // 3. Track firstFixCompleted event for PostHog
        if !hasTrackedFirstFix {
            hasTrackedFirstFix = true
            trackFirstFixCompleted(for: vampire, dailySaved: eurosSavedToday)
        }
    }

    // MARK: - 3. PostHog Event Tracking
    private func trackFirstFixCompleted(for vampire: VampireDevice, dailySaved: Double) {
        let properties: [String: Any] = [
            "device_id": vampire.id.uuidString,
            "device_name": vampire.name,
            "device_room": vampire.room,
            "device_watts": vampire.watts,
            "yearly_cost_eur": vampire.yearlyCost,
            "daily_savings_today": dailySaved,
            "total_saved_today_accumulated": totalSavedToday,
            "country_id": country.id,
            "country_name": country.name,
            "price_per_kwh": country.pricePerKWh,
            "currency_symbol": country.currencySymbol,
            "remaining_unfixed_vampires": activeCount,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        PostHogAnalytics.capture(
            event: "firstFixCompleted",
            properties: properties
        )
    }

    // MARK: - Country Update
    func updateCountry(_ newCountry: CountryPrice) {
        self.country = newCountry

        // Recalculate each device's yearlyCost based on new country's rate
        for i in devices.indices {
            devices[i].yearlyCost = PriceData.calculateCost(totalWatts: devices[i].watts, country: newCountry)
        }
    }
}
