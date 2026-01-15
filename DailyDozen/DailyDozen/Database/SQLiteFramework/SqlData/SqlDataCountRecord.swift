//
//  SqlDataCountRecord.swift
//  SQLiteFramework/SqlData
//
//  Copyright © 2023-2025 NutritionFacts.org. All rights reserved.
//
// SQLite specific snake_case_name mapping
// swiftlint:disable identifier_name

import Foundation
import SwiftUI

/// Object Relationship Mapping (ORM) for `datacount_table`
/// Handles mapping from relationship data and item record object

public struct SqlDataCountRecord: Codable, Sendable {
    
    // MARK: - fields
    
    ///    `datacount_date_psid`  TEXT;     -- yyy-MM-dd ISO 8601
    public var datacount_date_psid: String
    ///    `datacount_kind_pfnid` INTEGER,  -- integer 0=dozeBeans, etc.
    public var datacount_kind_pfnid: Int
    ///    `datacount_count`      INTEGER
    public var datacount_count: Int
    /// Note: v3 DB had `datacount_streak` INTEGER column which is now calculated.
    public var datacountStreakCalc: Int
    
    /// Canonical `field` (Column) Name Order
    fileprivate enum Column: Int {
        case datacountDatePsid  = 0
        case datacountKindPfnid = 1
        case datacountCount     = 2
        
        var idx: Int {self.rawValue}
    }
    
    public var count: Int { datacount_count }
    
    public var idKeys: (datestampSid: String, typeKey: String)? {
        if let typeKey = DataCountType(nid: datacount_kind_pfnid)?.typeKey {
            return (datestampSid: datacount_date_psid, typeKey: typeKey)
        } else {
            return nil
        }
    }
    
    public var idParts: (datestamp: Date, countType: DataCountType)? {
        get async {
            guard let date = Date(datestampSid: datacount_date_psid),
                  let countType = DataCountType(nid: datacount_kind_pfnid) else {
                print("•ERROR• SqlDataCountRecord idParts has invalid datestamp or typeKey")
                return nil
            }
            return (datestamp: date, countType: countType)
        }
    }
    
    /// Description string for logging. e.g., "20190214•0•dozeBeans"
    public var idString: String {
        if let parts = idKeys {
            return "\(parts.datestampSid)•\(datacount_kind_pfnid)•\(parts.typeKey)"
        }
        return "\(datacount_date_psid)•\(datacount_kind_pfnid)•unknown?"
    }
    
    // MARK: Class Methods
    
    static func pid(date: Date, countType: DataCountType) -> String {
        return "\(date.datestampSid).\(countType.typeKey)"
    }
    
    static func pid(datestampSid: String, typeKey: String) -> String {
        return "\(datestampSid).\(typeKey)"
    }
    
    static func pidKeys(pid: String) -> (datestampSid: String, typeKey: String) {
        let parts = pid.components(separatedBy: ".")
        return (datestampSid: parts[0], typeKey: parts[1])
    }
    
    // MARK: - Init
    
    /// CSV Initializer: SqlDataCountRecord
    public init?(datestampSid: String, typeKey: String, count: Int = 0, streak: Int = 0) async {
        guard let dataCountType = DataCountType(itemTypeKey: typeKey),
              Date(datestampSid: datestampSid) != nil else {
            return nil
        }
        
        //self.init()
        datacount_date_psid = datestampSid // YYYYMMDD
        datacount_kind_pfnid = dataCountType.nid
        
        datacount_count = count
        if datacount_count > dataCountType.goalServings {
            datacount_count = dataCountType.goalServings
            print("•ERROR• SqlDataCountRecord init datestampSid:\(datestampSid) typekey:\(typeKey) count:\(count) exceeded max servings \(dataCountType.goalServings)")
        }
        datacountStreakCalc = streak
    }
    
    public init(date: Date, countType: DataCountType, count: Int = 0, streak: Int = 0) {
        //self.init()
        datacount_date_psid = date.datestampSid // `yyyy-MM-dd` (not "key" `yyyyMMdd`)
        datacount_kind_pfnid = countType.nid    // number index
        
        datacount_count = count
        if datacount_count > countType.goalServings {
            datacount_count = countType.goalServings
            // •NYI•GOAL• capability to exceed servings goal
            print(
                "SqlDataCountRecord init date:\(date.datestampSid) countType:\(countType.typeKey) count:\(count) exceeds max servings \(countType.goalServings)"
            )
        }
        datacountStreakCalc = streak
    }
    
    public init?(row: [Any?] ) { // Removed api parameter as it's not used
        guard // required fields
            let datePsid = row[Column.datacountDatePsid.idx] as? String,
            let kindPfnid = row[Column.datacountKindPfnid.idx] as? Int,
            let count = row[Column.datacountCount.idx] as? Int
        else {
            return nil
        }
        
        self.datacount_date_psid = datePsid
        self.datacount_kind_pfnid = kindPfnid
        self.datacount_count = count
        self.datacountStreakCalc = 0 // Hack for database without stored streak value
    }
    
    // MARK: - Meta Information
    
    static func primaryKey() -> String? {
        return "pid"
    }
    
    // MARK: - Data Presentation Methods
    
    func title() -> String {
        guard let tmp = DataCountType(nid: self.datacount_kind_pfnid) else {
            return "Undefined Title (Error)"
        }
        return tmp.headingDisplay
    }
    
    // MARK: - Data Management Methods
    
    mutating func setCount(text: String) async {
        if let value = Int(text) {
            await setCount(value)
        } else {
            print("•ERROR• SqlDataCountRecord setCount() not convertable to Int \(text)")
        }
    }
    
    mutating func setCount(_ count: Int) async {
        datacount_count = count
        if let countType = await idParts?.countType {
            if datacount_count > countType.goalServings {
                datacount_count = countType.goalServings
                print("•ERROR• SqlDataCountRecord setCount \(idString)@\(count) exceeds servings goal")
            }
        } else {
            print("•ERROR• SqlDataCountRecord setCount \(idString)@\(count) could not range check servings")
        }
    }
}

extension SqlDataCountRecord: Equatable {
    public static func == (lhs: SqlDataCountRecord, rhs: SqlDataCountRecord) -> Bool {
        lhs.datacount_date_psid == rhs.datacount_date_psid &&
        lhs.datacount_kind_pfnid == rhs.datacount_kind_pfnid &&
        lhs.datacount_count == rhs.datacount_count &&
        lhs.datacountStreakCalc == rhs.datacountStreakCalc
    }
}
