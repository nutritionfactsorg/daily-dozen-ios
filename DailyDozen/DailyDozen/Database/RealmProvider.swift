//
//  RealmProvider.swift
//  DatabaseMigration
//
//  Created by marc on 2019.11.08.
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmDelegate: AnyObject {
    func didUpdateFile()
}

class RealmProvider {
    
    private struct Strings {
        static let realmFilename = "NutritionFacts.realm"
    }
    
    private let realm: Realm
    private var unsavedDailyTracker: DailyTracker?
    
    init() {
        let config = Realm.Configuration(
            // Local Realm file url
            fileURL: URL.inDocuments(for: Strings.realmFilename),
            objectTypes: [DataCountRecord.self, DataWeightRecord.self])
        guard let realm = try? Realm(configuration: config) else {
            fatalError("FAIL: could not instantiate RealmProvider.")
        }
        self.realm = realm
    }
    
    /// :REPLACES: initialDoze(Date) :TBD: no longer needed? 
    func initialDailyTracker(date: Date) -> DailyTracker {
        return DailyTracker(date: date)
    }
    
    func getDailyWeight(date: Date) -> (am: DataWeightRecord?, pm: DataWeightRecord?) {
        let datestampKey = date.datestampKey
        let amPid = "\(datestampKey).am"
        let pmPid = "\(datestampKey).pm"

        let amWeightRecord = realm.object(ofType: DataWeightRecord.self, forPrimaryKey: amPid)
        let pmWeightRecord = realm.object(ofType: DataWeightRecord.self, forPrimaryKey: pmPid)
        
        return (amWeightRecord, pmWeightRecord)
    }
    
    func getDailyWeights(fromDate: Date, toDate: Date) -> (am: [DataWeightRecord], pm: [DataWeightRecord]) {
        var amRecords = [DataWeightRecord]()
        var pmRecords = [DataWeightRecord]()
        let weightResults = realm.objects(DataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        let fromDateKey = fromDate.datestampKey
        let toDateKey = toDate.datestampKey
        
        for dataWeightRecord in weightResultsById {
            let pidKeys = dataWeightRecord.pidKeys
            if pidKeys.datestampKey >= fromDateKey &&
                pidKeys.datestampKey <= toDateKey {
                if pidKeys.typeKey == "am" {
                    amRecords.append(dataWeightRecord)
                } else {
                    pmRecords.append(dataWeightRecord)
                }
            }
        }
        
        return (amRecords, pmRecords)
    }
    
    func getDailyWeights() -> (am: [DataWeightRecord], pm: [DataWeightRecord]) {
        var amRecords = [DataWeightRecord]()
        var pmRecords = [DataWeightRecord]()
        let weightResults = realm.objects(DataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        for dataWeightRecord in weightResultsById {
            let pidKeys = dataWeightRecord.pidKeys
            if pidKeys.typeKey == "am" {
                amRecords.append(dataWeightRecord)
            } else {
                pmRecords.append(dataWeightRecord)
            }
        }
        
        return (amRecords, pmRecords)
    }
    
    /// :REPLACES: getDozeLegacy(Date)
    func getDailyTracker(date: Date) -> DailyTracker {
        let datestampKey = date.datestampKey
        
        var dailyTracker = DailyTracker(date: date)
        
        for dataCountType in DataCountType.allCases {
            let pid = DataCountRecord.pid(datestampKey: datestampKey, typeKey: dataCountType.typeKey)
            if let item = realm.object(ofType: DataCountRecord.self, forPrimaryKey: pid) {
                dailyTracker.itemsDict[dataCountType] = item
            } else {
                dailyTracker.itemsDict[dataCountType] = DataCountRecord(date: date, countType: dataCountType)
            }
        }
        
        unsavedDailyTracker = dailyTracker
        return dailyTracker
    }
    
    /// Note: minimal checked. Expects stored database values to be valid. Exists on first data error.
    func getDailyTrackers() -> [DailyTracker] {
        var allTrackers = [DailyTracker]()
        let counterResults = realm.objects(DataCountRecord.self)
        let counterResultsById = counterResults.sorted(byKeyPath: "pid")
        guard counterResultsById.count > 0 else {
            return allTrackers
        }
        
        let weightResults = realm.objects(DataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        let firstDataCountRecord = counterResultsById[0]
        guard var currentDate = firstDataCountRecord.pidParts?.datestamp else {
            return allTrackers
        }
        var currentDatestamp = currentDate.datestampKey
        var tracker = DailyTracker(date: currentDate)
        var weightIdx = 0
        for dataCountRecord in counterResultsById {
            let datestampKey = dataCountRecord.pidKeys.datestampKey
            if datestampKey != currentDatestamp {
                guard let nextDate = Date.init(datestampKey: datestampKey) else {
                    return allTrackers
                }
                
                // Process Weights: AM, PM
                while weightIdx < weightResultsById.count &&
                    weightResultsById[weightIdx].pidKeys.datestampKey == datestampKey {
                        let weight = weightResultsById[weightIdx]
                        if weight.pidKeys.typeKey == DataWeightType.am.typeKey {
                            tracker.weightAM = weight
                        } else {
                            tracker.weightPM = weight
                        }
                        weightIdx += 1
                }
                
                allTrackers.append(tracker)
                tracker = DailyTracker(date: nextDate)
                currentDate = nextDate
                currentDatestamp = nextDate.datestampKey
            }
            
            guard let countType = dataCountRecord.pidParts?.countType else {
                return allTrackers
            }
            tracker.itemsDict[countType] = dataCountRecord
        }
        allTrackers.append(tracker)
        
        return allTrackers
    }
    
    func saveCount(_ count: Int, date: Date, countType: DataCountType) {
        let id = DataCountRecord.pid(date: date, countType: countType)
        saveCount(count, pid: id)
    }
    
    func saveCount(_ count: Int, pid: String) {
        saveDailyTracker()
        do {
            try realm.write {
                realm.create(
                    DataCountRecord.self,
                    value: ["pid": pid, "count": count],
                    update: Realm.UpdatePolicy.all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveWeight(date: Date, weightType: DataWeightType, kg: Double) {
        // DataWeightRecord(date: date, weightType: weightType, kg: kg)
        guard kg > 0.0 else { return }
        let pid = "\(date.datestampKey).\(weightType.typeKey)"
        do {
            try realm.write {
                realm.create(
                    DataWeightRecord.self,
                    value: ["pid": pid, "kg": kg, "time": date.datestampHHmm],
                    update: Realm.UpdatePolicy.all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteWeight(date: Date, weightType: DataWeightType) {
        let pid = "\(date.datestampKey).\(weightType.typeKey)"
        if let record = realm.object(ofType: DataWeightRecord.self, forPrimaryKey: pid) {
            do {
                try realm.write {
                    realm.delete(record)                    
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateStreak(_ streak: Int, date: Date, countType: DataCountType) {
        let pid = DataCountRecord.pid(date: date, countType: countType)
        updateStreak(streak, pid: pid)
    }
    
    /// :!!!:NYI: updateStreak() needs to do more than a single value
    func updateStreak(_ streak: Int, pid: String) {
        saveDailyTracker()
        do {
            try realm.write {
                realm.create(
                    DataCountRecord.self, 
                    value: ["pid": pid, "streak": streak],
                    update: Realm.UpdatePolicy.all
                )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveDailyTracker() {
        guard let tracker = unsavedDailyTracker else {
            // print("saveDailyTracker() unsavedDailyTracker is nil")
            return
        }
        saveDailyTracker(tracker: tracker)
    }
    
    func saveDailyTracker(tracker: DailyTracker) {
        do {
            try realm.write {
                let trackerDict = tracker.itemsDict
                for key in trackerDict.keys {
                    realm.add(
                        trackerDict[key]!, // DataCountRecord
                        update: Realm.UpdatePolicy.all
                    )
                }
                unsavedDailyTracker = nil
            }                
        } catch {
            print(":ERROR: saveDailyTracker() failed tracker:\(tracker) description:\(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(":ERROR: deleteAll() failed description:\(error.localizedDescription)")
        }
    }
    
}
