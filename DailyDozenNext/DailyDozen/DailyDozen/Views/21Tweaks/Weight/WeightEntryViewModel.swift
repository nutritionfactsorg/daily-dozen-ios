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
    @Published var pendingWeights: [String: PendingWeight] = [:]
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
                       Task {
                        if tracker.weightAM.dataweight_kg > 0 {
                            if let amTimeDate = Date(datestampHHmm: tracker.weightAM.dataweight_time, referenceDate: date) {
                                print("•Sync• Triggering syncWeightPut for AM: \(tracker.weightAM.dataweight_kg) kg at \(amTimeDate.datestampyyyyMMddHHmmss)")
                                do {
                                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .am, kg: tracker.weightAM.dataweight_kg, time: amTimeDate)
                                    print("•Sync• AM sync completed")
                                } catch {
                                    print("•Sync• AM sync error: \(error.localizedDescription)")
                                }
                            } else {
                                print("•Date• AM time parsing failed: \(tracker.weightAM.dataweight_time)")
                            }
                        } else {
                            print("•Sync• Skipping AM sync: weight is \(tracker.weightAM.dataweight_kg)")
                        }
                        if tracker.weightPM.dataweight_kg > 0 {
                            if let pmTimeDate = Date(datestampHHmm: tracker.weightPM.dataweight_time, referenceDate: date) {
                                print("•Sync• Triggering syncWeightPut for PM: \(tracker.weightPM.dataweight_kg) kg at \(pmTimeDate.datestampyyyyMMddHHmmss)")
                                do {
                                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .pm, kg: tracker.weightPM.dataweight_kg, time: pmTimeDate)
                                    print("•Sync• PM sync completed")
                                } catch {
                                    print("•Sync• PM sync error: \(error.localizedDescription)")
                                }
                            } else {
                                print("•Date• PM time parsing failed: \(tracker.weightPM.dataweight_time)")
                            }
                        } else {
                            print("•Sync• Skipping PM sync: weight is \(tracker.weightPM.dataweight_kg)")
                        }
                    }
                } else {
                    print("•Save• No changes to save for \(dateSid)")
                }
    }
    
    //TBDz:  determine if saving only to one decimal?  I think not?
    @MainActor
    func savePendingWeights() async {
            print("savePendingWeights called with: \(pendingWeights.map { ($0.key, $0.value.amWeight, $0.value.pmWeight) })")
            for (dateSid, weights) in pendingWeights {
                let amValue = Double(weights.amWeight.filter { !$0.isWhitespace })
                let pmValue = Double(weights.pmWeight.filter { !$0.isWhitespace })
                print("Processing \(dateSid): AM \(String(describing: amValue)), PM \(String(describing: pmValue))")
                if amValue != nil || pmValue != nil {
                    guard let date = Date(datestampSid: dateSid) else {
                        print("Invalid dateSid: \(dateSid), skipping save")
                        continue
                    }
                   saveWeight( // 🟢 Changed: Added await for async call
                        for: date,
                        amWeight: amValue.flatMap { Double($0) },
                        pmWeight: pmValue.flatMap { Double($0) },
                        amTime: weights.amTime,
                        pmTime: weights.pmTime
                    )
                    print("Called saveWeight for \(dateSid)")
                } else {
                    print("No valid weights for \(dateSid), skipping")
                }
            }
            pendingWeights.removeAll() // 🟢 Changed: @Published update on main thread
            print("Cleared pendingWeights after save")
        }
    
    func loadWeights(for date: Date, unitType: UnitType) async -> WeightEntryData { // 🟢 Changed: Return WeightEntryData
        let tracker = tracker(for: date)
        let unitType = UnitType.fromUserDefaults()
       
        let amWeight = tracker.weightAM.dataweight_kg > 0 ?
        UnitsUtility.regionalWeight(
            fromKg: tracker.weightAM.dataweight_kg,
            toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric,
            toDecimalDigits: 1
        ) ?? "" : ""
        let pmWeight = tracker.weightPM.dataweight_kg > 0 ?
        UnitsUtility.regionalWeight(
            fromKg: tracker.weightPM.dataweight_kg,
            toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric,
            toDecimalDigits: 1
        ) ?? "" : ""
        
        // Parse time with reference date
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let amTime: Date
        if tracker.weightAM.dataweight_time.isEmpty {
            amTime = Date()
        } else if let timeDate = Date(datestampHHmm: tracker.weightAM.dataweight_time, referenceDate: date) {
            amTime = timeDate
        } else {
            amTime = Date()
            print("Failed to parse AM time: \(tracker.weightAM.dataweight_time)")
        }
        
        let pmTime: Date
        if tracker.weightPM.dataweight_time.isEmpty {
            pmTime = Date()
        } else if let timeDate = Date(datestampHHmm: tracker.weightPM.dataweight_time, referenceDate: date) {
            pmTime = timeDate
        } else {
            pmTime = Date()
            print("Failed to parse PM time: \(tracker.weightPM.dataweight_time)")
        }
        
        // 🟢 Changed: Load from HealthKit if mockDB is empty
        let finalAmWeight: String
        let finalAmTime: Date
        if amWeight.isEmpty {
            let (amTimeStr, amWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .am)
            finalAmWeight = amWeightStr
            finalAmTime = Date(datestampHHmm: amTimeStr, referenceDate: date) ?? amTime
        } else {
            finalAmWeight = amWeight
            finalAmTime = amTime
        }
        
        let finalPmWeight: String
        let finalPmTime: Date
        if pmWeight.isEmpty {
            let (pmTimeStr, pmWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .pm)
            finalPmWeight = pmWeightStr
            finalPmTime = Date(datestampHHmm: pmTimeStr, referenceDate: date) ?? pmTime
        } else {
            finalPmWeight = pmWeight
            finalPmTime = pmTime
        }
        
        print("Loaded weights for \(date.datestampSid): AM \(finalAmWeight), PM \(finalPmWeight), AM Time \(finalAmTime.formatted(date: .omitted, time: .shortened)), PM Time \(finalPmTime.formatted(date: .omitted, time: .shortened))")
        return WeightEntryData(amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
    }
        
        func updatePendingWeights(for date: Date, amWeight: String, pmWeight: String, amTime: Date, pmTime: Date) {
            
            if !amWeight.isEmpty || !pmWeight.isEmpty {
                pendingWeights[date.datestampSid] = PendingWeight(
                    amWeight: amWeight,
                    pmWeight: pmWeight,
                    amTime: amTime,
                    pmTime: pmTime
                )
                //            print("Updated pending weights for \(date.datestampSid): AM \(amWeight), PM \(pmWeight)")
            } else {
                pendingWeights.removeValue(forKey: date.datestampSid)
            }
        }
    }

 //TBDZ:  this might be a duplicate someplace -- verify
enum UnitType: String {
   case metric
   case imperial
    
    static func fromUserDefaults() -> UnitType {
        let registeredUnitType = UserDefaults.standard.string(forKey: "unitsTypePref") ?? "metric"
        return UnitType(rawValue: registeredUnitType) ?? .metric
    }
}
