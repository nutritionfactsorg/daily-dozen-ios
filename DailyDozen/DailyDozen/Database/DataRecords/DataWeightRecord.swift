//
//  DataWeightRecord.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation
import RealmSwift

class DataWeightRecord: Object {
    
    /// yyyyMMdd.typeKey e.g. 20190101.amKey
    @objc dynamic var pid = "" 
    // kilograms
    @objc dynamic var kg = 0.0     
    // time of day HH:mm 24-hour
    @objc dynamic var time = ""    
    
    var lbs: Double {
        return kg * 2.204623
    }
    
    var pidKeys: (datestampKey: String, typeKey: String) {
        let parts = self.pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
    
    var pidParts: (datestamp: Date, weightType: DataCountType)? {
        guard let date = Date.init(datestampKey: pidKeys.datestampKey),
            let weightType = DataCountType(typeKey: pidKeys.typeKey) else {
                print(":ERROR: DataWeightRecord has invalid datestamp or weightType")
                return nil
        }
        return (datestamp: date, weightType: weightType)
    }
    
    // MARK: Class Methods
    
    static func pid(date: Date, weightType: DataWeightType) -> String {
        return "\(date.datestampKey).\(weightType.typeKey)"
    }
    
    static func pidKeys(pid: String) -> (datestampKey: String, typeKey: String) {
        let parts = pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
    
    // MARK: - Init
    
    /// CSV Initialer.
    convenience init?(datestampKey: String, typeKey: String, kilograms: String, timeHHmm: String) {
        guard DataWeightType(typeKey: typeKey) != nil,
            Date(datestampKey: datestampKey) != nil,
            let kg = Double(kilograms),
            timeHHmm.contains(":"),
            Int(timeHHmm.dropLast(3)) != nil,
            Int(timeHHmm.dropFirst(3)) != nil
            else {
                return nil
        }

        self.init()
        self.pid = "\(datestampKey).\(typeKey)"
        self.kg = kg
        self.time = time
    }
    
    convenience init(date: Date, weightType: DataWeightType, kg: Double) {
        self.init()
        self.pid = "\(date.datestampKey).\(weightType.typeKey)"
        self.kg = kg
        self.time = date.datestampHHmm
    }
    
    // MARK: - Meta Information
    
    override static func primaryKey() -> String? {
        return "pid"
    }
    
    // MARK: - Data Presentation Methods
    
}
