//
//  Doze.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 24.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

class Doze: Object {

    @objc dynamic var date = Date()
    @objc dynamic var id = UUID().uuidString
    let items = List<Item>()

    convenience init(date: Date, items: [Item]) {
        self.init()
        self.date = date
        self.items.append(objectsIn: items)
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
