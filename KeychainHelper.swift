// KeychainHelper.swift - Armazenamento seguro criptografado por hardware (Secure Enclave / iOS Keychain)
// Protege entitlements de assinatura, tokens e IDs de sessão contra adulteração e jailbreak

import Foundation
#if canImport(Security)
import Security
#endif

public enum KeychainHelper {
    private static let serviceName = "app.watt.security"

    public static func save(key: String, data: Data) -> Bool {
        #if canImport(Security)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
        #else
        UserDefaults.standard.set(data, forKey: "keychain_\(key)")
        return true
        #endif
    }

    public static func load(key: String) -> Data? {
        #if canImport(Security)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return data
        }
        return nil
        #else
        return UserDefaults.standard.data(forKey: "keychain_\(key)")
        #endif
    }

    public static func delete(key: String) {
        #if canImport(Security)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        #else
        UserDefaults.standard.removeObject(forKey: "keychain_\(key)")
        #endif
    }

    public static func saveString(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return save(key: key, data: data)
    }

    public static func loadString(key: String) -> String? {
        guard let data = load(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public static func saveBool(key: String, value: Bool) -> Bool {
        saveString(key: key, value: value ? "1" : "0")
    }

    public static func loadBool(key: String) -> Bool {
        guard let str = loadString(key: key) else { return false }
        return str == "1"
    }

    /// Retorna ou gera um UUID anônimo único para o dispositivo protegido pelo Keychain
    public static func getOrCreateDeviceUUID() -> String {
        let key = "watt_device_uuid"
        if let existing = loadString(key: key), !existing.isEmpty {
            return existing
        }
        let newUUID = UUID().uuidString
        _ = saveString(key: key, value: newUUID)
        return newUUID
    }
}
