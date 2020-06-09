//
//  DataCountType.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

enum DataCountType: String, CaseIterable {
    
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
    
    init?(itemTypeKey: String) {
        self = DataCountType(rawValue: String(itemTypeKey))!
    }
    
    var typeKey: String {
        return self.rawValue
    }
    
    var headingDisplay: String {
        return DataCountAttributes.shared.dict[self]!.headingDisplay
    }
    
    var maxServings: Int {
        return DataCountAttributes.shared.dict[self]!.maxServings
    }
    
    init?(csvHeading: String) {
        let csvHeadingIn = csvHeading
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        for key in DataCountAttributes.shared.dict.keys {
            let csvHeadingAttribute = DataCountAttributes.shared.dict[key]!
                .headingCSV
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .lowercased()
            if csvHeadingIn == csvHeadingAttribute {
                self = key
            }
        }
        return nil
    }
    
    var headingCSV: String {
        return DataCountAttributes.shared.dict[self]!.headingCSV
    }
    
    var imageName: String {
        return "ic_\(self.typeKey)"
    }
    
    /// does not include "other"
    var isDailyDozen: Bool {
        return self.typeKey.prefix(4) == "doze"
    }

    var isOther: Bool {
        return self.typeKey.prefix(5) == "other"
    }

    var isTweak: Bool {
        return self.typeKey.prefix(5) == "tweak"
    }

}
