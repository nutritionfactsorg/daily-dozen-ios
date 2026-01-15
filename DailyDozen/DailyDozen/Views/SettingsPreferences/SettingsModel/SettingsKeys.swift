//
//  SettingsKeys.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct SettingsKeys {
    // MARK: - UserDefaults keys
    
    //NYIz:  Need to add selectedTIme
    /// Reminder
    static let reminderCanNotify = "reminderCanNotify"
//    static let reminderHourPref = "reminderHourPref"
//    static let reminderMinutePref = "reminderMinutePref"
    static let reminderSoundPref = "reminderSoundPref"
    /// Units Type: imperial|metric
    static let unitsTypePref = "unitsTypePref"
    /// unitsTypeToggleShowPref: shows units type toggle button when true|"1"|"on"
    static let unitsTypeToggleShowPref = "unitsTypeToggleShowPref"
    /// Hide|Show 21 Tweaks
    static let show21TweaksPref = "show21TweaksPref"
    /// Used for first launch
    static let hasSeenLaunchV4 = "hasSeenLaunchV4"
    static let hasMigratedToSQLitev4 = "hasMigratedToSQLitev4"
    
    /// Analytics is enabled when when true|"1"|"on"
    static let analyticsIsEnabledPref = "analyticsIsEnabledPref"
    
    /// Light | Dark | Auto
    static let appearanceModePref = "appearanceModePref"
    /// Standard | Preview
    static let appearanceTypePref = "appearanceTypePref"
    
    /// Exercise Display Gamut: 1 x 45 minutes, 3 x 15 minutes, 6 x 8 minutes
    static let exerciseGamutPref = "exerciseGamutPref"
    /// Exercise Internal Gaumt: initially 1, later set to max 6
    static let exerciseGamutMaxUsed = "exerciseGamutMaxUsed"
    
    // MARK: - UNNotificationRequest identifiers
    
    /// Reminder UNNotificationRequest identifier
   static let reminderRequestID = "reminderRequestID"
    
   static let timeKeyPref = "timeKeyPref"
    
    // MARK: - Advanced Utilites helper
    
    static func allMyKeys() -> [String] {
        let myKeys = [
            reminderCanNotify,
            reminderSoundPref,
            unitsTypePref,
            unitsTypeToggleShowPref,
            show21TweaksPref,
            analyticsIsEnabledPref,
            appearanceModePref,
            appearanceTypePref,
            exerciseGamutPref,
            exerciseGamutMaxUsed,
            hasSeenLaunchV4,
            hasMigratedToSQLitev4,
            timeKeyPref
            // add any new ones here – the notification ID isn’t stored in defaults
        ]
        return myKeys
    }
    
    static func debugPrintMySettings() {
        let defaults = UserDefaults.standard
        let allMyKeys = allMyKeys()
        print("=== My App Settings Only ===")
        for key in allMyKeys {
            if let value = defaults.object(forKey: key) {
                print("\(key): \(value)  (\(type(of: value)))")
            } else {
                print("\(key): <not set>")
            }
        }
        print("==============================")
    }
    
    static func resetAllMySettings() {
        let defaults = UserDefaults.standard
        let keys = allMyKeys()
        
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        
        print("Reset all \(keys.count) of MY settings:")
        keys.forEach { print("  - \($0)") }
    }
}
