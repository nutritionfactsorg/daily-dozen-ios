//
//  SqlDailyTracker.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct SqlDailyTracker {
    let date: Date
    // typealias id = Date // :MECz:???:

    var itemsDict: [DataCountType: SqlDataCountRecord]
    // Weight
    var weightAM: SqlDataWeightRecord
    var weightPM: SqlDataWeightRecord
    
    init(date: Date, amTimeHHmm: String? = nil, pmTimeHHmm: String? = nil) {
        self.date = date
        
        itemsDict = [DataCountType: SqlDataCountRecord]()
        for dataCountType in DataCountType.allCases {
            itemsDict[dataCountType] = SqlDataCountRecord(date: date, countType: dataCountType)
        }
        self.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0, timeHHmm: amTimeHHmm ?? Date().datestampHHmm)
        self.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0, timeHHmm: pmTimeHHmm ?? Date().datestampHHmm)
           
    }
    //Pre-Version 4 need to check if there's something lost in updated init
//    init(date: Date, itemsDict: [DataCountType: SqlDataCountRecord], weightAM: SqlDataWeightRecord? = nil, weightPM: SqlDataWeightRecord? = nil) {
//        var a = SqlDailyTracker(date: date)
//        for (key, value) in itemsDict {
//            a.itemsDict[key] = value
//        }
//        if let weightAM {
//            a.weightAM = weightAM
//        }
//        if let weightPM {
//            a.weightPM = weightPM
//        }
//        self = a
//    }
    init(date: Date, itemsDict: [DataCountType: SqlDataCountRecord], weightAM: SqlDataWeightRecord? = nil, weightPM: SqlDataWeightRecord? = nil) {
           self.date = date
           self.itemsDict = itemsDict
           self.weightAM = weightAM ?? SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0, timeHHmm: Date().datestampHHmm)
           self.weightPM = weightPM ?? SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0, timeHHmm: Date().datestampHHmm)
       }
    
    //init added for development early stages
//    
//    init(date: Date, itemsDict: [DataCountType: SqlDataCountRecord]) {
//        self.date = date
//        
//        itemsDict = [DataCountType: SqlDataCountRecord]()
//        for dataCountType in DataCountType.allCases {
//            itemsDict[dataCountType] = SqlDataCountRecord(date: date, countType: dataCountType)
//        }
//        self.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0)
//        self.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0)
//    }
    
    //init?(dateString: String) {
    //    let formatter = DateFormatter()
    //    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    //    
    //    guard let date = formatter.date(from: dateString) else { return nil }
    //
    //    self.date = date
    //    
    //    // // Convert string to Date
    //    //if let date = formatter.date(from: dateString) {
    //    //    print(date) // Will print something like: 2025-03-26 18:19:36 +0000
    //    //} else {
    //    //    print("Failed to convert date string")
    //    //}
    //    
    //    itemsDict = [DataCountType: SqlDataCountRecord]()
    //    for dataCountType in DataCountType.allCases {
    //        itemsDict[dataCountType] = SqlDataCountRecord(date: date, countType: dataCountType)
    //    }
    //    self.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0)
    //    self.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0)
    //}
    
    func setCount(typeKey: DataCountType, countText: String) {
        if let value = Int(countText) {
            setCount(typeKey: typeKey, count: value)
        } else {
            logit.error("SqlDailyTracker setCount() countText \(countText) not convertable")
        }
    }
    
    func setCount(typeKey: DataCountType, count: Int) {
        if var sqlDataCountRecord = itemsDict[typeKey] {
            sqlDataCountRecord.setCount(count)
        } else {
            logit.error("SqlDailyTracker setCount() type not found \(typeKey.typeKey)")
        }
    }
    
    func getPid(typeKey: DataCountType) -> String {
        return "\(date.datestampKey).\(typeKey.typeKey)"
    }
    
}
