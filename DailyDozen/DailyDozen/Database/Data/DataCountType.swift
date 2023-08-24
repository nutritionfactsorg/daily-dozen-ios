//
//  DataCountType.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation

public enum DataCountType: String, CaseIterable {
    
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
    
    // MARK: - Provide native integer id `nid`
    
    init?(nid: Int) {
        switch nid {
        case 1: self = DataCountType(rawValue: "dozeBeans")!
        case 2: self = DataCountType(rawValue: "dozeBerries")!
        case 3: self = DataCountType(rawValue: "dozeFruitsOther")!
        case 4: self = DataCountType(rawValue: "dozeVegetablesCruciferous")!
        case 5: self = DataCountType(rawValue: "dozeGreens")!
        case 6: self = DataCountType(rawValue: "dozeVegetablesOther")!
        case 7: self = DataCountType(rawValue: "dozeFlaxseeds")!
        case 8: self = DataCountType(rawValue: "dozeNuts")!
        case 9: self = DataCountType(rawValue: "dozeSpices")!
        case 10: self = DataCountType(rawValue: "dozeWholeGrains")!
        case 11: self = DataCountType(rawValue: "dozeBeverages")!
        case 12: self = DataCountType(rawValue: "dozeExercise")!
            // Daily Dozen Other NIDs
        case 101: self = DataCountType(rawValue: "otherVitaminB12")!
        case 102: self = DataCountType(rawValue: "otherVitaminD")!
        case 103: self = DataCountType(rawValue: "otherOmega3")!
            // 21 Tweaks NIDs
        case 201: self = DataCountType(rawValue: "tweakMealWater")!
        case 202: self = DataCountType(rawValue: "tweakMealNegCal")!
        case 203: self = DataCountType(rawValue: "tweakMealVinegar")!
        case 204: self = DataCountType(rawValue: "tweakMealUndistracted")!
        case 205: self = DataCountType(rawValue: "tweakMeal20Minutes")!
        case 206: self = DataCountType(rawValue: "tweakDailyBlackCumin")!
        case 207: self = DataCountType(rawValue: "tweakDailyGarlic")!
        case 208: self = DataCountType(rawValue: "tweakDailyGinger")!
        case 209: self = DataCountType(rawValue: "tweakDailyNutriYeast")!
        case 210: self = DataCountType(rawValue: "tweakDailyCumin")!
        case 211: self = DataCountType(rawValue: "tweakDailyGreenTea")!
        case 212: self = DataCountType(rawValue: "tweakDailyHydrate")!
        case 213: self = DataCountType(rawValue: "tweakDailyDeflourDiet")!
        case 214: self = DataCountType(rawValue: "tweakDailyFrontLoad")!
        case 215: self = DataCountType(rawValue: "tweakDailyTimeRestrict")!
        case 216: self = DataCountType(rawValue: "tweakExerciseTiming")!
        case 217: self = DataCountType(rawValue: "tweakWeightTwice")!
        case 218: self = DataCountType(rawValue: "tweakCompleteIntentions")!
        case 219: self = DataCountType(rawValue: "tweakNightlyFast")!
        case 220: self = DataCountType(rawValue: "tweakNightlySleep")!
        case 221: self = DataCountType(rawValue: "tweakNightlyTrendelenbrug")!
        default:
            return nil
        }
    }
    
    var nid: Int {
        switch self {
        case .dozeBeans: return 1
        case .dozeBerries: return 2
        case .dozeFruitsOther: return 3
        case .dozeVegetablesCruciferous: return 4
        case .dozeGreens: return 5
        case .dozeVegetablesOther: return 6
        case .dozeFlaxseeds: return 7
        case .dozeNuts: return 8
        case .dozeSpices: return 9
        case .dozeWholeGrains: return 10
        case .dozeBeverages: return 11
        case .dozeExercise: return 12
            // Daily Dozen Other NIDs
        case .otherVitaminB12: return 101
        case .otherVitaminD: return 102
        case .otherOmega3: return 103
            // 21 Tweaks NIDs
        case .tweakMealWater: return 201
        case .tweakMealNegCal: return 202
        case .tweakMealVinegar: return 203
        case .tweakMealUndistracted: return 204
        case .tweakMeal20Minutes: return 205
        case .tweakDailyBlackCumin: return 206
        case .tweakDailyGarlic: return 207
        case .tweakDailyGinger: return 208
        case .tweakDailyNutriYeast: return 209
        case .tweakDailyCumin: return 210
        case .tweakDailyGreenTea: return 211
        case .tweakDailyHydrate: return 212
        case .tweakDailyDeflourDiet: return 213
        case .tweakDailyFrontLoad: return 214
        case .tweakDailyTimeRestrict: return 215
        case .tweakExerciseTiming: return 216
        case .tweakWeightTwice: return 217
        case .tweakCompleteIntentions: return 218
        case .tweakNightlyFast: return 219
        case .tweakNightlySleep: return 220
        case .tweakNightlyTrendelenbrug: return 221
        }
    }
    
}
