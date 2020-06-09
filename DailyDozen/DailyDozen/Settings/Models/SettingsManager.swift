//
//  SettingsManager.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct SettingsManager {
    
    public static func isImperial() -> Bool {
        guard
            let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr)
            else {
                // :TBD:ToBeLocalized: set initial default based on device language
                return true // imperial if unspecified
        }
        if currentUnitsType == .imperial {
            return true
        }
        return false
    }
    
    public static func convertKgToLbs(_ kg: Double) -> Double {
        let lbs = kg * 2.204623
        return lbs
    }
    
    public static func convertKgToLbs(_ string: String) -> String? {
        guard let kg = Double(string) else { return nil }
        let lbs = String(format: "%.1f", kg * 2.204623)
        return lbs
    }

    public static func convertLbsToKg(_ lbs: Double) -> Double {
        let kg = lbs / 2.204623
        return kg
    }

    public static func convertLbsToKg(_ string: String) -> String? {
        guard let lbs = Double(string) else { return nil }
        let kg = String(format: "%.1f", lbs / 2.204623)
        return kg
    }
    
}
