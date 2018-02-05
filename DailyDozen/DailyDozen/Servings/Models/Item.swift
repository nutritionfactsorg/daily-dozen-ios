//
//  Entity.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 23.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {

    @objc dynamic var name = ""
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var streak = 0
    let states = List<Bool>()

    convenience init(name: String, states: [Bool], streak: Int = 0) {
        self.init()
        self.name = name
        self.streak = streak
        self.states.append(objectsIn: states)
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
