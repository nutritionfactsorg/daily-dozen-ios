//
//  SqlDailyTracker.swift
//  SQLiteFramework/SqlData
//
//  Copyright © 2023-2025 NutritionFacts.org. All rights reserved.
//

import Foundation
import SwiftUI

struct SqlDailyTracker: Sendable {
    let date: Date
    
    var itemsDict: [DataCountType: SqlDataCountRecord]
    // Weight
    var weightAM: SqlDataWeightRecord?
    var weightPM: SqlDataWeightRecord?
    
    init(date: Date, amTimeHHmm: String? = nil, pmTimeHHmm: String? = nil) async {
        self.date = date.startOfDay
        self.itemsDict = await Self.createItemsDict(for: date.startOfDay)
        self.weightAM = amTimeHHmm != nil ?
        SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0, timeHHmm: amTimeHHmm!) : nil
        
        self.weightPM = pmTimeHHmm != nil ?
        SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0, timeHHmm: pmTimeHHmm!) : nil
    }
    
    init(
        date: Date,
        itemsDict: [DataCountType: SqlDataCountRecord],
        weightAM: SqlDataWeightRecord? = nil,
        weightPM: SqlDataWeightRecord? = nil
    ) {
        self.date = date.startOfDay
        self.itemsDict = itemsDict
        self.weightAM = weightAM
        self.weightPM = weightPM
    }
    
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
    
    mutating func setCount(typeKey: DataCountType, countText: String) async {
        if let value = Int(countText) {
            await setCount(typeKey: typeKey, count: value)
        } else {
            print("•ERROR• SqlDailyTracker setCount() countText \(countText) not convertable")
        }
    }
    
    mutating func setCount(typeKey: DataCountType, count: Int) async {
        if var sqlDataCountRecord = itemsDict[typeKey] {
            await sqlDataCountRecord.setCount(count)
            itemsDict[typeKey] = sqlDataCountRecord
        } else {
            print("•ERROR• SqlDailyTracker setCount() type not found \(typeKey.typeKey)")
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
