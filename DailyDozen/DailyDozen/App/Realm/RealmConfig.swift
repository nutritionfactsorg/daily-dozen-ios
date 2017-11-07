//
//  RealmConfig.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 24.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmConfig {

    private struct Keys {
        static let realm = "main.realm"
    }

    case servings

    /// Provides an initial doze for the empty Servings.
    static var initialDoze: Doze {
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
        let doze = Doze(date: Date(), items: items)

        if let realm = try? Realm(configuration: RealmConfig.servings.configuration) {
            do {
                try realm.write {
                    realm.add(doze, update: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return doze
    }

    /// A private instance of a Realm for the Servings.
    private static let servingsConfig = Realm.Configuration(
        fileURL: URL.inDocuments(for: Keys.realm),
        objectTypes: [Doze.self, Item.self])

    /// A public configuration instance of a Realm.
    var configuration: Realm.Configuration {
        switch self {
        case .servings:
            return RealmConfig.servingsConfig
        }
    }
}
