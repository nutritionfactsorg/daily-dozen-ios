//
//  DataCountType.swift
//  DatabaseMigration
//
//  Created by marc on 2019.11.08.
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

enum DataCountType: String {
    
    //case date
    //case streak
    // Daily Dozen Servings NIDs (Native IDs)
    case dozeBeans
    case dozeBerries
    case dozeFruitsOther 
    case dozeVegetablesCruciferous 
    case dozeGreens
    case dozeVegetablesOther 
    case dozeFlaxseeds
    case dozeNuts
    case dozeSpices
    case dozeWholeGrains 
    case dozeBeverages
    case dozeExercise
    // Daily Dozen Other NIDs
    case otherVitaminB12
    case otherVitaminD
    case otherOmega3
    // 21 Tweaks NIDs
    case tweakMealWater
    case tweakMealNegCal
    case tweakMealVinegar
    case tweakMealUndistracted
    case tweakMeal20Minutes
    case tweakDailyBlackCumin
    case tweakDailyGarlic
    case tweakDailyGinger
    case tweakDailyNutriYeast
    case tweakDailyCumin
    case tweakDailyGreenTea
    case tweakDailyHydrate
    case tweakDailyDeflourDiet
    case tweakDailyFrontLoad
    case tweakDailyTimeRestrict
    case tweakExerciseTiming
    case tweakWeightTwice
    case tweakCompleteIntentions
    case tweakNightlyFast
    case tweakNightlySleep
    case tweakNightlyTrendelenbrug
    
    init?(typeKey: String) {
        if typeKey.hasSuffix("Key") {
            self = DataCountType(rawValue: String(typeKey.dropLast(3)))!
        }
        return nil
    }
    
    func typeKey() -> String {
        return self.rawValue + "Key"
    }
    
    func title() -> String {
        return DataCountAttributes.shared.dict[self]!.title
    }
    
    func maxServings() -> Int {
        return DataCountAttributes.shared.dict[self]!.maxServings
    }
    
    init?(csvHeading: String) {
        let csvHeadingIn = csvHeading
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        for key in DataCountAttributes.shared.dict.keys {
            let csvHeading = DataCountAttributes.shared.dict[key]!
                .csvHeading
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .lowercased()
            if csvHeadingIn == csvHeading {
                self = key
            }
        }
        return nil
    }
    
    func csvHeading() -> String {
        return DataCountAttributes.shared.dict[self]!.csvHeading
    }

}

extension DataCountType: CaseIterable {}
