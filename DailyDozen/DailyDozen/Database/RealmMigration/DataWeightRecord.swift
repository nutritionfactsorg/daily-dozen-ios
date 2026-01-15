//
//  DataWeightRecord.swift
//  RealmMigration
//
//  Copyright © 2019-2025 NutritionFacts.org. All rights reserved.
//

import Foundation
import RealmSwift

/*
 pid,kg,time
 20221209.am,66.9,08:24
 20221209.pm,63.0,21:08
 20221210.am,66.9,08:58
 20221210.pm,63.0,23:32
 */

class DataWeightRecord: Object {
    @objc dynamic var pid: String = ""
    @objc dynamic var kg: Double = 0.0
    @objc dynamic var time: String = ""

    override class func primaryKey() -> String? { "pid" }
    
    var pidKeys: (datestampKey: String, typeKey: String) {
        let parts = self.pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
}
