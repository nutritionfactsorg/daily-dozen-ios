//
//  SqlDataCountRecord.swift
//  SQLiteApi/DataSql
//
// SQLite specific snake_case_name mapping
// swiftlint:disable identifier_name 

import Foundation

/// Object Relationship Mapping (ORM) for `datacount_table`
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
    
    /// Canonical `field` (Column) Name Order
    fileprivate enum Column: Int {
        case datacountDatePsid  = 0
        case datacountKindPfnid = 1
        case datacountCount     = 2
        case datacountStreak    = 3
        
        var idx: Int {self.rawValue}
    }
    
    public var count: Int { datacount_count }
    
    /// e.g. "20190214.dozeBeans"
    public var idString: String {
        if let parts = idKeys {
            return "\(parts.datestampSid).\(parts.typeKey)"
        }
        return "\(datacount_date_psid).\(datacount_kind_pfnid)?"
    }
    
    public var idKeys: (datestampSid: String, typeKey: String)? {
        if let typeKey = DataCountType(nid: datacount_kind_pfnid)?.typeKey {
            return (datestampSid: datacount_date_psid, typeKey: typeKey)
        } else {
            return nil
        }
    }
    
    public var idParts: (datestamp: Date, countType: DataCountType)? {
        guard let date = Date.init(datestampSid: datacount_date_psid),
            let countType = DataCountType(nid: datacount_kind_pfnid) else {
                logit.error(
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
            logit.error(
                "SqlDataCountRecord init datestampSid:\(datestampSid) typekey:\(typeKey) count:\(count) exceeded max servings \(dataCountType.maxServings)"
            )

        }
        datacount_streak = streak
    }
    
    public init(date: Date, countType: DataCountType, count: Int = 0, streak: Int = 0) {
        //self.init()
        datacount_date_psid = date.datestampSid // YYYYMMDD
        datacount_kind_pfnid = countType.nid    // number index
        
        datacount_count = count
        if datacount_count > countType.maxServings {
            datacount_count = countType.maxServings
            logit.error(
                "SqlDataCountRecord init date:\(date.datestampSid) countType:\(countType.typeKey) count:\(count) exceeds max servings \(countType.maxServings)"
            )
        }
        datacount_streak = streak
    }
    
    public init?( row: [Any?], api: SQLiteApi ) {
        guard // required fields
            let datePsid = row[Column.datacountDatePsid.idx] as? String,
            let kindPfnid = row[Column.datacountKindPfnid.idx] as? Int,
            let count = row[Column.datacountCount.idx] as? Int,
            let streak = row[Column.datacountStreak.idx] as? Int
        else {
            return nil
            //var s = ""
            //for a in row {
            //    s.append("\(a ?? "nil")")
            //}
            //
            //throw SQLiteApiError.rowConversionFailed(s)
        }
        
        self.datacount_date_psid = datePsid
        self.datacount_kind_pfnid = kindPfnid
        self.datacount_count = count
        self.datacount_streak = streak
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
            logit.error(
                "SqlDataCountRecord setCount() not convertable to Int \(text)"
            )
        }
    }
    
    mutating func setCount(_ count: Int) {
        datacount_count = count
        if let countType = idParts?.countType {
            if datacount_count > countType.maxServings {
                datacount_count = countType.maxServings
                logit.error(
                    "SqlDataCountRecord setCount \(idString) \(count) exceeds max servings"
                )
            }
        } else {
            logit.error(
                "SqlDataCountRecord setCount \(idString) \(count) could not range check servings"
            )
        }
    }
}
