//
//  UnitsType.swift
//  DailyDozen
//
//  Created by mc on 1/21/25.
//

import Foundation

/// Units System Type: imperial or metric
///
/// Related Localization Files:
/// * DozeDetailSizeUnitHeader
/// * Localizable.strings
/// * SettingsLayout
/// * TweakDetailActivityUnitHeader
enum UnitsType: String {
    
    case imperial
    case metric
    
    init?(_ str: String) {
        switch str {
        case "imperial", "[imperial]": self = .imperial
        case "metric", "[metric]": self = .metric
        default: return nil
        }
    }
    
    init?(mass: String) {
        switch mass {
        case "lbs", "[lbs]": self = .imperial
        case "kg", "[kg]": self = .metric
        default: return nil
        }
    }
    
    /// Returns localized name for the unit system currently in use.
    var title: String {
        switch self {
        case .imperial:
            return String(localized: "unitToggle.imperial", comment: "Units toggle button text: imperial measurement system")
        case .metric:
            return String(localized: "unitToggle.metric", comment: "Units toggle button text: metric measurement system")
        }
    }
    
    /// Returns toggled type for the current type.
    var toggledType: UnitsType {
        return self == .imperial ? UnitsType.metric : UnitsType.imperial
    }
}
