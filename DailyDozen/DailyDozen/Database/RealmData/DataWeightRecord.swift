//
//  DataWeightRecord.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation
import RealmSwift

class DataWeightRecord: Object {
    
    // MARK: - fields
    
    /// yyyyMMdd.typeKey e.g. 20190101.am
    @objc dynamic var pid: String = ""
    /// kilograms
    @objc dynamic var kg: Double = 0.0
    /// time of day 24-hour "HH:mm" format
    @objc dynamic var time: String = ""
    
    var kgStr: String {
        if let s = UnitsUtility.regionalKgWeight(fromKg: kg, toDecimalDigits: 1) {
            return s
        } else {
            return String(format: "%.1f", kg) // fallback if region conversion is nil
        }
    }
    
    var lbs: Double {
        return kg * 2.204623
    }
    
    var lbsStr: String {
        if let s = UnitsUtility.regionalLbsWeight(fromKg: kg, toDecimalDigits: 1) {
            return s
        } else {
            let poundValue = kg * 2.204623
            return String(format: "%.1f", poundValue) // fallback if region conversion is nil
        }
    }
    
    /// time of day "hh:mm a" format
    var timeAmPm: String {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = "HH:mm"
        if let fromDate = fromDateFormatter.date(from: time) {
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = "hh:mm a"
            let fromTime: String = toDateFormatter.string(from: fromDate)
            return fromTime
        }
        return ""
    }
    
    var datetime: Date? {
        let datestring = "\(pid.prefix(8)) \(time)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter.date(from: datestring)
    }
    
    var pidKeys: (datestampKey: String, typeKey: String) {
        let parts = self.pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
    
    var pidParts: (datestamp: Date, weightType: DataWeightType)? {
        guard let date = Date.init(datestampKey: pidKeys.datestampKey),
            let weightType = DataWeightType(typeKey: pidKeys.typeKey) else {
                logit.error(
                    "DataWeightRecord pidParts has invalid datestamp or weightType"
                )
                return nil
        }
        return (datestamp: date, weightType: weightType)
    }
    
    // MARK: Class Methods
    
    static func pid(date: Date, weightType: DataWeightType) -> String {
        return "\(date.datestampKey).\(weightType.typeKey)"
    }
    
    static func pidKeys(pid: String) -> (datestampKey: String, typeKey: String) {
        let parts = pid.components(separatedBy: ".")
        return (datestampKey: parts[0], typeKey: parts[1])
    }
    
    // MARK: - Init
    
    /// CSV Initializer: DataWeightRecord
    convenience init?(datestampKey: String, typeKey: String, kilograms: String, timeHHmm: String) {
        guard DataWeightType(typeKey: typeKey) != nil,
            Date(datestampKey: datestampKey) != nil,
            let kg = Double(kilograms),
            timeHHmm.contains(":"),
            Int(timeHHmm.dropLast(3)) != nil,
            Int(timeHHmm.dropFirst(3)) != nil
            else {
                return nil
        }

        self.init()
        self.pid = "\(datestampKey).\(typeKey)"
        self.kg = kg
        self.time = timeHHmm
    }
    
    convenience init(date: Date, weightType: DataWeightType, kg: Double) {
        self.init()
        self.pid = "\(date.datestampKey).\(weightType.typeKey)"
        self.kg = kg
        self.time = date.datestampHHmm
    }
    
    // MARK: - Realm Meta Information
    
    override static func primaryKey() -> String? {
        return "pid"
    }
    
    // MARK: - Data Presentation Methods
    
}
