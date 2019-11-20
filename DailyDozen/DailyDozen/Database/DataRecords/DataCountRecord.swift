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
    /// "yyyyMMdd"
    @objc dynamic var datestampKey = ""
    /// "typeKey"
    @objc dynamic var typeKey = ""
    /// daily servings completed
    @objc dynamic var count = 0
    /// consecutive days-to-date with all servings completed
    @objc dynamic var streak = 0
    
    // MARK: Class Methods
    
    static func id(date: Date, type: DataCountType) -> String {
        return "\(date.datestampKey).\(type.typeKey())"
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
        guard let type = DataCountType(typeKey: typeKey),
            Date(datestampKey: datestampKey) != nil else {
            return nil
        }
        
        self.init()
        self.datestampKey = datestampKey
        self.typeKey = typeKey
        self.count = count
        
        if self.count > type.maxServings() {
            self.count = type.maxServings()
            print(":LOG:ERROR: \(self.datestampKey) \(self.typeKey) \(count) exceeded max servings \(type.maxServings())")
        }
        self.streak = streak
        self.id = "\(self.datestampKey).\(self.typeKey)"
    }
    
    convenience init(date: Date, type: DataCountType, count: Int = 0, streak: Int = 0) {
        self.init()
        self.datestampKey = date.datestampKey
        self.typeKey = type.typeKey()
        self.count = count
        if self.count > type.maxServings() {
            self.count = type.maxServings()
            print(":LOG:ERROR: \(self.datestampKey) \(self.typeKey) \(count) exceeds max servings \(type.maxServings())")
        }
        self.streak = streak
        self.id = "\(self.datestampKey).\(self.typeKey)"
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
        guard let tmp = DataCountType(rawValue: self.typeKey) else {
            return "Undefined Title (Error)" 
        }
        return tmp.title()
    }
    
}
