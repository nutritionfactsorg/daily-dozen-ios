//
//  DataCountRecord.swift
//  RealmMigration
//
//  Copyright © 2019-2025 NutritionFacts.org. All rights reserved.
//

import Foundation
import RealmSwift

/*
 pid,count,streak
 20221209.dozeBeans,3,1
 20221209.dozeBerries,1,1
 20221209.dozeBeverages,1,0
 20221209.dozeExercise,1,1
 20221209.dozeFlaxseeds,1,1
 20221209.dozeFruitsOther,2,0
 20221209.dozeGreens,1,0
 20221209.dozeNuts,1,1
 20221209.dozeSpices,1,1
 20221209.dozeVegetablesCruciferous,0,0
 */

class DataCountRecord: Object {
    @objc dynamic var pid: String = ""
    @objc dynamic var count: Int = 0
    @objc dynamic var streak: Int = 0
    
    override class func primaryKey() -> String? { "pid" }
    
    var pidKeys: (datestampKey: String, typeKey: String) {
        let parts = self.pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
}
