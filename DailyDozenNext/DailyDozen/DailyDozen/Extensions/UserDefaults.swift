//
//  UserDefaults.swift
//  DailyDozen
//
//
//
import Foundation

extension UserDefaults {
    /// Prints only the Apple language & locale related keys that affect your app’s localization
    func printAppleLanguageSettingsOnly() {
        let defaults = UserDefaults.standard
        
        print("=== Apple Language & Locale Settings ===")
        
        // These are the exact keys iOS uses to determine the app language
        let languageKeys = [
            "AppleLanguages",           // Primary: array of preferred languages
            "AppleLocale",              // Current locale identifier (e.g. "en_US")
            "AppleLanguagesDidMigrate", // iOS 13+ migration flag
            "NSLanguages"               // Fallback key some older apps use
        ]
        
        for key in languageKeys {
            if let value = defaults.object(forKey: key) {
                print("\(key): \(value)")
            } else {
                print("\(key): <not set>")
            }
        }
        
        // Bonus: show what the system actually thinks the current language is
        let currentLang = Locale.current.language.languageCode?.identifier ?? "unknown"
        let currentRegion = Locale.current.region?.identifier ?? "unknown"
        let resolvedLang = Bundle.main.preferredLocalizations.first ?? "unknown"
        
        print("\nLocale.current: \(Locale.current.identifier) (\(currentLang)-\(currentRegion))")
        print("Bundle.main.preferredLocalizations.first: \(resolvedLang)")
        print("========================================\n")
    }
}

// MARK: - One-liner usage anywhere

//UserDefaults.standard.printAppleLanguageSettingsOnly()

// MARK: Test Foreign Language

// Put this in @main struct to test French even on an English device
//UserDefaults.standard.set(["fr"], forKey: "AppleLanguages")
//UserDefaults.standard.set("fr_FR", forKey: "AppleLocale")
