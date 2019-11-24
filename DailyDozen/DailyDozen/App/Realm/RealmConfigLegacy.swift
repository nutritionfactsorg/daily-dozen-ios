//
//  RealmConfigLegacy.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 24.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmConfigLegacy {
    
    private struct Strings {
        static let realmFilename = "main.realm"
    }
    
    case servings
    
    /// A private instance of a Realm for the Servings.
    private static let servingsConfig = Realm.Configuration(
        fileURL: URL.inDocuments(for: Strings.realmFilename),
        objectTypes: [Doze.self, Item.self])
    
    /// A public configuration instance of a Realm.
    var configuration: Realm.Configuration {
        switch self {
        case .servings:
            return RealmConfigLegacy.servingsConfig
        }
    }
    
    /// Returns an initial doze for the current date.
    ///
    /// **Important: Item name keys** 
    /// 
    /// The "`Item(name:`" property here is used: 
    /// 
    /// 1. by `DozeViewModel` `imageName(…)` method
    /// to derive the associated servings image filename. 
    /// 2. by `DozeViewModel` `itemInfo(…)` method
    /// to determine `isSupplemental` display handling 
    /// 3. by `TextsProvider` for `getTopic(…)` lookup of "details.plist" strings.
    ///
    /// This `items` array order sets the Servings display order.
    /// 
    /// The numerical split between main items and supplements items 
    /// is set by `supplementsCount` in `ServingsSection`.
    ///
    /// - Parameter date: The current date.
    static func initialDoze(for date: Date) -> Doze {
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
}
