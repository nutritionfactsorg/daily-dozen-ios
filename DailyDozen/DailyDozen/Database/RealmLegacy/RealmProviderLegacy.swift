//
//  RealmProviderLegacy.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import RealmSwift

class RealmProviderLegacy {
    
    public static let realmFilename = "main.realm"
    
    private let realm: Realm
    private var unsavedDoze: Doze?
    
//    convenience init() {
//        let fileURL: URL = URL.inDocuments(filename: RealmProviderLegacy.realmFilename)
//        self.init(fileURL: fileURL)
//    }
    
    init(fileURL: URL) {
        let config = Realm.Configuration(
            fileURL: fileURL,   // local Realm file url
            objectTypes: [Doze.self, Item.self])
        guard let realm = try? Realm(configuration: config) 
            else {
                fatalError("FAIL: could not instantiate RealmProviderLegacy")
        }
        self.realm = realm
    }
    
    /// Returns a Doze object for the current date.
    /// 
    /// - Returns: The doze.
    func getDozeLegacy(for date: Date) -> Doze {
        let dozeResults: Results<Doze> = realm.objects(Doze.self)
        let dozeFiltered = dozeResults.filter { $0.date.isInCurrentDayWith(date) }
        let doze = dozeFiltered.first ?? initialDoze(date: date)
        unsavedDoze = doze
        return doze
    }
    
    private func initialDoze(date: Date) -> Doze {
        let items = [
            Item(name: "Beans", states: [false, false, false]),
            Item(name: "Berries", states: [false]),
            Item(name: "Other Fruits", states: [false, false, false]),
            Item(name: "Cruciferous Vegetables", states: [false]),
            Item(name: "Greens", states: [false, false]),
            Item(name: "Other Vegetables", states: [false, false]),
            Item(name: "Flaxseeds", states: [false]),
            Item(name: "Nuts", states: [false]),
            Item(name: "Spices", states: [false]),
            Item(name: "Whole Grains", states: [false, false, false]),
            Item(name: "Beverages", states: [false, false, false, false, false]),
            Item(name: "Exercise", states: [false]),
            Item(name: "Vitamin B12", states: [false]),
            Item(name: "Vitamin D", states: [false])
        ]
        return Doze(date: date, items: items)
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
            LogService.shared.error(
                "RealmProviderLegacy saveStatesLegacy \(error.localizedDescription)"
            )
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
            LogService.shared.error(
                "RealmProviderLegacy updateStreakLegacy \(error.localizedDescription)"
            )
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
                LogService.shared.error(
                    "FAILED RealmProviderLegacy saveDozeLegacy() did not save doze: \(doze), description: \(error.localizedDescription)"
                )
            }
            
        }
    }
    
    func deleteDBAllLegacy() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            LogService.shared.error(
                "FAIL RealmProviderLegacy deleteDBAllLegacy() description:\(error.localizedDescription)"
            )
        }
    }
    
}
