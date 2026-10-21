// AppConfiguration.swift - Gerenciamento seguro de configurações e credenciais
// Suporta injeção via Info.plist, variáveis de ambiente de CI/CD ou defaults seguros

import Foundation

public struct AppConfiguration {
    public static let shared = AppConfiguration()

    // MARK: - Supabase Config
    public let supabaseURL: String
    public let supabaseAnonKey: String

    // MARK: - App Identifiers
    public let termsURL: URL
    public let privacyURL: URL

    private init() {
        let bundle = Bundle.main

        // 1. Tenta carregar do Info.plist ou variáveis de ambiente se configurado
        let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"]
        let plistURL = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        let defaultURL = "https://qjzdkmyxxhocyqvwqmbi.supabase.co/rest/v1"

        let envKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
        let plistKey = bundle.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        let defaultKey = "sb_publishable_9mpwzt_DM90N73wBsD-XEw_PVyVbzuP"

        self.supabaseURL = envURL ?? plistURL ?? defaultURL
        self.supabaseAnonKey = envKey ?? plistKey ?? defaultKey

        self.termsURL = URL(string: "https://watt.app/terms") ?? URL(string: "about:blank")!
        self.privacyURL = URL(string: "https://watt.app/privacy") ?? URL(string: "about:blank")!
    }
}
