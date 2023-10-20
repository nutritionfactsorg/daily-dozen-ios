//
//  RealmDailyTracker.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct RealmDailyTracker {
    
    let date: Date
        
    var itemsDict: [DataCountType: RealmDataCountRecord]
    // Weight
    var weightAM: RealmDataWeightRecord
    var weightPM: RealmDataWeightRecord
    
    let logger = LogService.shared
    
    init(date: Date) {
        self.date = date
        
        itemsDict = [DataCountType: RealmDataCountRecord]()
        for dataCountType in DataCountType.allCases {
            itemsDict[dataCountType] = RealmDataCountRecord(date: date, countType: dataCountType)
        }
        self.weightAM = RealmDataWeightRecord(date: date, weightType: .am, kg: 0.0)
        self.weightPM = RealmDataWeightRecord(date: date, weightType: .pm, kg: 0.0)
    }
    
    func setCount(typeKey: DataCountType, countText: String) {
        if let value = Int(countText) {
            setCount(typeKey: typeKey, count: value)
        } else {
            logger.error("RealmDailyTracker setCount() countText \(countText) not convertable")
        }
    }
    
    func setCount(typeKey: DataCountType, count: Int) {
        if let realmDataCountRecord = itemsDict[typeKey] {
            realmDataCountRecord.setCount(count)
        } else {
            logger.error("RealmDailyTracker setCount() type not found \(typeKey.typeKey)")
        }
    }
    
    func getPid(typeKey: DataCountType) -> String {
        return "\(date.datestampKey).\(typeKey.typeKey)"
    }
    
}
