//
//  RealmProvider_v02.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 30.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import RealmSwift

protocol RealmDelegateLegacy: AnyObject {
    func didUpdateFile()
}

class RealmProviderLegacy {
    
    private let realm: Realm
    private var unsavedDoze: Doze?
    
    init() {
        let config = RealmConfigLegacy.servings.configuration
        guard let realm = try? Realm(configuration: config) 
            else {
                fatalError("There should be a realm")
        }
        self.realm = realm
    }
    
    /// Returns a Doze object for the current date.
    /// 
    /// - Returns: The doze.
    func getDozeLegacy(for date: Date) -> Doze {
        let dozeResults: Results<Doze> = realm.objects(Doze.self)
        let dozeFiltered = dozeResults.filter { $0.date.isInCurrentDayWith(date) }
        let doze = dozeFiltered.first ?? RealmConfigLegacy.initialDoze(for: date)
        unsavedDoze = doze
        return doze
    }
    
    func getDozesLegacy() -> Results<Doze> {
        return realm.objects(Doze.self)
    }
    
    /// Updates an Item object with an ID for new states.
    ///
    /// - Parameters:
    ///   - states: The new state.
    ///   - id: The ID.
    func saveStatesLegacy(_ states: [Bool], id: String) {
        saveDozeLegacy()
        do {
            try realm.write {
                realm.create(Item.self, value: ["id": id, "states": states], update: Realm.UpdatePolicy.all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateStreakLegacy(_ streak: Int, id: String) {
        saveDozeLegacy()
        do {
            try realm.write {
                // BUG: id+streak(0) only causing memory leak when called but not later used.
                realm.create(Item.self, value: ["id": id, "streak": streak], update: Realm.UpdatePolicy.all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Saves the unsaved doze.
    private func saveDozeLegacy() {
        if let doze = unsavedDoze {
            do {
                try realm.write {
                    realm.add(doze, update: Realm.UpdatePolicy.all)
                    unsavedDoze = nil
                }
            } catch {
                print(":ERROR: saveDozeLegacy() failed dozr:\(doze) description:\(error.localizedDescription)")
            }
        }
    }
    
    func deleteAllLegacy() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(":ERROR: deleteAll() failed description:\(error.localizedDescription)")
        }
    }
    
}
