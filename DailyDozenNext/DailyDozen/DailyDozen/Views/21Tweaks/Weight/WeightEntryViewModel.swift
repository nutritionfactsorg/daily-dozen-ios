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

//extension WeightEntryViewModel {
//    @MainActor
//    static func defaultViewModel() -> WeightEntryViewModel {
//        WeightEntryViewModel()
//    }
//}

// ViewModel to manage weight data and database operations
extension Notification.Name {
    static let mockDBUpdated = Notification.Name("mockDBUpdated")
}

@MainActor
class WeightEntryViewModel: ObservableObject {
    @Published var trackers: [String: SqlDailyTracker] = [:]
    @Published var pendingWeights: [String: PendingWeight] = [:]
    static let mockDBTrigger = NotificationCenter.Publisher(center: .default, name: .mockDBUpdated, object: nil)
       
    private var lastMockDBCount: Int = 0   //TBDz is this used?
    
    //Temp TBDZ just temp force unwrapped SqlDateWeightRecord  20250915
    
    
    
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
    
    @MainActor
    func saveWeight(for date: Date, amWeight: Double?, pmWeight: Double?, amTime: Date?, pmTime: Date?) {
        let dateSid = date.datestampSid
        var tracker = trackers[dateSid] ?? SqlDailyTracker(date: date)
        let unitType = UnitType.fromUserDefaults()
        
        print("Saving AM: \(String(describing: amWeight)), PM: \(String(describing: pmWeight)), Unit: \(unitType.rawValue), AM Time: \(amTime?.formatted(date: .omitted, time: .shortened) ?? "nil"), PM Time: \(pmTime?.formatted(date: .omitted, time: .shortened) ?? "nil")")
                
        var hasChanges = false
        if let amWeight = amWeight, let amTime = amTime, amWeight >= 0 {
            let kg = unitType == .imperial ? amWeight / 2.204623 : amWeight
            tracker.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: kg, timeHHmm: amTime.datestampHHmm)
//            print("Set AM weight: \(kg) kg at \(amTime.datestampHHmm) (datetime: \(tracker.weightAM.datetime?.formatted(date: .omitted, time: .shortened) ?? "nil"))")
            hasChanges = true
        }
        if let pmWeight = pmWeight, let pmTime = pmTime, pmWeight >= 0 {
            let kg = unitType == .imperial ? pmWeight / 2.204623 : pmWeight
            tracker.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: kg, timeHHmm: pmTime.datestampHHmm)
//            print("Set PM weight: \(kg) kg at \(pmTime.datestampHHmm) (datetime: \(tracker.weightPM.datetime?.formatted(date: .omitted, time: .shortened) ?? "nil"))")
            hasChanges = true
        }
        
        if hasChanges || trackers[dateSid] != nil {
//            print("Tracker before update: AM \(tracker.weightAM.dataweight_kg), PM \(tracker.weightPM.dataweight_kg)")
            trackers[dateSid] = tracker
            print("Calling updateMockDB for \(dateSid)")
            updateMockDB(with: tracker)
                       Task {
                           if tracker.weightAM!.dataweight_kg > 0 {
                               if let amTimeDate = Date(datestampHHmm: tracker.weightAM!.dataweight_time, referenceDate: date) {
                                   print("•Sync• Triggering syncWeightPut for AM: \(tracker.weightAM!.dataweight_kg) kg at \(amTimeDate.datestampyyyyMMddHHmmss)")
                                do {
                                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .am, kg: tracker.weightAM!.dataweight_kg, time: amTimeDate, tracker: tracker)
                                    print("•Sync• AM sync completed")
                                } catch {
                                    print("•Sync• AM sync error: \(error.localizedDescription)")
                                }
                            } else {
                                print("•Date• AM time parsing failed: \(tracker.weightAM!.dataweight_time)")
                            }
                        } else {
                            print("•Sync• Skipping AM sync: weight is \(tracker.weightAM!.dataweight_kg)")
                        }
                           if tracker.weightPM!.dataweight_kg > 0 {
                               if let pmTimeDate = Date(datestampHHmm: tracker.weightPM!.dataweight_time, referenceDate: date) {
                                   print("•Sync• Triggering syncWeightPut for PM: \(tracker.weightPM!.dataweight_kg) kg at \(pmTimeDate.datestampyyyyMMddHHmmss)")
                                do {
                                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .pm, kg: tracker.weightPM!.dataweight_kg, time: pmTimeDate, tracker: tracker)
                                    print("•Sync• PM sync completed")
                                } catch {
                                    print("•Sync• PM sync error: \(error.localizedDescription)")
                                }
                            } else {
                                print("•Date• PM time parsing failed: \(tracker.weightPM!.dataweight_time)")
                            }
                        } else {
//                            print("•Sync• Skipping PM sync: weight is \(tracker.weightPM.dataweight_kg)")
                            print("Temp")
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
                   saveWeight( // Changed: Added await for async call
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
            NotificationCenter.default.post(name: .mockDBUpdated, object: nil)
        }
  
    @MainActor
    func loadWeights(for date: Date, unitType: UnitType) async -> WeightEntryData {
        let key = date.datestampSid
        var tracker = tracker(for: date)
        var hasChanges = false
        
        if tracker.weightAM!.dataweight_kg == 0 {
            let (amTimeStr, amWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .am)
            if !amWeightStr.isEmpty, let kg = Double(amWeightStr) {
                tracker.weightAM = SqlDataWeightRecord(
                    date: date,
                    weightType: .am,
                    kg: unitType == .metric ? kg : kg / 2.204623,
                    timeHHmm: amTimeStr
                )
                hasChanges = true
                print("•Load• Updated AM weight from HealthKit: \(kg) kg for \(key)")
            } else {
                print("•Load• No AM weight data for \(key)")
            }
        }
        if tracker.weightPM!.dataweight_kg == 0 {
            let (pmTimeStr, pmWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .pm)
            if !pmWeightStr.isEmpty, let kg = Double(pmWeightStr) {
                tracker.weightPM = SqlDataWeightRecord(
                    date: date,
                    weightType: .pm,
                    kg: unitType == .metric ? kg : kg / 2.204623,
                    timeHHmm: pmTimeStr
                )
                hasChanges = true
                print("•Load• Updated PM weight from HealthKit: \(kg) kg for \(key)")
            } else {
                print("•Load• No PM weight data for \(key)")
            }
        }
        
        // Save to mockDB if there are changes and non-zero weights or itemsDict data
        if hasChanges && (tracker.weightAM!.dataweight_kg > 0 || tracker.weightPM!.dataweight_kg > 0 || !tracker.itemsDict.isEmpty) {
            trackers[key] = tracker
            updateMockDB(with: tracker) // Use existing global function
            print("•Load• Persisted tracker to mockDB for \(key)")
        }
        
        let amRecord = tracker.weightAM
        let pmRecord = tracker.weightPM
        
        let amWeight = amRecord!.dataweight_kg > 0 ?
            UnitsUtility.regionalWeight(
                fromKg: amRecord!.dataweight_kg,
                toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric,
                toDecimalDigits: 1
            ) ?? "" : ""
        let pmWeight = pmRecord!.dataweight_kg > 0 ?
            UnitsUtility.regionalWeight(
                fromKg: pmRecord!.dataweight_kg,
                toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric,
                toDecimalDigits: 1
            ) ?? "" : ""
        
        let amTime = amRecord!.dataweight_time.isEmpty ? Date() :
        Date(datestampHHmm: amRecord!.dataweight_time, referenceDate: date) ?? Date()
        let pmTime = pmRecord!.dataweight_time.isEmpty ? Date() :
        Date(datestampHHmm: pmRecord!.dataweight_time, referenceDate: date) ?? Date()
        
        print("Loaded weights for \(date.datestampSid): AM \(amWeight), PM \(pmWeight), AM Time \(amTime.datestampHHmm), PM Time \(pmTime.datestampHHmm)")
        return WeightEntryData(amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
    }

    @MainActor
    func updatePendingWeights(for date: Date, amWeight: String, pmWeight: String, amTime: Date, pmTime: Date) async {
            
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
