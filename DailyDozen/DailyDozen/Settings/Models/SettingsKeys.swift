//
//  SettingsKeys.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

/// 
struct SettingsKeys {
    // MARK: - UserDefaults keys
    
    /// Reminder
    static let reminderCanNotify = "reminderCanNotify"
    static let reminderHourPref = "reminderHourPref"
    static let reminderMinutePref = "reminderMinutePref"
    static let reminderSoundPref = "reminderSoundPref"
    /// Units Type: imperial|metric
    static let unitsTypePref = "unitsTypePref"
    /// unitsTypeToggleShowPref: shows units type toggle button when true|"1"|"on"
    static let unitsTypeToggleShowPref = "unitsTypeToggleShowPref"
    /// Hide|Show 21 Tweaks
    static let show21TweaksPref = "show21TweaksPref"
    /// Used for first launch
    static let hasSeenFirstLaunch = "hasSeenFirstLaunch_v3.1.0"
    
    /// Analytics is enabled when when true|"1"|"on"
    static let analyticsIsEnabledPref = "analyticsIsEnabledPref"
    
    /// Light | Dark | Auto
    static let appearanceModePref = "appearanceModePref"
    /// Standard | Preview
    static let appearanceTypePref = "appearanceTypePref"
    
    /// Exercise Display Gamut: 1 x 45 minutes, 3 x 15 minutes, 6 x 8 minutes
    static let exerciseGamutPref = "exerciseGamutPref"
    static let exerciseGamutMaxUsed = "exerciseGamutMaxUsed"
    
    // MARK: - UNNotificationRequest identifiers
    
    /// Reminder UNNotificationRequest identifier
    static let reminderRequestID = "reminderRequestID"
    
    ///
}
