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
    // Current Default Database
    static var primary = RealmProvider()
    //
    public static let realmFilename = "NutritionFacts.realm"
    public static let realmFilenameScratch = "NutritionFacts.scratch.realm"
    public static func realmFilenameNowstamp() -> String {
        return "NutritionFacts.\(Date.datestampNow()).realm"
    }
    public static func realmBackupList() -> [String] {
        var filenameList: [String] = []
        let fm = FileManager.default
        
        let keys: [URLResourceKey] = [.isRegularFileKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        
        do {
            let contentUrls = try fm.contentsOfDirectory(
                at: URL.inDatabase(), 
                includingPropertiesForKeys: keys, 
                options: options)
            for url in contentUrls {
                // 'Regex' is only available in iOS 16.0 or newer
                // 'contains: Regex' is only available in iOS 16.0 or newer
                let regex = "^NutritionFacts.[_0-9]+.realm$"
                let filename = url.lastPathComponent
                if filename.regexMatch(pattern: regex) {
                    filenameList.append(filename)
                }
            }
        } catch {
            LogService.shared.error(
                "RealmProvider realmBackupList \(error.localizedDescription)"
            )
        }
        
        return filenameList.sorted()
    }
    
    private var realm: Realm
    private var unsavedDailyTracker: RealmDailyTracker?
    
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
            objectTypes: [RealmDataCountRecord.self, RealmDataWeightRecord.self])
        Realm.Configuration.defaultConfiguration = config
        guard let realm = try? Realm() else {
            fatalError("FAIL: could not instantiate RealmProvider.")
        }
        self.realm = realm
    }
    
    static func initialize(fileURL: URL) {
        //Realm.Configuration(
        //    fileURL: <#T##URL?#>, 
        //    inMemoryIdentifier: <#T##String?#>, 
        //    syncConfiguration: <#T##SyncConfiguration?#>, 
        //    encryptionKey: <#T##Data?#>, 
        //    readOnly: <#T##Bool#>, 
        //    schemaVersion: <#T##UInt64#>, 
        //    migrationBlock: <#T##MigrationBlock?##MigrationBlock?##(_ migration: Migration, _ oldSchemaVersion: UInt64) -> Void#>, 
        //    deleteRealmIfMigrationNeeded: <#T##Bool#>, 
        //    shouldCompactOnLaunch: <#T##((Int, Int) -> Bool)?##((Int, Int) -> Bool)?##(Int, Int) -> Bool#>, 
        //    objectTypes: <#T##[Object.Type]?#>)
        
        let config = Realm.Configuration(
            fileURL: fileURL,   // local Realm file url
            objectTypes: [RealmDataCountRecord.self, RealmDataWeightRecord.self])
        Realm.Configuration.defaultConfiguration = config
        guard let realm = try? Realm() else {
            fatalError("FAIL: could not instantiate RealmProvider.")
        }
        RealmProvider.primary.realm = realm
        //Realm.invalidate(<#T##self: Realm##Realm#>)
        _ = Realm.refresh(RealmProvider.primary.realm)
    }
    
    func initialDailyTracker(date: Date) -> RealmDailyTracker {
        return RealmDailyTracker(date: date)
    }
    
    /// Use: weight entry
    func getDBWeight(date: Date, ampm: DataWeightType) -> RealmDataWeightRecord? {
        let datestampKey = date.datestampKey
        let pid = ampm == .am ? "\(datestampKey).am" : "\(datestampKey).pm"
        
        let weightRecord = realm.object(ofType: RealmDataWeightRecord.self, forPrimaryKey: pid)
        return weightRecord
    }
    
    // Use: datetime list to sync with HealthKit
    func getDBWeightDatetimes() -> Results<RealmDataWeightRecord> {
        return realm.objects(RealmDataWeightRecord.self)
    }
    
    /// Use: TBD
    func getDailyWeights(fromDate: Date, toDate: Date) -> (am: [RealmDataWeightRecord], pm: [RealmDataWeightRecord]) {
        var amRecords = [RealmDataWeightRecord]()
        var pmRecords = [RealmDataWeightRecord]()
        let weightResults = realm.objects(RealmDataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        let fromDateKey = fromDate.datestampKey
        let toDateKey = toDate.datestampKey
        
        for realmDataWeightRecord in weightResultsById {
            let pidKeys = realmDataWeightRecord.pidKeys
            if pidKeys.datestampKey >= fromDateKey &&
                pidKeys.datestampKey <= toDateKey {
                if pidKeys.typeKey == "am" {
                    amRecords.append(realmDataWeightRecord)
                } else {
                    pmRecords.append(realmDataWeightRecord)
                }
            }
        }
        
        return (amRecords, pmRecords)
    }
    
    /// Use: history view
    func getDailyWeights() -> (am: [RealmDataWeightRecord], pm: [RealmDataWeightRecord]) {
        var amRecords = [RealmDataWeightRecord]()
        var pmRecords = [RealmDataWeightRecord]()
        let weightResults = realm.objects(RealmDataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        for realmDataWeightRecord in weightResultsById {
            let pidKeys = realmDataWeightRecord.pidKeys
            if pidKeys.typeKey == "am" {
                amRecords.append(realmDataWeightRecord)
            } else {
                pmRecords.append(realmDataWeightRecord)
            }
        }
        
        return (amRecords, pmRecords)
    }
    
    /// Use: weight export
    func getDailyWeightsArray() -> [RealmDataWeightRecord] {
        var records = [RealmDataWeightRecord]()
        let weightResults = realm.objects(RealmDataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        for realmDataWeightRecord in weightResultsById {
            records.append(realmDataWeightRecord)
        }
        
        return records
    }
    
    func getDailyTracker(date: Date) -> RealmDailyTracker {
        let datestampKey = date.datestampKey
        
        var dailyTracker = RealmDailyTracker(date: date)
        
        for dataCountType in DataCountType.allCases {
            let pid = RealmDataCountRecord.pid(datestampKey: datestampKey, typeKey: dataCountType.typeKey)
            if let item = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: pid) {
                dailyTracker.itemsDict[dataCountType] = item
            } else {
                dailyTracker.itemsDict[dataCountType] = RealmDataCountRecord(date: date, countType: dataCountType)
            }
        }
        
        unsavedDailyTracker = dailyTracker
        return dailyTracker
    }
    
    /// Note: minimal checked. Expects stored database values to be valid. Exists on first data error.
    func getDailyTrackers() -> [RealmDailyTracker] {        
        // Daily Dozen & Tweaks Counters
        let counterResultsById = realm.objects(RealmDataCountRecord.self)
            .sorted(byKeyPath: "pid")
        
        // Weight History
        let weightResultsById = realm.objects(RealmDataWeightRecord.self)
            .sorted(byKeyPath: "pid")
        
        if counterResultsById.count > 0 && weightResultsById.count > 0 {
            return getDailyTrackersMerged(counterResults: counterResultsById, weightResults: weightResultsById)
        } else if counterResultsById.count > 0 {
            return getDailyTrackersCountersOnly(counterResults: counterResultsById)
        } else if weightResultsById.count > 0 {
            return getDailyTrackersWeightOnly(weightResults: weightResultsById)
        } else {
            return [RealmDailyTracker]()
        }
    }
    
    /// Merges counts and weights in to single [DailyTracker] array
    private func getDailyTrackersMerged(counterResults: Results<RealmDataCountRecord>, weightResults: Results<RealmDataWeightRecord>) -> [RealmDailyTracker] {
        var allTrackers = [RealmDailyTracker]()
        
        let counterResults = counterResults.sorted(byKeyPath: "pid")
        let weightResults = weightResults.sorted(byKeyPath: "pid")
        
        var thisCounterRecord: RealmDataCountRecord = counterResults[0]
        var thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey // yyyyMMdd
        guard let thisCounterDate = Date(datestampKey: thisCounterDatestamp) else { return allTrackers }
        
        var thisWeightRecord: RealmDataWeightRecord = weightResults[0]
        var thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey // yyyyMMdd
        guard let thisWeightDate = Date(datestampKey: thisWeightDatestamp) else { return allTrackers }
        
        var counterIndex = 0
        var weightIndex = 0
        var lastDatestamp = thisCounterDatestamp 
        var tracker = RealmDailyTracker(date: thisCounterDate)
        
        if thisCounterDatestamp > thisWeightDatestamp { 
            // start with earliest datestamp
            lastDatestamp = thisWeightDatestamp
            tracker = RealmDailyTracker(date: thisWeightDate)
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
                        tracker = RealmDailyTracker(date: date)    
                    } else { return allTrackers } // early fail if datestamp invalid
                } else {
                    lastDatestamp = thisWeightDatestamp 
                    if let date = Date(datestampKey: thisWeightDatestamp) {
                        tracker = RealmDailyTracker(date: date)
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
                        tracker = RealmDailyTracker(date: date)    
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
                        tracker = RealmDailyTracker(date: date)    
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
    private func getDailyTrackersCountersOnly(counterResults: Results<RealmDataCountRecord>) -> [RealmDailyTracker] {
        var allTrackers = [RealmDailyTracker]()
        
        var thisCounterRecord: RealmDataCountRecord = counterResults[0]
        var thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey
        guard let thisDate = Date(datestampKey: thisCounterDatestamp) else { return allTrackers }
        
        var counterIndex = 0
        var lastDatestamp = thisCounterDatestamp
        var tracker = RealmDailyTracker(date: thisDate)
        while counterIndex < counterResults.count {
            thisCounterRecord = counterResults[counterIndex]
            thisCounterDatestamp = thisCounterRecord.pidKeys.datestampKey
            
            if thisCounterDatestamp > lastDatestamp {
                allTrackers.append(tracker)
                if let date = Date(datestampKey: thisCounterDatestamp) {
                    tracker = RealmDailyTracker(date: date)    
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
    private func getDailyTrackersWeightOnly(weightResults: Results<RealmDataWeightRecord>) -> [RealmDailyTracker] {
        var allTrackers = [RealmDailyTracker]()
        
        var thisWeightRecord: RealmDataWeightRecord = weightResults[0]
        var thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey
        guard let thisDate = Date(datestampKey: thisWeightDatestamp) else { return allTrackers }
        
        var weightIndex = 0
        var lastDatestamp = thisWeightDatestamp
        var tracker = RealmDailyTracker(date: thisDate)
        while weightIndex < weightResults.count {
            thisWeightRecord = weightResults[weightIndex]
            thisWeightDatestamp = thisWeightRecord.pidKeys.datestampKey
            
            if thisWeightDatestamp > lastDatestamp {
                allTrackers.append(tracker)
                if let date = Date(datestampKey: thisWeightDatestamp) {
                    tracker = RealmDailyTracker(date: date)    
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
        saveDailyTracker()
        
        let pid = RealmDataCountRecord.pid(date: date, countType: countType)
        do {
            try realm.write {
                realm.create(
                    RealmDataCountRecord.self,
                    value: ["pid": pid, "count": count],
                    update: Realm.UpdatePolicy.modified)
                updateStreak(count: count, date: date, countType: countType)
            }
        } catch {
            LogService.shared.error(
                "RealmProvider saveCount \(error.localizedDescription)"
            )
        }
    }
    
    func saveDBWeight(date: Date, ampm: DataWeightType, kg: Double) {
        // RealmDataWeightRecord(date: date, weightType: weightType, kg: kg)
        guard kg > 0.0 else { return }
        let pid = "\(date.datestampKey).\(ampm.typeKey)"
        do {
            try realm.write {
                realm.create(
                    RealmDataWeightRecord.self,
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
        if let record = realm.object(ofType: RealmDataWeightRecord.self, forPrimaryKey: pid) {
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
    
    func saveDailyTracker() {
        guard let tracker = unsavedDailyTracker else {
            //LogService.shared.debug(
            //    "RealmProvider saveDailyTracker unsavedDailyTracker is nil"
            //)
            return
        }
        saveDailyTracker(tracker: tracker)
    }
    
    func saveDailyTracker(tracker: RealmDailyTracker) {
        do {
            try realm.write {
                let trackerDict = tracker.itemsDict
                for key in trackerDict.keys {
                    realm.add(
                        trackerDict[key]!, // RealmDataCountRecord
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
    
    // MARK: - Progress Streak Indicator Management
    
    // Note: The progress streak is a derived value. 
    // The progress streak indicates the number of consecutive days completed
    // for a specific topic.
    
    private func updateStreak(count: Int, date: Date, countType: DataCountType) {
        let itemCompleted = countType.maxServings == count
        if itemCompleted {
            updateStreakCompleted(date: date, countType: countType)
        } else {
            updateStreakIncomplete(date: date, countType: countType)
        }
    }
    
    private func updateStreakCompleted(date: Date, countType: DataCountType) {
        // setup this date
        let thisPid = RealmDataCountRecord.pid(date: date, countType: countType)
        guard let thisRec = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: thisPid)
        else {
            LogService.shared.error("Invalid updateStreakCompleted: \(thisPid) not retrieved")
            return
        }
        
        // set this day's streak based on previous date
        var prevDay = date.adding(days: -1)
        var prevPid = RealmDataCountRecord.pid(date: prevDay, countType: countType)
        if let yesterday = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: prevPid) {
            thisRec.streak = yesterday.streak + 1
        } else {
            thisRec.streak = 1
        }
        
        // check & update next (future) date streak values
        var nextMaxValidStreak = thisRec.streak + 1
        var nextDay = date.adding(days: 1)
        var nextPid = RealmDataCountRecord.pid(date: nextDay, countType: countType)
        while let nextRec = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: nextPid) {
            if nextRec.count < countType.maxServings {
                if nextRec.streak == 0 {
                    // Done. Next day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    LogService.shared.error("\(nextPid) count:\(nextRec.count) < maxServings\(countType.maxServings) with streak:\(nextRec.streak)")
                    nextRec.streak = 0
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if nextRec.count == countType.maxServings {
                if nextRec.streak != nextMaxValidStreak {
                    nextRec.streak = nextMaxValidStreak // Update
                } else {
                    break // Done.                        
                }
                nextMaxValidStreak += 1
            } else if nextRec.count > countType.maxServings {
                LogService.shared.error("\(nextPid) count:\(nextRec.count) > maxServings\(countType.maxServings)")
                nextRec.count = countType.maxServings
                nextRec.streak = nextMaxValidStreak
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            nextDay = nextDay.adding(days: 1)
            nextPid = RealmDataCountRecord.pid(date: nextDay, countType: countType)
        }
        
        // count to verify this day's streak value.
        prevDay = date.adding(days: -1) // reset
        prevPid = RealmDataCountRecord.pid(date: prevDay, countType: countType) // reset
        var streakCount = 1
        while let prevRec = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: prevPid) {
            if prevRec.count == countType.maxServings {
                streakCount += 1                
            } else {
                break
            }
            prevDay = prevDay.adding(days: -1)
            prevPid = RealmDataCountRecord.pid(date: prevDay, countType: countType)
        }
        
        if streakCount == thisRec.streak {
            return // Done. Expected outcome.
        } 
        
        // check & update previous (past) date streak values
        prevDay = date.adding(days: -1) // reset
        prevPid = RealmDataCountRecord.pid(date: prevDay, countType: countType) // reset
        var prevMaxValidStreak = thisRec.streak - 1
        while let prevRec = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: prevPid) {
            if prevRec.count < countType.maxServings {
                if prevRec.streak == 0 {
                    // Done. Previous day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    LogService.shared.error("\(prevPid) count:\(prevRec.count) < maxServings\(countType.maxServings) with streak:\(prevRec.streak)")
                    prevRec.streak = 0
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if prevRec.count == countType.maxServings {
                if prevRec.streak != prevMaxValidStreak {
                    prevRec.streak = prevMaxValidStreak
                } else {
                    break // Done.                        
                }
                prevMaxValidStreak -= 1
            } else if prevRec.count > countType.maxServings {
                LogService.shared.error("\(prevPid) count:\(prevRec.count) > maxServings\(countType.maxServings)")
                prevRec.count = countType.maxServings
                prevRec.streak = prevMaxValidStreak
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            prevDay = prevDay.adding(days: -1)
            prevPid = RealmDataCountRecord.pid(date: prevDay, countType: countType)
        }        
    }
    
    private func updateStreakIncomplete(date: Date, countType: DataCountType) {
        // setup this date
        let thisPid = RealmDataCountRecord.pid(date: date, countType: countType)
        guard let thisRec = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: thisPid)
        else {
            LogService.shared.error("Invalid updateStreakIncomplete: \(thisPid) not retrieved")
            return
        }
        // this day's streak is 0
        thisRec.streak = 0
        
        // check & update next (future) date streak values
        var nextMaxValidStreak = 1
        var nextDay = date.adding(days: 1)
        var nextPid = RealmDataCountRecord.pid(date: nextDay, countType: countType)
        while let nextRec = realm.object(ofType: RealmDataCountRecord.self, forPrimaryKey: nextPid) {
            if nextRec.count < countType.maxServings {
                if nextRec.streak == 0 {
                    // Done. Next day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    LogService.shared.error("\(nextPid) count:\(nextRec.count) < maxServings\(countType.maxServings) with streak:\(nextRec.streak)")
                    nextRec.streak = 0
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if nextRec.count == countType.maxServings {
                if nextRec.streak != nextMaxValidStreak {
                    nextRec.streak = nextMaxValidStreak // update
                } else {
                    break // Done.
                }
                nextMaxValidStreak += 1
            } else if nextRec.count > countType.maxServings {
                LogService.shared.error("\(nextPid) count:\(nextRec.count) > maxServings\(countType.maxServings)")
                nextRec.count = countType.maxServings
                nextRec.streak = nextMaxValidStreak
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            nextDay = nextDay.adding(days: 1)
            nextPid = RealmDataCountRecord.pid(date: nextDay, countType: countType)
        }
    }
    
}
