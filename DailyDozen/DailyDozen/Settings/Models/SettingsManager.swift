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

    public static func unitsType() -> UnitsType {
        guard
            let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr)
        else {
            return .imperial // default if not specified in preferences
        }
        return currentUnitsType
    }
        
}
