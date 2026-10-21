import Foundation

// MARK: - CountryPrice Model
struct CountryPrice: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let flag: String
    let currencySymbol: String
    let pricePerKWh: Double

    // MARK: - Required European Presets: DE, IE, BE, DK, UK, NL
    static let germany = CountryPrice(
        id: "DE",
        name: "Germany",
        flag: "🇩🇪",
        currencySymbol: "€",
        pricePerKWh: 0.3869
    )

    static let ireland = CountryPrice(
        id: "IE",
        name: "Ireland",
        flag: "🇮🇪",
        currencySymbol: "€",
        pricePerKWh: 0.3794
    )

    static let belgium = CountryPrice(
        id: "BE",
        name: "Belgium",
        flag: "🇧🇪",
        currencySymbol: "€",
        pricePerKWh: 0.3421
    )

    static let denmark = CountryPrice(
        id: "DK",
        name: "Denmark",
        flag: "🇩🇰",
        currencySymbol: "kr",
        pricePerKWh: 0.3556
    )

    static let uk = CountryPrice(
        id: "UK",
        name: "United Kingdom",
        flag: "🇬🇧",
        currencySymbol: "£",
        pricePerKWh: 0.3400
    )

    static let netherlands = CountryPrice(
        id: "NL",
        name: "Netherlands",
        flag: "🇳🇱",
        currencySymbol: "€",
        pricePerKWh: 0.3250
    )

    // Additional presets
    static let france = CountryPrice(
        id: "FR",
        name: "France",
        flag: "🇫🇷",
        currencySymbol: "€",
        pricePerKWh: 0.2516
    )

    // All supported countries
    static let allCountries: [CountryPrice] = [
        .germany,
        .ireland,
        .belgium,
        .denmark,
        .uk,
        .netherlands,
        .france
    ]

    static let presets: [CountryPrice] = allCountries
}

// MARK: - PriceData Calculations
struct PriceData {
    static let countries: [CountryPrice] = CountryPrice.allCountries

    /// Annual standby consumption (kWh): (totalWatts * 18 * 365) / 1000
    static func calculateKWh(totalWatts: Double) -> Double {
        (totalWatts * 18.0 * 365.0) / 1000.0
    }

    /// Annual Cost: (totalWatts * 18 * 365) / 1000 * country.pricePerKWh
    static func calculateCost(totalWatts: Double, country: CountryPrice) -> Double {
        calculateKWh(totalWatts: totalWatts) * country.pricePerKWh
    }

    /// Carbon emissions (kg CO2 / year): kWh * 0.40
    static func calculateCO2(totalWatts: Double) -> Double {
        calculateKWh(totalWatts: totalWatts) * 0.40
    }

    /// Equivalent number of trees needed to absorb CO2
    static func calculateTrees(totalWatts: Double) -> Int {
        let co2 = calculateCO2(totalWatts: totalWatts)
        return max(1, Int(round(co2 / 21.0)))
    }
}
