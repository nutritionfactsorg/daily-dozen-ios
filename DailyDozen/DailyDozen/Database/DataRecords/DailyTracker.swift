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
    // items includes both DailyDozen and Tweaks
    // :TBD: perhaps split DailyDozen and Tweaks
    var itemsDict: [DataCountType: DataCountRecord]
    // Weight
    //var weightAM: DataWeightRecord :NYI:
    //var weightPM: DataWeightRecord :NYI:
    
    init(date: Date = Date()) {
        self.date = date
        
        itemsDict = [DataCountType: DataCountRecord]()
        // Daily Dozen
        itemsDict[.dozeBeans] = DataCountRecord(date: date, type: .dozeBeans)
        itemsDict[.dozeBerries] = DataCountRecord(date: date, type: .dozeBerries)
        itemsDict[.dozeFruitsOther] = DataCountRecord(date: date, type: .dozeFruitsOther)
        itemsDict[.dozeVegetablesCruciferous] = DataCountRecord(date: date, type: .dozeVegetablesCruciferous)
        itemsDict[.dozeGreens] = DataCountRecord(date: date, type: .dozeGreens)
        itemsDict[.dozeVegetablesOther] = DataCountRecord(date: date, type: .dozeVegetablesOther)
        itemsDict[.dozeFlaxseeds] = DataCountRecord(date: date, type: .dozeFlaxseeds)
        itemsDict[.dozeNuts] = DataCountRecord(date: date, type: .dozeNuts)
        itemsDict[.dozeSpices] = DataCountRecord(date: date, type: .dozeSpices)
        itemsDict[.dozeWholeGrains] = DataCountRecord(date: date, type: .dozeWholeGrains)
        itemsDict[.dozeBeverages] = DataCountRecord(date: date, type: .dozeBeverages)
        itemsDict[.dozeExercise] = DataCountRecord(date: date, type: .dozeExercise)
        
        // Daily Dozen Extra
        itemsDict[.otherVitaminB12] = DataCountRecord(date: date, type: .otherVitaminB12)
    }
    
}

extension DailyTracker: Equatable {
    // :!!!: make DailyTracker Equatable for sorting
}
