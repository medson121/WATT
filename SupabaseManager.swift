// SupabaseManager.swift - Conecta seu app iOS com o banco Supabase com segurança reforçada
// Protegido contra vazamento de logs, com suporte a RLS via Device UUID e configuração centralizada

import Foundation
import SwiftUI

// MARK: - Gerenciador Seguro do Supabase
public class SupabaseManager: ObservableObject {
    public static let shared = SupabaseManager()
    
    // Configurações seguras carregadas via AppConfiguration
    @Published public private(set) var supabaseURL = AppConfiguration.shared.supabaseURL
    @Published public private(set) var supabaseAnonKey = AppConfiguration.shared.supabaseAnonKey
    
    @Published public var isConnected = false
    @Published public var isTesting = false
    @Published public var lastError: String?
    @Published public var lastResponse: String?
    @Published public var lastStatusCode: Int?
    @Published public var lastLatencyMs: Int?
    @Published public var lastTestedAt: Date?
    @Published public var fetchedCountries: [CountryPrice] = []

    /// Identificador único e persistente do dispositivo armazenado com segurança no Keychain
    public var deviceUUID: String {
        KeychainHelper.getOrCreateDeviceUUID()
    }

    /// Base REST endpoint URL helper to prevent double slashes or missing /rest/v1
    public var restBaseURL: String {
        var trimmed = supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.hasSuffix("/") {
            trimmed.removeLast()
        }
        if trimmed.hasSuffix("/rest/v1") {
            return trimmed
        } else {
            return "\(trimmed)/rest/v1"
        }
    }

    public init() {}

    // Permite reconfigurar dinamicamente se necessário
    public func configure(url: String, anonKey: String) {
        self.supabaseURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        self.supabaseAnonKey = anonKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Testar conexão com countries_prices
    @discardableResult
    public func testConnection() async -> Bool {
        await MainActor.run {
            self.isTesting = true
            self.lastError = nil
        }
        
        let startTime = Date()
        let urlString = "\(restBaseURL)/countries_prices?select=*&limit=1"
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                self.isTesting = false
                self.lastError = "URL inválida: \(urlString)"
                self.isConnected = false
            }
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(deviceUUID, forHTTPHeaderField: "X-Device-ID")
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let elapsedMs = Int(Date().timeIntervalSince(startTime) * 1000)
            
            if let httpResponse = response as? HTTPURLResponse {
                let responseString = String(data: data, encoding: .utf8) ?? ""
                
                await MainActor.run {
                    self.lastStatusCode = httpResponse.statusCode
                    self.lastLatencyMs = elapsedMs
                    self.lastTestedAt = Date()
                    self.lastResponse = responseString
                }
                
                if httpResponse.statusCode == 200 {
                    AppLogger.success("Supabase conectado com sucesso (\(elapsedMs)ms)")
                    await MainActor.run {
                        self.isConnected = true
                        self.isTesting = false
                    }
                    return true
                } else {
                    let errMsg = "HTTP \(httpResponse.statusCode)"
                    AppLogger.error("Supabase retorno com erro: \(errMsg)")
                    await MainActor.run {
                        self.lastError = errMsg
                        self.isConnected = false
                        self.isTesting = false
                    }
                    return false
                }
            }
        } catch {
            AppLogger.error("Erro na conexão: \(error.localizedDescription)")
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.isConnected = false
                self.isTesting = false
            }
        }
        return false
    }
    
    // MARK: - Salvar vampiro do usuário (associado ao deviceUUID protegido)
    public func saveUserVampire(catalogId: String, customWatts: Double?, room: String) async {
        let urlString = "\(restBaseURL)/user_vampires"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.setValue(deviceUUID, forHTTPHeaderField: "X-Device-ID")
        request.timeoutInterval = 10
        
        var body: [String: Any] = [
            "device_id": deviceUUID,
            "catalog_id": catalogId,
            "room": room,
            "is_fixed": false
        ]
        if let customWatts = customWatts {
            body["custom_watts"] = customWatts
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                AppLogger.success("Vampiro registrado com segurança no Supabase")
            }
        } catch {
            AppLogger.error("Falha ao salvar vampiro: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Salvar check diário (associado ao deviceUUID protegido)
    public func saveDailyCheck(eurosSaved: Double, kwhSaved: Double, co2Saved: Double, vampiresFixed: Int) async {
        let urlString = "\(restBaseURL)/daily_checks"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceUUID, forHTTPHeaderField: "X-Device-ID")
        request.timeoutInterval = 10
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        let body: [String: Any] = [
            "device_id": deviceUUID,
            "date": today,
            "euros_saved": eurosSaved,
            "kwh_saved": kwhSaved,
            "co2_saved": co2Saved,
            "vampires_fixed": vampiresFixed,
            "streak_count": 1
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                AppLogger.success("Check diário persistido com segurança")
            }
        } catch {
            AppLogger.error("Falha ao salvar check diário: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Buscar países
    public func fetchCountries() async -> [CountryPrice] {
        let urlString = "\(restBaseURL)/countries_prices?select=*"
        guard let url = URL(string: urlString) else { return CountryPrice.all }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(deviceUUID, forHTTPHeaderField: "X-Device-ID")
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                let countries = try JSONDecoder().decode([CountryPrice].self, from: data)
                AppLogger.success("\(countries.count) países carregados do Supabase")
                await MainActor.run {
                    self.fetchedCountries = countries
                }
                return countries
            }
            return CountryPrice.all
        } catch {
            AppLogger.error("Erro ao buscar países: \(error.localizedDescription)")
            return CountryPrice.all // fallback para dados mock
        }
    }
    
    // MARK: - Excluir todos os dados do dispositivo (GDPR / LGPD Right to be Forgotten)
    public func purgeDeviceData() async -> Bool {
        AppLogger.info("Iniciando purga de dados para deviceUUID: \(deviceUUID)")
        
        let endpoints = [
            "\(restBaseURL)/daily_checks?device_id=eq.\(deviceUUID)",
            "\(restBaseURL)/user_vampires?device_id=eq.\(deviceUUID)"
        ]
        
        var allSucceeded = true
        for endpoint in endpoints {
            guard let url = URL(string: endpoint) else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(deviceUUID, forHTTPHeaderField: "X-Device-ID")
            request.timeoutInterval = 10
            
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                    AppLogger.success("Dados purgados com sucesso de: \(endpoint)")
                } else {
                    allSucceeded = false
                }
            } catch {
                AppLogger.error("Falha ao purgar dados: \(error.localizedDescription)")
                allSucceeded = false
            }
        }
        
        return allSucceeded
    }
}

