//
//  DataCount1Record.swift
//  SQLiteApi
//

import Foundation
import LogService

/// Object Relationship Mapping (ORM)
/// Handles mapping from relationship data and item record object 
public struct DataCount1Record: Codable {
    
    // MARK: - fields
    
    ///    datacount_date_psid  TEXT;     -- YYYYMMDD
    public var datacount_date_psid: String
    ///    datacount_kind_pfnid INTEGER,  -- integer 0=dozeBeans, etc.
    public var datacount_kind_pfnid: Int
    ///    datacount_count      INTEGER
    public var datacount_count: Int
    ///    datacount_streak     INTEGER
    public var datacount_streak: Int
    
    // "\(datacount_kind_pfnid).\(dataCountType.typeKey)"
    // 20190214.dozeBeans
    public var pid: String // :TBD: refactor to string id `sid`
    
    public var pidKeys: (datestampKey: String, typeKey: String) {
        let parts = self.pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }

    public var pidParts: (datestamp: Date, countType: DataCountType)? {
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
    public init?(datestampKey: String, typeKey: String, count: Int = 0, streak: Int = 0) {
        guard let dataCountType = DataCountType(itemTypeKey: typeKey),
            Date(datestampKey: datestampKey) != nil else {
            return nil
        }
        
        //self.init()
        datacount_date_psid = datestampKey // YYYYMMDD
        datacount_kind_pfnid = dataCountType.nid

        datacount_count = count
        if datacount_count > dataCountType.maxServings {
            datacount_count = dataCountType.maxServings
            LogService.shared.error(
                "DataCountRecord init datestampKey:\(datestampKey) typekey:\(typeKey) count:\(count) exceeded max servings \(dataCountType.maxServings)"
            )

        }
        datacount_streak = streak
        
        self.pid = "\(datacount_kind_pfnid).\(dataCountType.typeKey)"
    }
    
    public init(date: Date, countType: DataCountType, count: Int = 0, streak: Int = 0) {
        //self.init()
        datacount_date_psid = date.datestampKey // YYYYMMDD
        datacount_kind_pfnid = countType.nid    // number index
        
        datacount_count = count
        if datacount_count > countType.maxServings {
            datacount_count = countType.maxServings
            LogService.shared.error(
                "DataCountRecord init date:\(date.datestampKey) countType:\(countType.typeKey) count:\(count) exceeds max servings \(countType.maxServings)"
            )
        }
        datacount_streak = streak
        
        self.pid = "\(datacount_kind_pfnid).\(countType.typeKey)"
    }
    
    // MARK: - Meta Information
    
    static func primaryKey() -> String? {
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
    
    mutating func setCount(text: String) {
        if let value = Int(text) {
            setCount(value)
        } else {
            LogService.shared.error(
                "DataCountRecord setCount() not convertable to Int \(text)"
            )
        }
    }
    
    mutating func setCount(_ count: Int) {
        datacount_count = count
        if let countType = pidParts?.countType {
            if datacount_count > countType.maxServings {
                datacount_count = countType.maxServings
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
