//
//  RealmDailyTracker.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct RealmDailyTracker {
    
    let date: Date
        
    var itemsDict: [DataCountType: DataCountRecord]
    // Weight
    var weightAM: DataWeightRecord
    var weightPM: DataWeightRecord
    
    init(date: Date) {
        self.date = date
        
        itemsDict = [DataCountType: DataCountRecord]()
        for dataCountType in DataCountType.allCases {
            itemsDict[dataCountType] = DataCountRecord(date: date, countType: dataCountType)
        }
        self.weightAM = DataWeightRecord(date: date, weightType: .am, kg: 0.0)
        self.weightPM = DataWeightRecord(date: date, weightType: .pm, kg: 0.0)
    }
    
    func setCount(typeKey: DataCountType, countText: String) {
        if let value = Int(countText) {
            setCount(typeKey: typeKey, count: value)
        } else {
            logit.error("RealmDailyTracker setCount() countText \(countText) not convertable")
        }
    }
    
    func setCount(typeKey: DataCountType, count: Int) {
        if let realmDataCountRecord = itemsDict[typeKey] {
            realmDataCountRecord.setCount(count)
        } else {
            logit.error("RealmDailyTracker setCount() type not found \(typeKey.typeKey)")
        }
    }
    
    func getPid(typeKey: DataCountType) -> String {
        return "\(date.datestampKey).\(typeKey.typeKey)"
    }
    
}
