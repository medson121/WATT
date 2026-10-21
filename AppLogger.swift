// AppLogger.swift - Logging seguro que desativa saídas sensíveis em compilações de Produção / Release
// Previne vazamento de URLs, tokens e payloads via console / syslog do iOS

import Foundation

public enum AppLogger {
    public static func debug(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("🔍 [DEBUG] \(message())")
        #endif
    }

    public static func info(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("ℹ️ [INFO] \(message())")
        #endif
    }

    public static func success(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("✅ \(message())")
        #endif
    }

    public static func error(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("❌ \(message())")
        #endif
    }
}
