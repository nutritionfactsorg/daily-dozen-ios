//
//  WeightEntryViewModel.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation
import SwiftUI
//TBDz:  think about this extension -- if needed?
// Modified initializer for SqlDataWeightRecord to allow time override
extension SqlDataWeightRecord {
    init(date: Date, weightType: DataWeightType, kg: Double, configure: (inout SqlDataWeightRecord) -> Void) {
        self.init(date: date, weightType: weightType, kg: kg)
        configure(&self)
    }
}

// ViewModel to manage weight data and database operations
class WeightEntryViewModel: ObservableObject {
    @Published var trackers: [String: SqlDailyTracker] = [:]
    
    init() {
        loadTrackers()
    }
    
    func loadTrackers() {
        trackers = Dictionary(uniqueKeysWithValues: mockDB.map { ($0.date.datestampSid, $0) })
    }
    
    func tracker(for date: Date) -> SqlDailyTracker {
        let dateSid = date.datestampSid
        if let tracker = trackers[dateSid] {
            return tracker
        }
        let newTracker = SqlDailyTracker(date: date)
        trackers[dateSid] = newTracker
        return newTracker
    }
    
    func saveWeight(for date: Date, amWeight: Double?, pmWeight: Double?, amTime: Date?, pmTime: Date?) {
            let dateSid = date.datestampSid
            var tracker = trackers[dateSid] ?? SqlDailyTracker(date: date)
            
            let unitType = UnitType.fromUserDefaults()
            
            if let amWeight = amWeight, amWeight > 0, let amTime = amTime {
                let kg = unitType == .imperial ? amWeight / 2.204623 : amWeight
                tracker.weightAM = SqlDataWeightRecord(
                    date: date,
                    weightType: .am,
                    kg: kg
                )
                tracker.weightAM.dataweight_time = amTime.datestampHHmm
            } else {
                tracker.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0)
            }
            
            if let pmWeight = pmWeight, pmWeight > 0, let pmTime = pmTime {
                let kg = unitType == .imperial ? pmWeight / 2.204623 : pmWeight
                tracker.weightPM = SqlDataWeightRecord(
                    date: date,
                    weightType: .pm,
                    kg: kg // Fix: Use converted kg
                )
                tracker.weightPM.dataweight_time = pmTime.datestampHHmm
            } else {
                tracker.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0)
            }
            
            trackers[dateSid] = tracker
            if let index = mockDB.firstIndex(where: { $0.date.datestampSid == dateSid }) {
                mockDB[index] = tracker
            } else {
                mockDB.append(tracker)
            }
        }
}

// Modified initializer for SqlDataWeightRecord to allow time override
//extension SqlDataWeightRecord {
//    init(date: Date, weightType: DataWeightType, kg: Double, configure: (inout SqlDataWeightRecord) -> Void) {
//        self.init(date: date, weightType: weightType, kg: kg)
//        configure(&self)
//    }
//}
 //TBDZ:  this might be a duplicate someplace -- verify
enum UnitType: String {
   case metric
   case imperial
    
    static func fromUserDefaults() -> UnitType {
        let registeredUnitType = UserDefaults.standard.string(forKey: "unitsTypePref") ?? "metric"
        return UnitType(rawValue: registeredUnitType) ?? .metric
    }
}
