//
//  SqlDataWeightRecord.swift
//  SQLiteFramework/SqlData
//
//  Copyright © 2023-2025 NutritionFacts.org. All rights reserved.
//
// SQLite specific snake_case_name mapping
// swiftlint:disable identifier_name

import Foundation
import SwiftUI

extension String {
    func matches(_ pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression) != nil
    }
}

/// Object Relationship Mapping (ORM) for `dataweight_table`
/// Handles mapping from relationship data and item record object

public struct SqlDataWeightRecord: Codable, Sendable {
    
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
        
        get async {
            if let s = await UnitsUtility.regionalKgWeight(fromKg: dataweight_kg, toDecimalDigits: 1) {
                return s
            } else {
                return String(format: "%.1f", dataweight_kg)
            }
        }
    }
    
    public var lbs: Double {
        return dataweight_kg * 2.204623
    }
    
    public var lbsStr: String {
        get async {
            if let s = await UnitsUtility.regionalLbsWeight(fromKg: dataweight_kg, toDecimalDigits: 1) {
                return s
            } else {
                let poundValue = dataweight_kg * 2.204623
                return String(format: "%.1f", poundValue)
            }
        }
    }
        
    public var datetime: Date? {
        let datestring = "\(dataweight_date_psid)T\(dataweight_time)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm"
        return dateFormatter.date(from: datestring)
    }
    
    public var pidKeys: (datestampSid: String, typeKey: String) {
        let typeKey = dataweight_ampm_pnid == 0 ? "am" : "pm" // Match DataWeightType rawValue
        return (datestampSid: dataweight_date_psid, typeKey: typeKey)
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
        // return (datestampSid: parts[0], typeKey: parts[1])
        return (datestampSid: parts[0], typeKey: parts.count > 1 ? parts[1] : "")
    }
    
    // MARK: - Init
    
    public init?(datestampSid: String, typeKey: String, kilograms: String, timeHHmm: String) {
        guard let weightType = DataWeightType(typeKey: typeKey.lowercased()),
              Date(datestampSid: datestampSid) != nil,
              let kg = Double(kilograms.trimmingCharacters(in: .whitespacesAndNewlines)),
              kg >= 5 && kg <= 400,
              timeHHmm.range(of: #"^([0-1][0-9]|2[0-3]):[0-5][0-9]$"#, options: .regularExpression) != nil
        else {
            print("•Init Error• SqlDataWeightRecord failed: datestampSid=\(datestampSid), typeKey=\(typeKey), kg=\(kilograms), time=\(timeHHmm)")
            return nil
        }
        
        self.dataweight_date_psid = datestampSid
        self.dataweight_ampm_pnid = weightType.typeNid
        
        self.dataweight_kg = kg
        self.dataweight_time = timeHHmm
    }
    
    public init?(importDatestampKey: String, typeKey: String, kilograms: String, timeHHmm: String) {
        guard let weightType = DataWeightType(typeKey: typeKey.lowercased()),
              let date = Date(datestampKey: importDatestampKey),  // Use datestampKey for `yyyyMMdd` "key" format
              let kg = Double(kilograms.trimmingCharacters(in: .whitespacesAndNewlines)),
              kg >= 5 && kg <= 400,
              timeHHmm.range(of: #"^([0-1][0-9]|2[0-3]):[0-5][0-9]$"#, options: .regularExpression) != nil else {
            print("•Init Error• SqlDataWeightRecord failed for import: datestampSid=\(importDatestampKey), typeKey=\(typeKey), kg=\(kilograms), time=\(timeHHmm)")
            return nil
        }
        
        self.dataweight_date_psid = date.datestampSid  // PSID `yyyyMMdd` version
        self.dataweight_ampm_pnid = weightType.typeNid
        self.dataweight_kg = kg
        self.dataweight_time = timeHHmm
    }
    
    public init(date: Date, weightType: DataWeightType, kg: Double) {
        //let typeKey = weightType.typeNid == 0 ? "AM" : "PM"
        self.dataweight_date_psid = date.datestampSid
        self.dataweight_ampm_pnid = weightType.typeNid
        self.dataweight_kg = kg
        self.dataweight_time = date.datestampHHmm
        //self.lbs = UnitsUtility.getLbs(kg: kg)
        // self.lbsStr = String(format: "%.1f", self.lbs)
    }
    
    public init?(row: [Any?]) {
        guard row.count >= 4,
              let datePsid = row[0] as? String,
              Date(datestampSid: datePsid) != nil,
              let ampm = row[1] as? Int,
              ampm == 0 || ampm == 1,
              let kg = row[2] as? Double,
              let time = row[3] as? String,
              time.range(of: #"^[0-2][0-9]:[0-5][0-9]$"#, options: .regularExpression) != nil else {
            return nil
        }
        self.dataweight_date_psid = datePsid // e.g., "2025-08-28"
        self.dataweight_ampm_pnid = ampm // 0 or 1
        self.dataweight_kg = kg
        self.dataweight_time = time
        // self.lbs = UnitsUtility.getLbs(kg: kg)
        // self.lbsStr = String(format: "%.1f", self.lbs)
    }
    
    // MARK: - Realm Meta Information
    
    static func primaryKey() -> String? {
        return "pid"
    }
    
    // MARK: - Data Presentation Methods ()

    // Note: includes version 4.x Additions :v4.x:
    
    public init(date: Date, weightType: DataWeightType, kg: Double, timeHHmm: String? = nil) {
        self.dataweight_date_psid = date.datestampSid
        self.dataweight_ampm_pnid = weightType.typeNid
        self.dataweight_kg = kg
        self.dataweight_time = timeHHmm ?? date.datestampHHmm
    }
    
    public init(date: Date, weightType: DataWeightType, kg: Double, time: Date) {
        self.dataweight_date_psid = date.datestampSid
        self.dataweight_ampm_pnid = weightType.typeNid
        self.dataweight_kg = kg
        self.dataweight_time = time.datestampHHmm  // ← "12:16" String
    }
}

extension SqlDataWeightRecord: Equatable {
    @Sendable
    public static func == (lhs: SqlDataWeightRecord, rhs: SqlDataWeightRecord) -> Bool {
        lhs.dataweight_date_psid == rhs.dataweight_date_psid &&
        lhs.dataweight_ampm_pnid == rhs.dataweight_ampm_pnid &&
        lhs.dataweight_kg == rhs.dataweight_kg &&
        lhs.dataweight_time == rhs.dataweight_time
    }
}

extension SqlDataWeightRecord {
    init(date: Date, weightType: DataWeightType, kg: Double, configure: (inout SqlDataWeightRecord) -> Void) {
        self.init(date: date, weightType: weightType, kg: kg)
        configure(&self)
    }
}
