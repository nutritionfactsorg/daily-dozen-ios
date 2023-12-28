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
    
    /// Daily count for exercises (number of checkboxes)
    /// Exercise Display Gamut: 1 x 45 minutes, 3 x 15 minutes, 6 x 8 minutes
    public static func exerciseGamut() -> ExerciseGamut {
        let exerciseGamutPrefInt = UserDefaults.standard.integer(forKey: SettingsKeys.exerciseGamutPref)
        guard let currentGamut = ExerciseGamut(rawValue: exerciseGamutPrefInt)
        else {
            return ExerciseGamut.default // default if not specified in preferences
        }
        return currentGamut
    }

    /// Daily count for exercises (number of checkboxes)
    /// Exercise Display Gamut: 1 x 45 minutes, 3 x 15 minutes, 6 x 8 minutes
    public static func exerciseGamutInt() -> Int {
        return exerciseGamut().int
    }
    
    /// Daily count for exercises (number of checkboxes)
    /// Exercise Display Gamut: 1 x 45 minutes, 3 x 15 minutes, 6 x 8 minutes
    /// Highest gamut every set in user preferences
    public static func exerciseGamutMaxUsed() -> ExerciseGamut {
        let exerciseGamutMaxUsedInt = UserDefaults.standard.integer(forKey: SettingsKeys.exerciseGamutMaxUsed)
        guard let maxGamut = ExerciseGamut(rawValue: exerciseGamutMaxUsedInt)
        else {
            return ExerciseGamut.default // default if not specified in preferences
        }
        return maxGamut
    }

    /// Daily count for exercises (number of checkboxes)
    /// Exercise Display Gamut: 1 x 45 minutes, 3 x 15 minutes, 6 x 8 minutes
    /// Highest gamut every set in user preferences
    public static func exerciseGamutMaxUsedInt() -> Int {
        return exerciseGamutMaxUsed().int
    }
}
