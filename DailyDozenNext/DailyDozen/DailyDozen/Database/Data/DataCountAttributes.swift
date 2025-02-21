//
//  DataCountAttributes.swift
//  DatabaseMigration
//
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation
import UIKit // CGFloat

struct DataCountAttributes {
    
    struct Attribute {
        let countType: DataCountType
        let headingDisplay: String // :WAS: NSLocalizedString("dozeBeans.heading", …)
        let headingCSV: String
        let goalServings: Int
       // let id: Int
    }
    
    static let shared = DataCountAttributes()

    //TBDz convert NSLocalizedString
    let dict: [DataCountType: Attribute] = [
        // Daily Dozen Servings
        .dozeBeans: Attribute(
            countType: .dozeBeans,
            headingDisplay: String(localized: "dozeBeans.heading"),
            headingCSV: "Beans",
            goalServings: 3),
        .dozeBerries: Attribute(
            countType: .dozeBerries,
            headingDisplay: String(localized: "dozeBerries.heading"),
            headingCSV: "Berries",
            goalServings: 1),
        .dozeFruitsOther: Attribute(
            countType: .dozeFruitsOther,
            headingDisplay: String(localized: "dozeFruitsOther.heading"),
            headingCSV: "Other Fruits",
            goalServings: 3),
        .dozeVegetablesCruciferous: Attribute(
            countType: .dozeVegetablesCruciferous,
            headingDisplay: String(localized: "dozeVegetablesCruciferous.heading"),
            headingCSV: "Cruciferous Vegetables",
            goalServings: 1
           ),
        .dozeGreens: Attribute(
            countType: .dozeGreens,
            headingDisplay: String(localized: "dozeGreens.heading"),
            headingCSV: "Greens",
            goalServings: 2),
        .dozeVegetablesOther: Attribute(
            countType: .dozeVegetablesOther,
            headingDisplay: String(localized: "dozeVegetablesOther.heading"),
            headingCSV: "Other Vegetables",
            goalServings: 2),
        .dozeFlaxseeds: Attribute(
            countType: .dozeFlaxseeds,
            headingDisplay: String(localized: "dozeFlaxseeds.heading"),
            headingCSV: "Flaxseeds",
            goalServings: 1),
        .dozeNuts: Attribute(
            countType: .dozeNuts,
            headingDisplay: String(localized: "dozeNuts.heading"),
            headingCSV: "Nuts",
            goalServings: 1),
        .dozeSpices: Attribute(
            countType: .dozeSpices,
            headingDisplay: String(localized: "dozeSpices.heading"),
            headingCSV: "Spices",
            goalServings: 1),
        .dozeWholeGrains: Attribute(
            countType: .dozeWholeGrains,
            headingDisplay: String(localized: "dozeWholeGrains.heading"),
            headingCSV: "Whole Grains",
            goalServings: 3),
        .dozeBeverages: Attribute(
            countType: .dozeBeverages,
            headingDisplay: String(localized: "dozeBeverages.heading"),
            headingCSV: "Beverages",
            goalServings: 5),
        .dozeExercise: Attribute(
            countType: .dozeExercise,
            headingDisplay: String(localized: "dozeExercise.heading"),
            headingCSV: "Exercise",
            goalServings: SettingsManager.exerciseGamutInt()), // :GTD:[UNITS]: exerciseGamut
        .otherVitaminB12: Attribute(
            countType: .otherVitaminB12,
            headingDisplay: String(localized: "otherVitaminB12.heading"),
            headingCSV: "Vitamin B12",
            goalServings: 1),
        .otherVitaminD: Attribute(
            countType: .otherVitaminD,
            headingDisplay: String(localized: "otherVitaminD.heading"),
            headingCSV: "Vitamin D",
            goalServings: 1),
        .otherOmega3: Attribute(
            countType: .otherOmega3,
            headingDisplay: String(localized: "otherOmega3.heading"),
            headingCSV: "Omega 3",
            goalServings: 1),
        // 21 Tweaks
        .tweakMealWater: Attribute(
            countType: .tweakMealWater,
            headingDisplay: String(localized: "tweakMealWater.heading"),
            headingCSV: "Meal Water",
            goalServings: 3),
        .tweakMealNegCal: Attribute(
            countType: .tweakMealNegCal,
            headingDisplay: String(localized: "tweakMealNegCal.heading"),
            headingCSV: "Meal NegCal",
            goalServings: 3),
        .tweakMealVinegar: Attribute(
            countType: .tweakMealVinegar,
            headingDisplay: String(localized: "tweakMealVinegar.heading"),
            headingCSV: "Meal Vinegar",
            goalServings: 3),
        .tweakMealUndistracted: Attribute(
            countType: .tweakMealUndistracted,
            headingDisplay: String(localized: "tweakMealUndistracted.heading"),
            headingCSV: "Meal Undistracted",
            goalServings: 3),
        .tweakMeal20Minutes: Attribute(
            countType: .tweakMeal20Minutes,
            headingDisplay: String(localized: "tweakMeal20Minutes.heading"),
            headingCSV: "Meal 20 Minutes",
            goalServings: 3),
        .tweakDailyBlackCumin: Attribute(
            countType: .tweakDailyBlackCumin,
            headingDisplay: String(localized: "tweakDailyBlackCumin.heading"),
            headingCSV: "Daily Black Cumin",
            goalServings: 1),
        .tweakDailyGarlic: Attribute(
            countType: .tweakDailyGarlic,
            headingDisplay: String(localized: "tweakDailyGarlic.heading"),
            headingCSV: "Daily Garlic",
            goalServings: 1),
        .tweakDailyGinger: Attribute(
            countType: .tweakDailyGinger,
            headingDisplay: String(localized: "tweakDailyGinger.heading"),
            headingCSV: "Daily Ginger",
            goalServings: 1),
        .tweakDailyNutriYeast: Attribute(
            countType: .tweakDailyNutriYeast,
            headingDisplay: String(localized: "tweakDailyNutriYeast.heading"),
            headingCSV: "Daily NutriYeast",
            goalServings: 1),
        .tweakDailyCumin: Attribute(
            countType: .tweakDailyCumin,
            headingDisplay: String(localized: "tweakDailyCumin.heading"),
            headingCSV: "Daily Cumin",
            goalServings: 2),
        .tweakDailyGreenTea: Attribute(
            countType: .tweakDailyGreenTea,
            headingDisplay: String(localized: "tweakDailyGreenTea.heading"),
            headingCSV: "Daily Green Tea",
            goalServings: 3),
        .tweakDailyHydrate: Attribute(
            countType: .tweakDailyHydrate,
            headingDisplay: String(localized: "tweakDailyHydrate.heading"),
            headingCSV: "Daily Hydrate",
            goalServings: 1),
        .tweakDailyDeflourDiet: Attribute(
            countType: .tweakDailyDeflourDiet,
            headingDisplay: String(localized: "tweakDailyDeflourDiet.heading"),
            headingCSV: "Daily Deflour Diet",
            goalServings: 1),
        .tweakDailyFrontLoad: Attribute(
            countType: .tweakDailyFrontLoad,
            headingDisplay: String(localized: "tweakDailyFrontLoad.heading"),
            headingCSV: "Daily Front-Load",
            goalServings: 1),
        .tweakDailyTimeRestrict: Attribute(
            countType: .tweakDailyTimeRestrict,
            headingDisplay: String(localized: "tweakDailyTimeRestrict.heading"),
            headingCSV: "Daily Time-Restrict",
            goalServings: 1),
        .tweakExerciseTiming: Attribute(
            countType: .tweakExerciseTiming,
            headingDisplay: String(localized: "tweakExerciseTiming.heading"),
            headingCSV: "Exercise Timing",
            goalServings: 1),
        .tweakWeightTwice: Attribute(
            countType: .tweakWeightTwice,
            headingDisplay: String(localized: "tweakWeightTwice.heading"),
            headingCSV: "Weight Twice",
            goalServings: 2),
        .tweakCompleteIntentions: Attribute(
            countType: .tweakCompleteIntentions,
            headingDisplay: String(localized: "tweakCompleteIntentions.heading"),
            headingCSV: "Complete Intentions",
            goalServings: 3),
        .tweakNightlyFast: Attribute(
            countType: .tweakNightlyFast,
            headingDisplay: String(localized: "tweakNightlyFast.heading"),
            headingCSV: "Nightly Fast",
            goalServings: 1),
        .tweakNightlySleep: Attribute(
            countType: .tweakNightlySleep,
            headingDisplay: String(localized: "tweakNightlySleep.heading"),
            headingCSV: "Nightly Sleep",
            goalServings: 1),
        .tweakNightlyTrendelenbrug: Attribute(
            countType: .tweakNightlyTrendelenbrug,
            headingDisplay: String(localized: "tweakNightlyTrendelenbrug.heading"),
            headingCSV: "Nightly Trendelenbrug",
            goalServings: 1)
    ]
    
}
