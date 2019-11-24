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
    @objc dynamic var id = "" 
    /// daily servings completed
    @objc dynamic var count = 0
    /// consecutive days-to-date with all servings completed
    @objc dynamic var streak = 0
    
    var keys: (datestamp: Date, countType: DataCountType)? {
        guard let date = Date.init(datestampKey: keyStrings.datestampKey),
            let countType = DataCountType(typeKey: keyStrings.typeKey) else {
                print(":ERROR: DataCountRecord has invalid datestamp or typeKey")
                return nil
        }
        return (datestamp: date, countType: countType)
    }

    var keyStrings: (datestampKey: String, typeKey: String) {
        let parts = self.id.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }

    // MARK: Class Methods
    
    static func id(date: Date, countType: DataCountType) -> String {
        return "\(date.datestampKey).\(countType.typeKey)"
    }

    static func id(datestampKey: String, typeKey: String) -> String {
        return "\(datestampKey).\(typeKey)"
    }

    static func idKeys(id: String) -> (datestampKey: String, typeKey: String) {
        let parts = id.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
    
    // MARK: - Init
    
    /// CSV Initialer.
    convenience init?(datestampKey: String, typeKey: String, count: Int = 0, streak: Int = 0) {
        guard let dataCountType = DataCountType(typeKey: typeKey),
            Date(datestampKey: datestampKey) != nil else {
            return nil
        }
        
        self.init()
        self.id = "\(datestampKey).\(typeKey)"

        self.count = count
        if self.count > dataCountType.maxServings() {
            self.count = dataCountType.maxServings()
            print(":LOG:ERROR: \(datestampKey) \(typeKey) \(count) exceeded max servings \(dataCountType.maxServings())")
        }
        self.streak = streak
    }
    
    convenience init(date: Date, countType: DataCountType, count: Int = 0, streak: Int = 0) {
        self.init()
        self.id = "\(date.datestampKey).\(countType.typeKey)"

        self.count = count
        if self.count > countType.maxServings() {
            self.count = countType.maxServings()
            print(":LOG:ERROR: \(date.datestampKey) \(countType.typeKey) \(count) exceeds max servings \(countType.maxServings())")
        }
        self.streak = streak
    }
    
    // MARK: - Meta Information
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /// properties to be indexed
    override class func indexedProperties() -> [String] {
        return ["datestampKey", "typeKey"]
    }
        
    // MARK: - Data Presentation Methods
    
    func title() -> String {
        guard let tmp = DataCountType(rawValue: self.keyStrings.typeKey) else {
            return "Undefined Title (Error)" 
        }
        return tmp.title()
    }
    
    // MARK: - Data Management Methods
    
    func setCount(text: String) {
        if let value = Int(text) {
            setCount(value)
        } else {
            print(":ERROR: setCount() not convertable to Int \(text)")
        }
    }
    
    func setCount(_ count: Int) {
        self.count = count
        if let countType = keys?.countType {
            if self.count > countType.maxServings() {
                self.count = countType.maxServings()
                print(":ERROR: \(id) \(count) exceeds max servings")
            }
        } else {
            print(":ERROR: \(id) \(count) could not range check servings")
        }
    }
    
}
