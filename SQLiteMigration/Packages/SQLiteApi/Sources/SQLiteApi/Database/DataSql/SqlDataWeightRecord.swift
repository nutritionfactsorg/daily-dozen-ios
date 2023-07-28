//
//  SqlDataWeightRecord.swift
//  SQLiteApi/DataSql
//

import Foundation
import LogService

public struct SqlDataWeightRecord: Codable {
    
    // MARK: - fields
    
    /// yyyy-MM-dd e.g. 2019-01-01 ISO 8601
    public var dataweight_date_psid: String = ""
    /// am/pm typeKey where am = 0, pm = 1
    public var dataweight_ampm_pnid: Int = 0
    /// kilograms
    public dynamic var dataweight_kg: Double = 0.0
    /// time of day 24-hour "HH:mm" format
    public dynamic var dataweight_time: String = ""
    
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
    
    /// time of day "hh:mm a" format
    /// :MIGRATE:SQL: timeAmPm should not be needed with SQL schema
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
    
    public var pidKeys: (datestampSid: String, typeKey: String) {
        let parts = self.dataweight_date_psid.components(separatedBy: ".")
        return (datestampSid: parts[0], typeKey: parts[1])
    }
    
    public var pidParts: (datestamp: Date, weightType: DataWeightType)? {
        guard let date = Date.init(datestampSid: pidKeys.datestampSid),
            let weightType = DataWeightType(typeKey: pidKeys.typeKey) else {
                LogService.shared.error(
                    "DataWeightRecord pidParts has invalid datestamp or weightType"
                )
                return nil
        }
        return (datestamp: date, weightType: weightType)
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
    
    /// CSV Initialer. :GTD: implement typeKey and typeNid
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
    
    // MARK: - Realm Meta Information
    
    static func primaryKey() -> String? {
        return "pid"
    }
    
    // MARK: - Data Presentation Methods
    
}
