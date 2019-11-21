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
    
    private struct Keys {
        static let realmFilename = "NutritionFacts.realm"
    }
    
    private let realm: Realm
    private var unsavedDailyTracker: DailyTracker?
    
    init() {
        let config = Realm.Configuration(
            // Local Realm file url
            fileURL: URL.inDocuments(for: Keys.realmFilename),
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
    
    /// :REPLACES: getDoze(Date)
    func getDailyTracker(date: Date) -> DailyTracker {
        let datestampKey = date.datestampKey
        
        var dailyTracker = DailyTracker(date: date)
        
        for dataCountType in DataCountType.allCases {
            let id = DataCountRecord.id(datestampKey: datestampKey, typeKey: dataCountType.typeKey)
            if let item = realm.object(ofType: DataCountRecord.self, forPrimaryKey: id) {
                dailyTracker.itemsDict[dataCountType] = item
            } else {
                dailyTracker.itemsDict[dataCountType] = DataCountRecord(date: date, type: dataCountType)
            }
        }

        unsavedDailyTracker = dailyTracker
        return dailyTracker
    }
    
    /// :!!!:REPLACES: getDozes() -> Results<Doze>
    func getDailyTrackers() -> [DailyTracker] {
        fatalError(":NYI: getDailyTrackers()")
    }

    func saveCount(_ count: Int, date: Date, type: DataCountType) {
        let id = DataCountRecord.id(date: date, type: type)
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
    
    func updateStreak(_ streak: Int, date: Date, type: DataCountType) {
        let id = DataCountRecord.id(date: date, type: type)
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
    
    /// :!!!:REPLACES: saveDoze() 
    func saveDailyTracker() {
        print("::: :DEBUG: saveDailyTracker() :::")
        guard let tracker = unsavedDailyTracker else {
            print(":DEBUG: saveDailyTracker() unsavedDailyTracker is nil")
            return
        }
        
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
            print(error.localizedDescription)
        }
    }
    
}
