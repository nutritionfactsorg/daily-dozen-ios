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
    
    /// Daily count goal for exercises (i.e. number of checkboxes displayed)
    /// Exercise Display Gamut: 1 x 45 minutes, 3 x 15 minutes, 6 x 8 minutes
    enum ExerciseGamut: Int {
        /// one 40-45 minute exercise session
        case one = 1
        /// three 15-minute sessions
        case three = 3
        /// size 7-8 minute sessions
        case six = 6
        
        /// Defaults to legacy gamut
        static var `default`: ExerciseGamut {
            return .one
        }
        
        var int: Int {
            self.rawValue
        }
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
}
