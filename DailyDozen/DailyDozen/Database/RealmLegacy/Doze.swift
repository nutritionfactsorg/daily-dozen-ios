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
    
    // MARK: - RealmDB Persisted Properties
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var date = DateManager.currentDatetime()
    let items = List<Item>()
    
    // MARK: - Non-Persisted Properties

    // MARK: - Init
    
    convenience init(date: Date, items: [Item]) {
        self.init()
        self.date = date
        self.items.append(objectsIn: items)
    }
    
    // MARK: - RealmDB Meta
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
