//
//  RealmProvider.swift
//  DatabaseMigration
//
//  Created by marc on 2019.11.08.
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation
import RealmSwift

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
    
    /// :REPLACES: getDozeLegacy(Date)
    func getDailyTracker(date: Date) -> DailyTracker {
        let datestampKey = date.datestampKey
        
        var dailyTracker = DailyTracker(date: date)
        
        for dataCountType in DataCountType.allCases {
            let id = DataCountRecord.id(datestampKey: datestampKey, typeKey: dataCountType.typeKey)
            if let item = realm.object(ofType: DataCountRecord.self, forPrimaryKey: id) {
                dailyTracker.itemsDict[dataCountType] = item
            } else {
                dailyTracker.itemsDict[dataCountType] = DataCountRecord(date: date, countType: dataCountType)
            }
        }
        
        unsavedDailyTracker = dailyTracker
        return dailyTracker
    }
    
    /// :!!!:REPLACES: getDozesLegacy() -> Results<Doze>
    /// Note: minimal checked. Expects stored database values to be valid. Exists on first data error.
    func getDailyTrackers() -> [DailyTracker] {
        var allTrackers = [DailyTracker]()
        let counterResults = realm.objects(DataCountRecord.self)
        let counterResultsById = counterResults.sorted(byKeyPath: "id")
        guard counterResultsById.count > 0 else {
            return allTrackers
        }
        
        let weightResults = realm.objects(DataWeightRecord.self)
        let weightResultsById = weightResults.sorted(byKeyPath: "id")
        
        let first = counterResultsById[0]
        guard let firstDate = first.keys?.datestamp else {
            return allTrackers
        }
        var tracker = DailyTracker(date: firstDate)
        var weightIdx = 0
        for dataCountRecord in counterResultsById {
            let datestampKey = dataCountRecord.keyStrings.datestampKey
            if dataCountRecord.keyStrings.datestampKey != datestampKey {
                guard let nextDate = Date.init(datestampKey: datestampKey) else {
                    return allTrackers
                }
                
                // Process Weights: AM, PM
                while weightIdx < weightResultsById.count &&
                    weightResultsById[weightIdx].keyStrings.datestampKey == datestampKey {
                        let weight = weightResultsById[weightIdx]
                        if weight.keyStrings.typeKey == DataWeightType.am.typeKey {
                            tracker.weightAM = weight
                        } else {
                            tracker.weightPM = weight
                        }
                        weightIdx += 1
                }
                
                allTrackers.append(tracker)
                tracker = DailyTracker(date: nextDate)
            }
            
            guard let countType = dataCountRecord.keys?.countType else {
                return allTrackers
            }
            tracker.itemsDict[countType] = dataCountRecord
        }
        allTrackers.append(tracker)
        
        return allTrackers
    }
    
    func saveCount(_ count: Int, date: Date, countType: DataCountType) {
        let id = DataCountRecord.id(date: date, countType: countType)
        saveCount(count, id: id)
    }
    
    /// :!!!:REPLACES: saveStates([Bool], String)
    func saveCount(_ count: Int, id: String) {
        saveDailyTracker()
        let keys = DataCountRecord.idKeys(id: id)
        do {
            try realm.write {
                realm.create(
                    DataCountRecord.self,
                    value: ["id": id, "datestampKey": keys.datestampKey, "typeKey": keys.typeKey, "count": count], 
                    update: Realm.UpdatePolicy.all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// :NYI saveWeight() 
    
    func updateStreak(_ streak: Int, date: Date, countType: DataCountType) {
        let id = DataCountRecord.id(date: date, countType: countType)
        updateStreak(streak, id: id)
    }
    
    /// :!!!:REPLACES: updateStreak(Int, String)
    /// :!!!:NYI: updateStreak() needs to do more than a single value
    func updateStreak(_ streak: Int, id: String) {
        saveDailyTracker()
        let keys = DataCountRecord.idKeys(id: id)
        do {
            try realm.write {
                realm.create(
                    DataCountRecord.self, 
                    value: ["id": id, "datestampKey": keys.datestampKey, "typeKey": keys.typeKey, "streak": streak], 
                    update: Realm.UpdatePolicy.all
                )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// :!!!:REPLACES: saveDozeLegacy()
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
