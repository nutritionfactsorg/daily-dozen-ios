//
//  Item.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 23.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    // MARK: - RealmDB Persisted Properties
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var streak = 0
    let states = List<Bool>()
    
    // MARK: - Non-Persisted Properties

    // MARK: - Init
    
    convenience init(name: String, states: [Bool], streak: Int = 0) {
        self.init()
        self.name = name
        self.streak = streak
        self.states.append(objectsIn: states)
    }
    
    // MARK: - RealmDB Meta
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
