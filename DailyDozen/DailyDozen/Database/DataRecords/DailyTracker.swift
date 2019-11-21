//
//  DailyTracker.swift
//  DailyDozen
//
//  Created by marc on 2019.11.18.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

// :REPLACES: `Doze`
struct DailyTracker {
    
    var date: Date
    var itemsDict: [DataCountType: DataCountRecord]
    // Weight
    //var weightAM: DataWeightRecord :NYI:
    //var weightPM: DataWeightRecord :NYI:
    
    init(date: Date = Date()) {
        self.date = date
        
        itemsDict = [DataCountType: DataCountRecord]()
        for dataCountType in DataCountType.allCases {
            itemsDict[dataCountType] = DataCountRecord(date: date, type: dataCountType)
        }
    }
}

extension DailyTracker: Equatable {
    // :!!!: make DailyTracker Equatable for sorting
}
