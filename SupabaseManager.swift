// SupabaseManager.swift - Conecta seu app iOS com o banco que você criou na Parte 1
// Cole no Antigravity - funciona no Windows!

import Foundation
import SwiftUI

// MARK: - Modelo simples (sem SDK externo, usa URLSession - funciona 100% no Windows)

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // ⚠️ TROQUE AQUI PELO SEU - vou te mostrar onde pegar
    private(set) var supabaseURL = "https://SEU_PROJETO.supabase.co"
    private(set) var supabaseAnonKey = "SEU_ANON_KEY_AQUI"
    
    @Published var isConnected = false
    @Published var lastError: String?

    // Permite configurar a URL e Chave dinamicamente
    func configure(url: String, anonKey: String) {
        self.supabaseURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        self.supabaseAnonKey = anonKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Testar conexão com countries_prices (que você já criou)
    func testConnection() async -> Bool {
        let urlString = "\(supabaseURL)/rest/v1/countries_prices?select=*&limit=1"
        guard let url = URL(string: urlString) else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Supabase conectado! Dados: \(String(data: data, encoding: .utf8) ?? "")")
                await MainActor.run { self.isConnected = true }
                return true
            }
        } catch {
            print("❌ Erro conexão: \(error)")
            await MainActor.run { self.lastError = error.localizedDescription }
        }
        return false
    }
    
    // MARK: - Salvar vampiro do usuário
    func saveUserVampire(catalogId: String, customWatts: Double?, room: String) async {
        let urlString = "\(supabaseURL)/rest/v1/user_vampires"
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
        let urlString = "\(supabaseURL)/rest/v1/daily_checks"
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
        let urlString = "\(supabaseURL)/rest/v1/countries_prices?select=*"
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let countries = try JSONDecoder().decode([CountryPrice].self, from: data)
            print("✅ \(countries.count) países buscados do Supabase")
            return countries
        } catch {
            print("❌ Erro buscar países: \(error)")
            return CountryPrice.all // fallback para dados mock
        }
    }
}
