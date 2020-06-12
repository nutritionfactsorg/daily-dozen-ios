//
//  RealmProvider.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import Foundation
import RealmSwift

protocol RealmDelegate: AnyObject {
    func didUpdateFile()
}

class RealmProvider {
    
    public static let realmFilename = "NutritionFacts.realm"
    
    private let realm: Realm
    private var unsavedDailyTracker: DailyTracker?
    
    /// Default current local Realm at Library/Database/defaultName
    convenience init() {
        let fileURL: URL = URL.inDatabase(filename: RealmProvider.realmFilename)
        self.init(fileURL: fileURL)
    }
    
    /// Prefer `init()` for default current local Realm.
    /// Use `init(fileURL: URL)` to access a local Realm which _is not the current local default_.
    init(fileURL: URL) {
        let config = Realm.Configuration(
            fileURL: fileURL,   // local Realm file url
            objectTypes: [DataCountRecord.self, DataWeightRecord.self])
        Realm.Configuration.defaultConfiguration = config
        guard let realm = try? Realm() else {
            fatalError("FAIL: could not instantiate RealmProvider.")
        }
        self.realm = realm
    }
    
    func initialDailyTracker(date: Date) -> DailyTracker {
        return DailyTracker(date: date)
    }
    
    /// Use: weight entry
    func getDBWeight(date: Date, ampm: DataWeightType) -> DataWeightRecord? {
        let datestampKey = date.datestampKey
        let pid = ampm == .am ? "\(datestampKey).am" : "\(datestampKey).pm"
        
        let weightRecord = realm.object(ofType: DataWeightRecord.self, forPrimaryKey: pid)
        return weightRecord
    }
    
    // Use: datetime list to sync with HealthKit
    func getDBWeightDatetimes() -> Results<DataWeightRecord> {
        return realm.objects(DataWeightRecord.self)
    }
    
    /// Use: TBD
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
    
    /// Use: history view
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
    
    /// Use: weight export
    func getDailyWeightsArray() -> [DataWeightRecord] {
        var records = [DataWeightRecord]()
        let weightResults = realm.objects(DataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        for dataWeightRecord in weightResultsById {
            records.append(dataWeightRecord)
        }
        
        return records
    }
    
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
        // Daily Dozen & Tweaks Counters
        let counterResultsById = realm.objects(DataCountRecord.self)
            .sorted(byKeyPath: "pid")
        
        // Weight History
        let weightResultsById = realm.objects(DataWeightRecord.self)
            .sorted(byKeyPath: "pid")
        
        if counterResultsById.count > 0 && weightResultsById.count > 0 {
            return getDailyTrackersMerged(counterResults: counterResultsById, weightResults: weightResultsById)
        } else if counterResultsById.count > 0 {
            return getDailyTrackersCountersOnly(counterResults: counterResultsById)
        } else if weightResultsById.count > 0 {
            return getDailyTrackersWeightOnly(weightResults: weightResultsById)
        } else {
            return [DailyTracker]()
        }
    }
    
    /// Merges counts and weights in to single [DailyTracker] array
    private func getDailyTrackersMerged(counterResults: Results<DataCountRecord>, weightResults: Results<DataWeightRecord>) -> [DailyTracker] {
        var allTrackers = [DailyTracker]()
        
        let counterResults = counterResults.sorted(byKeyPath: "pid")
        let weightResults = weightResults.sorted(byKeyPath: "pid")
        
        var thisCounterRecord: DataCountRecord = counterResults[0]
        var thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey // yyyyMMdd
        guard let thisCounterDate = Date(datestampKey: thisCounterDatestamp) else { return allTrackers }
        
        var thisWeightRecord: DataWeightRecord = weightResults[0]
        var thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey // yyyyMMdd
        guard let thisWeightDate = Date(datestampKey: thisWeightDatestamp) else { return allTrackers }
        
        var counterIndex = 0
        var weightIndex = 0
        var lastDatestamp = thisCounterDatestamp 
        var tracker = DailyTracker(date: thisCounterDate)
        
        if thisCounterDatestamp > thisWeightDatestamp { 
            // start with earliest datestamp
            lastDatestamp = thisWeightDatestamp
            tracker = DailyTracker(date: thisWeightDate)
        }
        while counterIndex < counterResults.count && weightIndex < weightResults.count {
            thisCounterRecord = counterResults[counterIndex]
            thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey
            thisWeightRecord = weightResults[weightIndex]
            thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey
            
            if thisCounterDatestamp == lastDatestamp {
                guard let countType = thisCounterRecord.pidParts?.countType else { return allTrackers }
                tracker.itemsDict[countType] = thisCounterRecord
                counterIndex += 1
            } else if thisWeightDatestamp == lastDatestamp {
                if thisWeightRecord.pidKeys.typeKey == DataWeightType.am.typeKey {
                    tracker.weightAM = thisWeightRecord
                } else {
                    tracker.weightPM = thisWeightRecord
                }      
                weightIndex += 1
            } else {
                allTrackers.append(tracker)
                // take the earlier of CounterDatestamp or WeightDatestamp
                if thisCounterDatestamp <= thisWeightDatestamp {
                    lastDatestamp = thisCounterDatestamp 
                    if let date = Date(datestampKey: thisCounterDatestamp) {
                        tracker = DailyTracker(date: date)    
                    } else { return allTrackers } // early fail if datestamp invalid
                } else {
                    lastDatestamp = thisWeightDatestamp 
                    if let date = Date(datestampKey: thisWeightDatestamp) {
                        tracker = DailyTracker(date: date)
                    } else { return allTrackers } // early fail if datestamp invalid 
                }
            }
        }
        
        // Append remaining counters
        if counterIndex < counterResults.count {
            while counterIndex < counterResults.count {
                thisCounterRecord = counterResults[counterIndex]
                thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey
                
                if thisCounterDatestamp > lastDatestamp {
                    allTrackers.append(tracker)
                    if let date = Date(datestampKey: thisCounterDatestamp) {
                        tracker = DailyTracker(date: date)    
                    } else { return allTrackers } // early fail if datestamp invalid
                }
                guard let countType = thisCounterRecord.pidParts?.countType else { return allTrackers }
                tracker.itemsDict[countType] = thisCounterRecord
                
                counterIndex += 1
                lastDatestamp = thisCounterDatestamp
            }
        }
            // Append remaining weight records
        else if weightIndex < weightResults.count {
            while weightIndex < weightResults.count {
                thisWeightRecord = weightResults[weightIndex]
                thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey
                
                if thisWeightDatestamp > lastDatestamp {
                    allTrackers.append(tracker)
                    if let date = Date(datestampKey: thisWeightDatestamp) {
                        tracker = DailyTracker(date: date)    
                    } else { return allTrackers } // early fail if datestamp invalid
                }
                if thisWeightRecord.pidKeys.typeKey == DataWeightType.am.typeKey {
                    tracker.weightAM = thisWeightRecord
                } else {
                    tracker.weightPM = thisWeightRecord
                }
                
                weightIndex += 1
                lastDatestamp = thisWeightDatestamp
            }
        }
        
        allTrackers.append(tracker)
        
        return allTrackers
    }
    
    /// requires presort from lower to higher datestamps
    private func getDailyTrackersCountersOnly(counterResults: Results<DataCountRecord>) -> [DailyTracker] {
        var allTrackers = [DailyTracker]()
        
        var thisCounterRecord: DataCountRecord = counterResults[0]
        var thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey
        guard let thisDate = Date(datestampKey: thisCounterDatestamp) else { return allTrackers }
        
        var counterIndex = 0
        var lastDatestamp = thisCounterDatestamp
        var tracker = DailyTracker(date: thisDate)
        while counterIndex < counterResults.count {
            thisCounterRecord = counterResults[counterIndex]
            thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey
            
            if thisCounterDatestamp > lastDatestamp {
                allTrackers.append(tracker)
                if let date = Date(datestampKey: thisCounterDatestamp) {
                    tracker = DailyTracker(date: date)    
                } else { return allTrackers } // early fail if datestamp invalid
            }
            guard let countType = thisCounterRecord.pidParts?.countType else { return allTrackers }
            tracker.itemsDict[countType] = thisCounterRecord
            
            counterIndex += 1
            lastDatestamp = thisCounterDatestamp
        }
        allTrackers.append(tracker)
        
        return allTrackers
    }
    
    /// requires presort from lower to higher datestamps
    private func getDailyTrackersWeightOnly(weightResults: Results<DataWeightRecord>) -> [DailyTracker] {
        var allTrackers = [DailyTracker]()
        
        var thisWeightRecord: DataWeightRecord = weightResults[0]
        var thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey
        guard let thisDate = Date(datestampKey: thisWeightDatestamp) else { return allTrackers }
        
        var weightIndex = 0
        var lastDatestamp = thisWeightDatestamp
        var tracker = DailyTracker(date: thisDate)
        while weightIndex < weightResults.count {
            thisWeightRecord = weightResults[weightIndex]
            thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey
            
            if thisWeightDatestamp > lastDatestamp {
                allTrackers.append(tracker)
                if let date = Date(datestampKey: thisWeightDatestamp) {
                    tracker = DailyTracker(date: date)    
                } else { return allTrackers } // early fail if datestamp invalid
            }
            if thisWeightRecord.pidKeys.typeKey == DataWeightType.am.typeKey {
                tracker.weightAM = thisWeightRecord
            } else {
                tracker.weightPM = thisWeightRecord
            }                
            
            weightIndex += 1
            lastDatestamp = thisWeightDatestamp
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
            LogService.shared.error(
                "RealmProvider saveCount \(error.localizedDescription)"
            )
        }
    }
    
    func saveDBWeight(date: Date, ampm: DataWeightType, kg: Double) {
        // DataWeightRecord(date: date, weightType: weightType, kg: kg)
        guard kg > 0.0 else { return }
        let pid = "\(date.datestampKey).\(ampm.typeKey)"
        do {
            try realm.write {
                realm.create(
                    DataWeightRecord.self,
                    value: ["pid": pid, "kg": kg, "time": date.datestampHHmm],
                    update: Realm.UpdatePolicy.all)
            }
        } catch {
            LogService.shared.error(
                "RealmProvider saveDBWeight \(error.localizedDescription)"
            )
        }
    }
    
    func deleteDBWeight(date: Date, ampm: DataWeightType) {
        let pid = "\(date.datestampKey).\(ampm.typeKey)"
        if let record = realm.object(ofType: DataWeightRecord.self, forPrimaryKey: pid) {
            do {
                try realm.write {
                    realm.delete(record)
                }
            } catch {
                LogService.shared.error(
                    "RealmProvider deleteWeight \(error.localizedDescription)"
                )
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
            LogService.shared.error(
                "RealmProvider updateStreak \(error.localizedDescription)"
            )
        }
    }
    
    func saveDailyTracker() {
        guard let tracker = unsavedDailyTracker else {
            //LogService.shared.debug(
            //    "RealmProvider saveDailyTracker unsavedDailyTracker is nil"
            //)
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
            LogService.shared.error(
                "FAIL RealmProvider saveDailyTracker() tracker:\(tracker) description:\(error.localizedDescription)"
            )
        }
    }
    
    func deleteDBAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            LogService.shared.error(
                "FAIL RealmProvider deleteDBAll() description:\(error.localizedDescription)"
            )
        }
    }
    
}
