//
//  SqlDataCountRecord.swift
//  SQLiteApi/DataSql
//
// SQLite specific snake_case_name mapping
// swiftlint:disable identifier_name 

import Foundation

/// Object Relationship Mapping (ORM)
/// Handles mapping from relationship data and item record object 
public struct SqlDataCountRecord: Codable {
    
    // MARK: - fields
    
    ///    `datacount_date_psid`  TEXT;     -- yyy-MM-dd ISO 8601
    public var datacount_date_psid: String
    ///    `datacount_kind_pfnid` INTEGER,  -- integer 0=dozeBeans, etc.
    public var datacount_kind_pfnid: Int
    ///    `datacount_count`      INTEGER
    public var datacount_count: Int
    ///    `datacount_streak`     INTEGER
    public var datacount_streak: Int
    
    public var count: Int { datacount_count }
    
    // "\(datacount_kind_pfnid).\(dataCountType.typeKey)"
    // 20190214.dozeBeans
    public var pid: String // :GTD: refactor to string id `sid`
    
    // :GTD: pidKeys needs to be checked where used … is string still needed?
    public var pidKeys: (datestampSid: String, typeKey: String)? {
        if let typeKey = DataCountType(nid: datacount_kind_pfnid)?.typeKey {
            return (datestampSid: datacount_date_psid, typeKey: typeKey)
        } else {
            return nil
        }
    }
    
    // :GTD: pidParts uses needs check
    public var pidParts: (datestamp: Date, countType: DataCountType)? {
        guard let date = Date.init(datestampSid: datacount_date_psid),
            let countType = DataCountType(nid: datacount_kind_pfnid) else {
                LogService.shared.error(
                    "SqlDataCountRecord pidParts has invalid datestamp or typeKey"
                )
                return nil
        }
        return (datestamp: date, countType: countType)
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
    public init?(datestampSid: String, typeKey: String, count: Int = 0, streak: Int = 0) {
        guard let dataCountType = DataCountType(itemTypeKey: typeKey),
            Date(datestampSid: datestampSid) != nil else {
            return nil
        }
        
        //self.init()
        datacount_date_psid = datestampSid // YYYYMMDD
        datacount_kind_pfnid = dataCountType.nid

        datacount_count = count
        if datacount_count > dataCountType.maxServings {
            datacount_count = dataCountType.maxServings
            LogService.shared.error(
                "SqlDataCountRecord init datestampSid:\(datestampSid) typekey:\(typeKey) count:\(count) exceeded max servings \(dataCountType.maxServings)"
            )

        }
        datacount_streak = streak
        
        self.pid = "\(datacount_kind_pfnid).\(dataCountType.typeKey)"
    }
    
    public init(date: Date, countType: DataCountType, count: Int = 0, streak: Int = 0) {
        //self.init()
        datacount_date_psid = date.datestampSid // YYYYMMDD
        datacount_kind_pfnid = countType.nid    // number index
        
        datacount_count = count
        if datacount_count > countType.maxServings {
            datacount_count = countType.maxServings
            LogService.shared.error(
                "SqlDataCountRecord init date:\(date.datestampSid) countType:\(countType.typeKey) count:\(count) exceeds max servings \(countType.maxServings)"
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
        guard let tmp = DataCountType(nid: self.datacount_kind_pfnid) else {
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
                "SqlDataCountRecord setCount() not convertable to Int \(text)"
            )
        }
    }
    
    mutating func setCount(_ count: Int) {
        datacount_count = count
        if let countType = pidParts?.countType {
            if datacount_count > countType.maxServings {
                datacount_count = countType.maxServings
                LogService.shared.error(
                    "SqlDataCountRecord setCount \(pid) \(count) exceeds max servings"
                )
            }
        } else {
            LogService.shared.error(
                "SqlDataCountRecord setCount \(pid) \(count) could not range check servings"
            )
        }
    }
}
