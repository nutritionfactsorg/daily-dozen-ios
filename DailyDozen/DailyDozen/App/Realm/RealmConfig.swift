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
            Item(name: "Beans", doses: [false, false, false]),
            Item(name: "Berries", doses: [false]),
            Item(name: "Other fruits", doses: [false, false, false]),
            Item(name: "Cruciferous Vegetables", doses: [false]),
            Item(name: "Greens", doses: [false, false]),
            Item(name: "Other Vegetables", doses: [false, false]),
            Item(name: "Flaxseeds", doses: [false]),
            Item(name: "Nuts", doses: [false]),
            Item(name: "Spices", doses: [false]),
            Item(name: "Whole Grains", doses: [false, false, false]),
            Item(name: "Beverages", doses: [false, false, false, false, false]),
            Item(name: "Exercise", doses: [false]),
            Item(name: "Vitamin B12", doses: [false]),
            Item(name: "Vitamin D", doses: [false])
        ]
        let doze = Doze(date: Date(), items: items)

        if let realm = try? Realm(configuration: RealmConfig.servings.configuration) {
            do {
                try realm.write {
                    realm.add(doze)
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
