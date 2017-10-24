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
    let doses = List<Bool>()

    convenience init(name: String, doses: [Bool]) {
        self.init()
        self.name = name
        self.doses.append(objectsIn: doses)
    }
}
