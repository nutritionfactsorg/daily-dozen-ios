//
//  SqlDailyTracker.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct SqlDailyTracker {
    
    let date: Date
        
    var itemsDict: [DataCountType: SqlDataCountRecord]
    // Weight
    var weightAM: SqlDataWeightRecord
    var weightPM: SqlDataWeightRecord
    
    init(date: Date) {
        self.date = date
        
        itemsDict = [DataCountType: SqlDataCountRecord]()
        for dataCountType in DataCountType.allCases {
            itemsDict[dataCountType] = SqlDataCountRecord(date: date, countType: dataCountType)
        }
        self.weightAM = SqlDataWeightRecord(date: date, weightType: .am, kg: 0.0)
        self.weightPM = SqlDataWeightRecord(date: date, weightType: .pm, kg: 0.0)
    }
    
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
