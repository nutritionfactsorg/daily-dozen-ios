//
//  RealmProvider.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 30.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import RealmSwift

class RealmProvider {

    private let realm: Realm

    init() {
        guard let realm = try? Realm(configuration: RealmConfig.servings.configuration) else {
            fatalError("There should be a realm")
        }
        self.realm = realm
    }

    /// Returns a Doze object for the current date.
    ///
    /// - Returns: The doze.
    func getDoze(for date: Date) -> Doze {
        return realm
            .objects(Doze.self)
            .filter { $0.date.shortDescription == date.shortDescription }
            .first ?? RealmConfig.initialDoze(for: date)
    }

    /// Updates an Item object with an ID for new states.
    ///
    /// - Parameters:
    ///   - states: The new state.
    ///   - id: The ID.
    func saveStates(_ states: [Bool], with id: String) {
        do {
            try realm.write {
                realm.create(Item.self, value: ["id": id, "states": states], update: true)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
