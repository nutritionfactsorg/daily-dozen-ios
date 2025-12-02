//
//  SqlDailyTracker.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import SwiftUI

//@Sendable
struct SqlDailyTracker: Sendable {
    let date: Date
    // typealias id = Date // :MECz:???:

    var itemsDict: [DataCountType: SqlDataCountRecord]
    // Weight
    var weightAM: SqlDataWeightRecord?
    var weightPM: SqlDataWeightRecord?
    
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
    init(date: Date, amTimeHHmm: String? = nil, pmTimeHHmm: String? = nil) async {
        self.date = date.startOfDay
        self.itemsDict = await Self.createItemsDict(for: date.startOfDay)
//            self.itemsDict = [DataCountType: SqlDataCountRecord]()
//            for dataCountType in DataCountType.allCases {
//                itemsDict[dataCountType] =  SqlDataCountRecord(date: date, countType: dataCountType)
//            }
            self.weightAM = amTimeHHmm != nil ? SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0, timeHHmm: amTimeHHmm!) : nil
            self.weightPM = pmTimeHHmm != nil ? SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0, timeHHmm: pmTimeHHmm!) : nil
        }
        
        init(date: Date, itemsDict: [DataCountType: SqlDataCountRecord], weightAM: SqlDataWeightRecord? = nil, weightPM: SqlDataWeightRecord? = nil) {
            self.date = date.startOfDay
            self.itemsDict = itemsDict
            self.weightAM = weightAM
            self.weightPM = weightPM
        }
    
//    init(date: Date) {
//        self.date = date.startOfDay
//        self.itemsDict = [:]
//       
//    }
    
    init(date: Date) {
            self.date = date.startOfDay
            self.itemsDict = [:]
            self.weightAM = nil
            self.weightPM = nil
        }
    
    static func createItemsDict(for date: Date) async -> [DataCountType: SqlDataCountRecord] {
            var dict: [DataCountType: SqlDataCountRecord] = [:]
            for dataCountType in DataCountType.allCases {
                dict[dataCountType] = SqlDataCountRecord(date: date, countType: dataCountType)
            }
            return dict
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
    
    mutating func setCount(typeKey: DataCountType, countText: String) async {
        if let value = Int(countText) {
            await setCount(typeKey: typeKey, count: value)
        } else {
            await logit.error("SqlDailyTracker setCount() countText \(countText) not convertable")
        }
    }
    
    mutating func setCount(typeKey: DataCountType, count: Int) async {
            if var sqlDataCountRecord = itemsDict[typeKey] {
                await sqlDataCountRecord.setCount(count)
                itemsDict[typeKey] = sqlDataCountRecord
            } else {
                await logit.error("SqlDailyTracker setCount() type not found \(typeKey.typeKey)")
            }
        }
    
    func getPid(typeKey: DataCountType) -> String {
        return "\(date.datestampKey).\(typeKey.typeKey)"
    }
    
}

extension SqlDailyTracker: Equatable {
    public static func == (lhs: SqlDailyTracker, rhs: SqlDailyTracker) -> Bool {
        // Compare dates (same day)
        guard Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date) else { return false }

        // Compare itemsDict
        guard lhs.itemsDict.keys == rhs.itemsDict.keys else { return false }
        for key in lhs.itemsDict.keys {
            guard let lhsRecord = lhs.itemsDict[key], let rhsRecord = rhs.itemsDict[key],
                  lhsRecord == rhsRecord else {
                return false
            }
        }

        // Compare weightAM
        if let lhsAM = lhs.weightAM, let rhsAM = rhs.weightAM {
            guard lhsAM == rhsAM else { return false }
        } else if lhs.weightAM != nil || rhs.weightAM != nil {
            return false
        }

        // Compare weightPM
        if let lhsPM = lhs.weightPM, let rhsPM = rhs.weightPM {
            guard lhsPM == rhsPM else { return false }
        } else if lhs.weightPM != nil || rhs.weightPM != nil {
            return false
        }

        return true
    }
}
