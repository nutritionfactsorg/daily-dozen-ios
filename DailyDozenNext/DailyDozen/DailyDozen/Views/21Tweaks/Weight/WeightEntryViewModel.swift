//
//  WeightEntryViewModel.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation
import SwiftUI

struct WeightEntryData {
    let amWeight: String
    let pmWeight: String
    let amTime: Date
    let pmTime: Date
}

// ViewModel to manage weight data and database operations   TBDz need to change name
extension Notification.Name {
    static let sqlDBUpdated = Notification.Name("sqlDBUpdated")
}

// :TBDz:  this might be a duplicate someplace -- verify
enum UnitType: String {
  case metric
  case imperial
   
   static func fromUserDefaults() -> UnitType {
       let registeredUnitType = UserDefaults.standard.string(forKey: "unitsTypePref") ?? "metric"
       return UnitType(rawValue: registeredUnitType) ?? .metric
   }
}
