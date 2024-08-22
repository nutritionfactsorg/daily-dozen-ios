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
            logit.error(
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
        let fm = FileManager.default
        // Create Library/Database directory if not present
        let databaseUrl = URL.inLibrary()
            .appendingPathComponent("Database", isDirectory: true)
        do {
            try fm.createDirectory(at: databaseUrl, withIntermediateDirectories: true)
        } catch {
            logit.error(" \(error)")
        }
        
        let config = Realm.Configuration(
            fileURL: fileURL,   // local Realm file url
            objectTypes: [DataCountRecord.self, DataWeightRecord.self])
        Realm.Configuration.defaultConfiguration = config
        guard let realm = try? Realm() else {
            if #available(iOS 16.0, *) {
                fatalError("FAIL: could not instantiate (init) RealmProvider. fileURL:\(fileURL.path(percentEncoded: false))")
            } else {
                // Fallback on earlier versions
                fatalError("FAIL: could not instantiate (init) RealmProvider. fileURL:\(fileURL.absoluteString)")
            }
        }
        self.realm = realm
    }
    
    static func initialize(fileURL: URL) {
        let fm = FileManager.default
        // Create Library/Database directory if not present
        let databaseUrl = URL.inLibrary()
            .appendingPathComponent("Database", isDirectory: true)
        do {
            try fm.createDirectory(at: databaseUrl, withIntermediateDirectories: true)
        } catch {
            logit.error(" \(error)")
        }
        //Realm.Configuration(
        //    fileURL: URL?,
        //    inMemoryIdentifier: String?,
        //    syncConfiguration: SyncConfiguration?,
        //    encryptionKey: Data?,
        //    readOnly: Bool,
        //    schemaVersion: UInt64,
        //    migrationBlock: MigrationBlock?,
        //    deleteRealmIfMigrationNeeded: Bool,
        //    shouldCompactOnLaunch: ((Int, Int) -> Bool)?,
        //    objectTypes: [Object.Type]?
        
        let config = Realm.Configuration(
            fileURL: fileURL,   // local Realm file url
            objectTypes: [DataCountRecord.self, DataWeightRecord.self])
        Realm.Configuration.defaultConfiguration = config
        guard let realm = try? Realm() else {
            if #available(iOS 16.0, *) {
                fatalError("FAIL: could not instantiate (static func) RealmProvider. fileURL:\(fileURL.path(percentEncoded: false))")
            } else {
                // Fallback on earlier versions
                fatalError("FAIL: could not instantiate (static func) RealmProvider. fileURL:\(fileURL.absoluteString)")
            }
        }
        RealmProvider.primary.realm = realm
        //Realm.invalidate(<#T##self: Realm##Realm#>)
        _ = Realm.refresh(RealmProvider.primary.realm)
    }
    
    func initialDailyTracker(date: Date) -> RealmDailyTracker {
        return RealmDailyTracker(date: date)
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
    func getDailyWeights() -> (am: [DataWeightRecord], pm: [DataWeightRecord]) {
        var amRecords = [DataWeightRecord]()
        var pmRecords = [DataWeightRecord]()
        let weightResults = realm.objects(DataWeightRecord.self)
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
    func getDailyWeightsArray() -> [DataWeightRecord] {
        var records = [DataWeightRecord]()
        let weightResults = realm.objects(DataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "pid")
        
        for realmDataWeightRecord in weightResultsById {
            records.append(realmDataWeightRecord)
        }
        
        return records
    }
    
    func getDailyCountRecord(date: Date, countType: DataCountType) -> DataCountRecord? {
        let datestampkey = date.datestampKey
        let typekey = countType.typeKey
        let pid = DataCountRecord.pid(datestampKey: datestampkey, typeKey: typekey)
        
        if let item = realm.object(ofType: DataCountRecord.self, forPrimaryKey: pid) {
            return item
        }
        return nil
    }
    
    func getDailyTracker(date: Date) -> RealmDailyTracker {
        let datestampKey = date.datestampKey
        
        var dailyTracker = RealmDailyTracker(date: date)
        
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
    func getDailyTrackers(activity: ActivityProgress? = nil) -> [RealmDailyTracker] {        
        // Daily Dozen & Tweaks Counters
        activity?.setProgress(ratio: 0.0, text: "0/3")
        let counterResultsById = realm.objects(DataCountRecord.self)
            .sorted(byKeyPath: "pid")
        
        // Weight History
        activity?.setProgress(ratio: 0.33, text: "1/3")
        let weightResultsById = realm.objects(DataWeightRecord.self)
            .sorted(byKeyPath: "pid")
        
        // :NOTE: proceeds quickly to here.
        if counterResultsById.count > 0 && weightResultsById.count > 0 {
            activity?.setProgress(ratio: 0.66, text: "2/3")
            let data = getDailyTrackersMerged(counterResults: counterResultsById, weightResults: weightResultsById)
            return data
        } else if counterResultsById.count > 0 {
            activity?.setProgress(ratio: 0.66, text: "2/3")
            let data = getDailyTrackersCountersOnly(counterResults: counterResultsById)
            return data
        } else if weightResultsById.count > 0 {
            activity?.setProgress(ratio: 0.66, text: "2/3")
            let data = getDailyTrackersWeightOnly(weightResults: weightResultsById)
            return data
        } else {
            return [RealmDailyTracker]()
        }
    }
    
    /// Merges counts and weights in to single [DailyTracker] array
    private func getDailyTrackersMerged(counterResults: Results<DataCountRecord>, weightResults: Results<DataWeightRecord>) -> [RealmDailyTracker] {
        var allTrackers = [RealmDailyTracker]()
        
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
    private func getDailyTrackersCountersOnly(counterResults: Results<DataCountRecord>) -> [RealmDailyTracker] {
        var allTrackers = [RealmDailyTracker]()
        
        var thisCounterRecord: DataCountRecord = counterResults[0]
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
    private func getDailyTrackersWeightOnly(weightResults: Results<DataWeightRecord>) -> [RealmDailyTracker] {
        var allTrackers = [RealmDailyTracker]()
        
        var thisWeightRecord: DataWeightRecord = weightResults[0]
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
        
        let pid = DataCountRecord.pid(date: date, countType: countType)
        do {
            try realm.write {
                realm.create(
                    DataCountRecord.self,
                    value: ["pid": pid, "count": count] as [String: Any],
                    update: Realm.UpdatePolicy.modified)
                updateStreak(count: count, date: date, countType: countType)
            }
        } catch {
            logit.error(
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
                    DataWeightRecord.self,
                    value: ["pid": pid, "kg": kg, "time": date.datestampHHmm] as [String: Any],
                    update: Realm.UpdatePolicy.all)
            }
        } catch {
            logit.error(
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
                logit.error(
                    "RealmProvider deleteWeight \(error.localizedDescription)"
                )
            }
        }
    }
    
    func saveDailyTracker() {
        guard let tracker = unsavedDailyTracker else {
            //logit.debug(
            //    "RealmProvider saveDailyTracker unsavedDailyTracker is nil"
            //)
            return
        }
        saveDailyTracker(tracker: tracker)
    }
    
    /// Write DailyTracker to Realm Database
    func saveDailyTracker(tracker: RealmDailyTracker) {
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
            logit.error(
                "FAIL RealmProvider saveDailyTracker() tracker:\(tracker) description:\(error.localizedDescription)"
            )
        }
    }
    
    /// Deletes all objects from the Realm.
    func deleteAllObjects() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            logit.error(
                "FAIL RealmProvider deleteAllObjects() description:\(error.localizedDescription)"
            )
        }
    }
    
    // MARK: - Progress Streak Indicator Management
    
    // Note: The progress streak is a derived value. 
    // The progress streak indicates the number of consecutive days completed
    // for a specific topic.
    
    private func updateStreak(count: Int, date: Date, countType: DataCountType) {
        let itemCompleted = countType.goalServings == count
        if itemCompleted {
            updateStreakCompleted(date: date, countType: countType)
        } else {
            updateStreakIncomplete(date: date, countType: countType)
        }
    }
    
    private func updateStreakCompleted(date: Date, countType: DataCountType) {
        // setup this date
        let thisPid = DataCountRecord.pid(date: date, countType: countType)
        guard let thisRec = realm.object(ofType: DataCountRecord.self, forPrimaryKey: thisPid)
        else {
            logit.error("Invalid updateStreakCompleted: \(thisPid) not retrieved")
            return
        }
        
        // set this day's streak based on previous date
        var prevDay = date.adding(days: -1)
        var prevPid = DataCountRecord.pid(date: prevDay, countType: countType)
        if let yesterday = realm.object(ofType: DataCountRecord.self, forPrimaryKey: prevPid) {
            thisRec.streak = yesterday.streak + 1
        } else {
            thisRec.streak = 1
        }
        
        // check & update next (future) date streak values
        var nextMaxValidStreak = thisRec.streak + 1
        var nextDay = date.adding(days: 1)
        var nextPid = DataCountRecord.pid(date: nextDay, countType: countType)
        while let nextRec = realm.object(ofType: DataCountRecord.self, forPrimaryKey: nextPid) {
            if nextRec.count < countType.goalServings {
                if nextRec.streak == 0 {
                    // Done. Next day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    logit.error("\(nextPid) count:\(nextRec.count) < goalServings\(countType.goalServings) with streak:\(nextRec.streak)")
                    nextRec.streak = 0
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if nextRec.count == countType.goalServings {
                if nextRec.streak != nextMaxValidStreak {
                    nextRec.streak = nextMaxValidStreak // Update
                } else {
                    break // Done.                        
                }
                nextMaxValidStreak += 1
            } else if nextRec.count > countType.goalServings {
                logit.error("\(nextPid) count:\(nextRec.count) > goalServings\(countType.goalServings)")
                nextRec.count = countType.goalServings
                nextRec.streak = nextMaxValidStreak
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            nextDay = nextDay.adding(days: 1)
            nextPid = DataCountRecord.pid(date: nextDay, countType: countType)
        }
        
        // count to verify this day's streak value.
        prevDay = date.adding(days: -1) // reset
        prevPid = DataCountRecord.pid(date: prevDay, countType: countType) // reset
        var streakCount = 1
        while let prevRec = realm.object(ofType: DataCountRecord.self, forPrimaryKey: prevPid) {
            if prevRec.count == countType.goalServings {
                streakCount += 1                
            } else {
                break
            }
            prevDay = prevDay.adding(days: -1)
            prevPid = DataCountRecord.pid(date: prevDay, countType: countType)
        }
        
        if streakCount == thisRec.streak {
            return // Done. Expected outcome.
        } 
        
        // check & update previous (past) date streak values
        prevDay = date.adding(days: -1) // reset
        prevPid = DataCountRecord.pid(date: prevDay, countType: countType) // reset
        var prevMaxValidStreak = thisRec.streak - 1
        while let prevRec = realm.object(ofType: DataCountRecord.self, forPrimaryKey: prevPid) {
            if prevRec.count < countType.goalServings {
                if prevRec.streak == 0 {
                    // Done. Previous day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    logit.error("\(prevPid) count:\(prevRec.count) < goalServings\(countType.goalServings) with streak:\(prevRec.streak)")
                    prevRec.streak = 0
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if prevRec.count == countType.goalServings {
                if prevRec.streak != prevMaxValidStreak {
                    prevRec.streak = prevMaxValidStreak
                } else {
                    break // Done.                        
                }
                prevMaxValidStreak -= 1
            } else if prevRec.count > countType.goalServings {
                logit.error("\(prevPid) count:\(prevRec.count) > goalServings\(countType.goalServings)")
                prevRec.count = countType.goalServings
                prevRec.streak = prevMaxValidStreak
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            prevDay = prevDay.adding(days: -1)
            prevPid = DataCountRecord.pid(date: prevDay, countType: countType)
        }        
    }
    
    private func updateStreakIncomplete(date: Date, countType: DataCountType) {
        // setup this date
        let thisPid = DataCountRecord.pid(date: date, countType: countType)
        // Retrieve single instance given object type with the given primary key
        guard let thisRec = realm.object(ofType: DataCountRecord.self, forPrimaryKey: thisPid)
        else {
            logit.error("Invalid updateStreakIncomplete: \(thisPid) not retrieved")
            return
        }
        // this day's streak is 0
        thisRec.streak = 0
        
        // check & update next (future) date streak values
        var nextMaxValidStreak = 1
        var nextDay = date.adding(days: 1)
        var nextPid = DataCountRecord.pid(date: nextDay, countType: countType)
        // Retrieve single instance given object type with the given primary key
        while let nextRec = realm.object(ofType: DataCountRecord.self, forPrimaryKey: nextPid) {
            if nextRec.count < countType.goalServings {
                if nextRec.streak == 0 {
                    // Done. Next day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    logit.error("\(nextPid) count:\(nextRec.count) < goalServings\(countType.goalServings) with streak:\(nextRec.streak)")
                    nextRec.streak = 0
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if nextRec.count == countType.goalServings {
                if nextRec.streak != nextMaxValidStreak {
                    nextRec.streak = nextMaxValidStreak // update
                } else {
                    break // Done.
                }
                nextMaxValidStreak += 1
            } else if nextRec.count > countType.goalServings {
                logit.error("\(nextPid) count:\(nextRec.count) > goalServings\(countType.goalServings)")
                nextRec.count = countType.goalServings
                nextRec.streak = nextMaxValidStreak
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            nextDay = nextDay.adding(days: 1)
            nextPid = DataCountRecord.pid(date: nextDay, countType: countType)
        }
    }
    
}
