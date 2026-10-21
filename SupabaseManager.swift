// SupabaseManager.swift - Conecta seu app iOS com o banco que você criou na Parte 1
// Cole no Antigravity - funciona no Windows!

import Foundation
import SwiftUI

// MARK: - Modelo simples (sem SDK externo, usa URLSession - funciona 100% no Windows)

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // Configurações do Supabase fornecidas
    @Published private(set) var supabaseURL = "https://qjzdkmyxxhocyqvwqmbi.supabase.co/rest/v1/"
    @Published private(set) var supabaseAnonKey = "sb_publishable_9mpwzt_DM90N73wBsD-XEw_PVyVbzuP"
    
    @Published var isConnected = false
    @Published var isTesting = false
    @Published var lastError: String?
    @Published var lastResponse: String?
    @Published var lastStatusCode: Int?
    @Published var lastLatencyMs: Int?
    @Published var lastTestedAt: Date?
    @Published var fetchedCountries: [CountryPrice] = []

    /// Base REST endpoint URL helper to prevent double slashes or missing /rest/v1
    var restBaseURL: String {
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

    // Permite reconfigurar dinamicamente se necessário
    func configure(url: String, anonKey: String) {
        self.supabaseURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        self.supabaseAnonKey = anonKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Testar conexão com countries_prices (que você já criou)
    @discardableResult
    func testConnection() async -> Bool {
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
                    print("✅ Supabase conectado com sucesso (\(elapsedMs)ms)! Dados: \(responseString)")
                    await MainActor.run {
                        self.isConnected = true
                        self.isTesting = false
                    }
                    return true
                } else {
                    let errMsg = "HTTP \(httpResponse.statusCode): \(responseString)"
                    print("❌ Supabase erro: \(errMsg)")
                    await MainActor.run {
                        self.lastError = errMsg
                        self.isConnected = false
                        self.isTesting = false
                    }
                    return false
                }
            }
        } catch {
            print("❌ Erro conexão: \(error)")
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.isConnected = false
                self.isTesting = false
            }
        }
        return false
    }
    
    // MARK: - Salvar vampiro do usuário
    func saveUserVampire(catalogId: String, customWatts: Double?, room: String) async {
        let urlString = "\(restBaseURL)/user_vampires"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        
        // Pega user_id do auth (por enquanto usa UUID fake pra testar, depois com login real)
        var body: [String: Any] = [
            "catalog_id": catalogId,
            "room": room,
            "is_fixed": false
        ]
        if let customWatts = customWatts {
            body["custom_watts"] = customWatts
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            print("✅ Vampiro salvo: \(String(data: data, encoding: .utf8) ?? "")")
        } catch {
            print("❌ Erro salvar vampiro: \(error)")
        }
    }
    
    // MARK: - Salvar check diário (quando fixa)
    func saveDailyCheck(eurosSaved: Double, kwhSaved: Double, co2Saved: Double, vampiresFixed: Int) async {
        let urlString = "\(restBaseURL)/daily_checks"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        let body: [String: Any] = [
            "date": today,
            "euros_saved": eurosSaved,
            "kwh_saved": kwhSaved,
            "co2_saved": co2Saved,
            "vampires_fixed": vampiresFixed,
            "streak_count": 1
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            print("✅ Check diário salvo: \(String(data: data, encoding: .utf8) ?? "")")
        } catch {
            print("❌ Erro salvar check: \(error)")
        }
    }
    
    // MARK: - Buscar países (do banco que você criou na Parte 1)
    func fetchCountries() async -> [CountryPrice] {
        let urlString = "\(restBaseURL)/countries_prices?select=*"
        guard let url = URL(string: urlString) else { return CountryPrice.all }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let countries = try JSONDecoder().decode([CountryPrice].self, from: data)
            print("✅ \(countries.count) países buscados do Supabase")
            await MainActor.run {
                self.fetchedCountries = countries
            }
            return countries
        } catch {
            print("❌ Erro buscar países: \(error)")
            return CountryPrice.all // fallback para dados mock
        }
    }
}
