//
//  SqlDataWeightRecord.swift
//  SQLiteApi/DataSql
//
// SQLite specific snake_case_name mapping
// swiftlint:disable identifier_name 

import Foundation

/// Object Relationship Mapping (ORM) for `dataweight_table`
/// Handles mapping from relationship data and item record object
public struct SqlDataWeightRecord: Codable {
    
    // MARK: - fields
    
    /// yyyy-MM-dd e.g. 2019-01-01 ISO 8601
    public var dataweight_date_psid: String = ""
    /// am/pm typeKey where am = 0, pm = 1
    public var dataweight_ampm_pnid: Int = 0
    /// kilograms
    public var dataweight_kg: Double = 0.0
    /// time of day 24-hour "HH:mm" format
    public var dataweight_time: String = ""
    
    /// Canonical `field` (Column) Name Order
    fileprivate enum Column: Int {
        case dataweightDatePsid  = 0
        case dataweightAmpmFnid = 1
        case dataweightKg       = 2
        case dataweightTime     = 3
        
        var idx: Int {self.rawValue}
    }
    
    public var kg: Double { dataweight_kg }
    public var time: String { dataweight_time }
    
    public var kgStr: String {
        if let s = UnitsUtility.regionalKgWeight(fromKg: dataweight_kg, toDecimalDigits: 1) {
            return s
        } else {
            return String(format: "%.1f", dataweight_kg) // fallback if region conversion is nil
        }
    }
    
    public var lbs: Double {
        return dataweight_kg * 2.204623
    }
    
    public var lbsStr: String {
        if let s = UnitsUtility.regionalLbsWeight(fromKg: dataweight_kg, toDecimalDigits: 1) {
            return s
        } else {
            let poundValue = dataweight_kg * 2.204623
            return String(format: "%.1f", poundValue) // fallback if region conversion is nil
        }
    }
    
    // time of day "hh:mm a" format
    // :MIGRATE:SQL: timeAmPm should not be needed with SQL schema
    //var timeAmPm: String {
    //    let fromDateFormatter = DateFormatter()
    //    fromDateFormatter.dateFormat = "HH:mm"
    //    if let fromDate = fromDateFormatter.date(from: dataweight_time) {
    //        let toDateFormatter = DateFormatter()
    //        toDateFormatter.dateFormat = "hh:mm a"
    //        let fromTime: String = toDateFormatter.string(from: fromDate)
    //        return fromTime
    //    }
    //    return ""
    //}
    
    public var datetime: Date? {
        let datestring = "\(dataweight_date_psid)T\(dataweight_time)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm"
        return dateFormatter.date(from: datestring)
    }
    
    // :RENAME:???: pidKeys -> idKeys
    public var pidKeys: (datestampSid: String, typeKey: String) {
        let parts = self.dataweight_date_psid.components(separatedBy: ".")
        return (datestampSid: parts[0], typeKey: parts[1])
    }
    
    // :RENAME:???: pidParts -> idParts
    public var pidParts: (datestamp: Date, weightType: DataWeightType)? {
        guard let date = Date.init(datestampSid: pidKeys.datestampSid),
            let weightType = DataWeightType(typeKey: pidKeys.typeKey) else {
                logit.error(
                    "SqlDataWeightRecord pidParts has invalid datestamp or weightType"
                )
                return nil
        }
        return (datestamp: date, weightType: weightType)
    }
    
    /// Description string for logging. e.g., "20190214•0•am"
    public var idString: String {
        let parts = pidKeys
        return "\(parts.datestampSid)•\(dataweight_ampm_pnid)•\(parts.typeKey)"
    }
    
    // MARK: Class Methods
    
    static func pid(date: Date, weightType: DataWeightType) -> String {
        return "\(date.datestampSid).\(weightType.typeKey)"
    }
    
    static func pidKeys(pid: String) -> (datestampSid: String, typeKey: String) {
        let parts = pid.components(separatedBy: ".")
        return (datestampSid: parts[0], typeKey: parts[1])
    }
    
    // MARK: - Init
    
    /// CSV Initializer: SqlDataWeightRecord :GTD: implement typeKey and typeNid
    public init?(datestampSid: String, typeKey: String, kilograms: String, timeHHmm: String) {
        guard DataWeightType(typeKey: typeKey) != nil,
            Date(datestampSid: datestampSid) != nil,
            let kg = Double(kilograms),
            timeHHmm.contains(":"),
            Int(timeHHmm.dropLast(3)) != nil,
            Int(timeHHmm.dropFirst(3)) != nil
            else {
                return nil
        }
        
        guard let typeNid = DataWeightType(typeKey: typeKey)?.typeNid
        else { return nil }
        
        self.dataweight_date_psid = datestampSid
        self.dataweight_ampm_pnid = typeNid
        self.dataweight_kg = kg
        self.dataweight_time = timeHHmm
    }
    
    public init(date: Date, weightType: DataWeightType, kg: Double) {
        self.dataweight_date_psid = date.datestampSid
        self.dataweight_ampm_pnid = weightType.typeNid
        self.dataweight_kg = kg
        self.dataweight_time = date.datestampHHmm
    }
    
    public init?( row: [Any?], api: SQLiteApi ) {
        guard // required fields
            let datePsid = row[Column.dataweightDatePsid.idx] as? String,
            let kindPfnid = row[Column.dataweightAmpmFnid.idx] as? Int,
            let kg = row[Column.dataweightKg.idx] as? Double,
            let time = row[Column.dataweightTime.idx] as? String
        else {
            return nil
            //var s = ""
            //for a in row {
            //    s.append("\(a ?? "nil")")
            //}
            //
            //throw SQLiteApiError.rowConversionFailed(s)
        }
        
        self.dataweight_date_psid = datePsid
        self.dataweight_ampm_pnid = kindPfnid
        self.dataweight_kg = kg
        self.dataweight_time = time
    }
    
    // MARK: - Realm Meta Information
    
    static func primaryKey() -> String? {
        return "pid"
    }
    
    // MARK: - Data Presentation Methods
    
}
