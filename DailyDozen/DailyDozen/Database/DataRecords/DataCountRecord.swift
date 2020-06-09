//
//  DataCountRecord.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation
import RealmSwift

class DataCountRecord: Object {
    
    // MARK: - RealmDB Persisted Properties
    
    /// yyyyMMdd.typeKey e.g. 20190101.beansKey
    @objc dynamic var pid: String = ""
    /// daily servings completed
    @objc dynamic var count: Int = 0
    /// consecutive days-to-date with all servings completed
    @objc dynamic var streak: Int = 0
    
    var pidKeys: (datestampKey: String, typeKey: String) {
        let parts = self.pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }

    var pidParts: (datestamp: Date, countType: DataCountType)? {
        guard let date = Date.init(datestampKey: pidKeys.datestampKey),
            let countType = DataCountType(itemTypeKey: pidKeys.typeKey) else {
                LogService.shared.error(
                    "DataCountRecord pidParts has invalid datestamp or typeKey"
                )
                return nil
        }
        return (datestamp: date, countType: countType)
    }

    // MARK: Class Methods
    
    static func pid(date: Date, countType: DataCountType) -> String {
        return "\(date.datestampKey).\(countType.typeKey)"
    }

    static func pid(datestampKey: String, typeKey: String) -> String {
        return "\(datestampKey).\(typeKey)"
    }

    static func pidKeys(pid: String) -> (datestampKey: String, typeKey: String) {
        let parts = pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
    
    // MARK: - Init
    
    /// CSV Initialer.
    convenience init?(datestampKey: String, typeKey: String, count: Int = 0, streak: Int = 0) {
        guard let dataCountType = DataCountType(itemTypeKey: typeKey),
            Date(datestampKey: datestampKey) != nil else {
            return nil
        }
        
        self.init()
        self.pid = "\(datestampKey).\(typeKey)"

        self.count = count
        if self.count > dataCountType.maxServings {
            self.count = dataCountType.maxServings
            LogService.shared.error(
                "DataCountRecord init datestampKey:\(datestampKey) typekey:\(typeKey) count:\(count) exceeded max servings \(dataCountType.maxServings)"
            )

        }
        self.streak = streak
    }
    
    convenience init(date: Date, countType: DataCountType, count: Int = 0, streak: Int = 0) {
        self.init()
        self.pid = "\(date.datestampKey).\(countType.typeKey)"

        self.count = count
        if self.count > countType.maxServings {
            self.count = countType.maxServings
            LogService.shared.error(
                "DataCountRecord init date:\(date.datestampKey) countType:\(countType.typeKey) count:\(count) exceeds max servings \(countType.maxServings)"
            )
        }
        self.streak = streak
    }
    
    // MARK: - Meta Information
    
    override static func primaryKey() -> String? {
        return "pid"
    }
        
    // MARK: - Data Presentation Methods
    
    func title() -> String {
        guard let tmp = DataCountType(rawValue: self.pidKeys.typeKey) else {
            return "Undefined Title (Error)" 
        }
        return tmp.headingDisplay
    }
    
    // MARK: - Data Management Methods
    
    func setCount(text: String) {
        if let value = Int(text) {
            setCount(value)
        } else {
            LogService.shared.error(
                "DataCountRecord setCount() not convertable to Int \(text)"
            )
        }
    }
    
    func setCount(_ count: Int) {
        self.count = count
        if let countType = pidParts?.countType {
            if self.count > countType.maxServings {
                self.count = countType.maxServings
                LogService.shared.error(
                    "DataCountRecord setCount \(pid) \(count) exceeds max servings"
                )
            }
        } else {
            LogService.shared.error(
                "DataCountRecord setCount \(pid) \(count) could not range check servings"
            )
        }
    }
    
}
