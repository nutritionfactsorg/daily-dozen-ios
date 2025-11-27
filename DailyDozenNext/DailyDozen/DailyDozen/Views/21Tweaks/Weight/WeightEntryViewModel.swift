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
    private var lastMockDBCount: Int = 0
    
    init() {
        loadTrackers()
    }
    
    func loadTrackers() {
        guard mockDB.count != lastMockDBCount else {
            return
        }
      //  print("mockDB before loadTrackers: \(mockDB.map { ($0.date.datestampSid, $0.weightAM.dataweight_kg, $0.weightPM.dataweight_kg) })")
        trackers = Dictionary(uniqueKeysWithValues: mockDB.map { ($0.date.datestampSid, $0) })
        lastMockDBCount = mockDB.count
    }
    
//    func tracker(for date: Date) -> SqlDailyTracker {
//        let dateSid = date.datestampSid
//        loadTrackers()
//        if let tracker = trackers[dateSid] {
//            print("Retrieved existing tracker for \(dateSid)")
//            return tracker
//        }
//        print("Created new tracker for \(dateSid)")
//        return SqlDailyTracker(date: date)
//    }
    func tracker(for date: Date) -> SqlDailyTracker {
            let calendar = Calendar.current
            return mockDB.first(where: { calendar.isDate($0.date, inSameDayAs: date.startOfDay) }) ?? SqlDailyTracker(date: date.startOfDay)
        }
    
    func saveWeight(for date: Date, amWeight: Double?, pmWeight: Double?, amTime: Date?, pmTime: Date?) {
        let dateSid = date.datestampSid
        var tracker = trackers[dateSid] ?? SqlDailyTracker(date: date)
        let unitType = UnitType.fromUserDefaults()
        
        print("Saving AM: \(String(describing: amWeight)), PM: \(String(describing: pmWeight)), Unit: \(unitType.rawValue), AM Time: \(amTime?.formatted(date: .omitted, time: .shortened) ?? "nil"), PM Time: \(pmTime?.formatted(date: .omitted, time: .shortened) ?? "nil")")
                
        var hasChanges = false
        if let amWeight = amWeight, let amTime = amTime, amWeight >= 0 {
            let kg = unitType == .imperial ? amWeight / 2.204623 : amWeight
            tracker.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: kg, timeHHmm: amTime.datestampHHmm)
            print("Set AM weight: \(kg) kg at \(amTime.datestampHHmm) (datetime: \(tracker.weightAM.datetime?.formatted(date: .omitted, time: .shortened) ?? "nil"))")
            hasChanges = true
        }
        if let pmWeight = pmWeight, let pmTime = pmTime, pmWeight >= 0 {
            let kg = unitType == .imperial ? pmWeight / 2.204623 : pmWeight
            tracker.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: kg, timeHHmm: pmTime.datestampHHmm)
            print("Set PM weight: \(kg) kg at \(pmTime.datestampHHmm) (datetime: \(tracker.weightPM.datetime?.formatted(date: .omitted, time: .shortened) ?? "nil"))")
            hasChanges = true
        }
        
        if hasChanges || trackers[dateSid] != nil {
            print("Tracker before update: AM \(tracker.weightAM.dataweight_kg), PM \(tracker.weightPM.dataweight_kg)")
            trackers[dateSid] = tracker
            print("Calling updateMockDB for \(dateSid)")
            updateMockDB(with: tracker)
           // print("mockDB after update: \(mockDB.map { ($0.date.datestampSid, $0.weightAM.dataweight_kg, $0.weightPM.dataweight_kg) })")
            print("Updated mockDB for \(dateSid): AM \(tracker.weightAM.dataweight_kg) kg at \(tracker.weightAM.dataweight_time), PM \(tracker.weightPM.dataweight_kg) kg at \(tracker.weightPM.dataweight_time)")
                   
           // print("Saved weights for \(dateSid): AM \(tracker.weightAM.dataweight_kg) kg, PM \(tracker.weightPM.dataweight_kg) kg")
        } else {
            print("No changes to save for \(dateSid)")
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
