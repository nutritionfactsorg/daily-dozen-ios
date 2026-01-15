//
//  DataCountAttributes.swift
//  Database/Data
//
//  Copyright © 2019-2025 NutritionFacts.org. All rights reserved.
//
// swiftlint:disable function_body_length

import Foundation
import SwiftUI

struct Attribute: Sendable {
    let headingDisplay: String
    let headingCSV: String
    let goalServings: Int
}

struct DataCountAttributesKey: EnvironmentKey {
    static let defaultValue: DataCountAttributes = .shared
}

extension EnvironmentValues {
    var dataCountAttributes: DataCountAttributes {
        get { self[DataCountAttributesKey.self] }
        set { self[DataCountAttributesKey.self] = newValue }
    }
}

struct DataCountAttributes: Sendable {
    
    static let shared = DataCountAttributes()
    
    let dict: [DataCountType: (headingDisplay: String, headingCSV: String, goalServings: Int)]
    
    private init () {
        self.dict =
        // Daily Dozen Servings
        [
            .dozeBeans: (
                // countType: .dozeBeans,
                headingDisplay: String(localized: "dozeBeans.heading"),
                headingCSV: "Beans",
                goalServings: 3),
            .dozeBerries: (
                //countType: .dozeBerries,
                headingDisplay: String(localized: "dozeBerries.heading"),
                headingCSV: "Berries",
                goalServings: 1),
            .dozeFruitsOther: (
                // countType: .dozeFruitsOther,
                headingDisplay: String(localized: "dozeFruitsOther.heading"),
                headingCSV: "Other Fruits",
                goalServings: 3),
            .dozeVegetablesCruciferous: (
                // countType: .dozeVegetablesCruciferous,
                headingDisplay: String(localized: "dozeVegetablesCruciferous.heading"),
                headingCSV: "Cruciferous Vegetables",
                goalServings: 1
            ),
            .dozeGreens: (
                // countType: .dozeGreens,
                headingDisplay: String(localized: "dozeGreens.heading"),
                headingCSV: "Greens",
                goalServings: 2),
            .dozeVegetablesOther: (
                // countType: .dozeVegetablesOther,
                headingDisplay: String(localized: "dozeVegetablesOther.heading"),
                headingCSV: "Other Vegetables",
                goalServings: 2),
            .dozeFlaxseeds: (
                // countType: .dozeFlaxseeds,
                headingDisplay: String(localized: "dozeFlaxseeds.heading"),
                headingCSV: "Flaxseeds",
                goalServings: 1),
            .dozeNuts: (
                // countType: .dozeNuts,
                headingDisplay: String(localized: "dozeNuts.heading"),
                headingCSV: "Nuts",
                goalServings: 1),
            .dozeSpices: (
                // countType: .dozeSpices,
                headingDisplay: String(localized: "dozeSpices.heading"),
                headingCSV: "Spices",
                goalServings: 1),
            .dozeWholeGrains: (
                //countType: .dozeWholeGrains,
                headingDisplay: String(localized: "dozeWholeGrains.heading"),
                headingCSV: "Whole Grains",
                goalServings: 3),
            .dozeBeverages: (
                //countType: .dozeBeverages,
                headingDisplay: String(localized: "dozeBeverages.heading"),
                headingCSV: "Beverages",
                goalServings: 5),
            .dozeExercise: (
                // countType: .dozeExercise,
                headingDisplay: String(localized: "dozeExercise.heading"),
                headingCSV: "Exercise",
                goalServings: 1),   //SettingsManager.exerciseGamutInt()), // :GTD:[GOALS]: exerciseGamut
            .otherVitaminB12: (
                // countType: .otherVitaminB12,
                headingDisplay: String(localized: "otherVitaminB12.heading"),
                headingCSV: "Vitamin B12",
                goalServings: 1),
            .otherVitaminD: (
                //countType: .otherVitaminD,
                headingDisplay: String(localized: "otherVitaminD.heading"),
                headingCSV: "Vitamin D",
                goalServings: 1),
            .otherOmega3: (
                // countType: .otherOmega3,
                headingDisplay: String(localized: "otherOmega3.heading"),
                headingCSV: "Omega 3",
                goalServings: 1),
            // 21 Tweaks
            .tweakMealWater: (
                // countType: .tweakMealWater,
                headingDisplay: String(localized: "tweakMealWater.heading"),
                headingCSV: "Meal Water",
                goalServings: 3),
            .tweakMealNegCal: (
                //countType: .tweakMealNegCal,
                headingDisplay: String(localized: "tweakMealNegCal.heading"),
                headingCSV: "Meal NegCal",
                goalServings: 3),
            .tweakMealVinegar: (
                //  countType: .tweakMealVinegar,
                headingDisplay: String(localized: "tweakMealVinegar.heading"),
                headingCSV: "Meal Vinegar",
                goalServings: 3),
            .tweakMealUndistracted: (
                //  countType: .tweakMealUndistracted,
                headingDisplay: String(localized: "tweakMealUndistracted.heading"),
                headingCSV: "Meal Undistracted",
                goalServings: 3),
            .tweakMeal20Minutes: (
                // countType: .tweakMeal20Minutes,
                headingDisplay: String(localized: "tweakMeal20Minutes.heading"),
                headingCSV: "Meal 20 Minutes",
                goalServings: 3),
            .tweakDailyBlackCumin: (
                //countType: .tweakDailyBlackCumin,
                headingDisplay: String(localized: "tweakDailyBlackCumin.heading"),
                headingCSV: "Daily Black Cumin",
                goalServings: 1),
            .tweakDailyGarlic: (
                // countType: .tweakDailyGarlic,
                headingDisplay: String(localized: "tweakDailyGarlic.heading"),
                headingCSV: "Daily Garlic",
                goalServings: 1),
            .tweakDailyGinger: (
                // countType: .tweakDailyGinger,
                headingDisplay: String(localized: "tweakDailyGinger.heading"),
                headingCSV: "Daily Ginger",
                goalServings: 1),
            .tweakDailyNutriYeast: (
                //countType: .tweakDailyNutriYeast,
                headingDisplay: String(localized: "tweakDailyNutriYeast.heading"),
                headingCSV: "Daily NutriYeast",
                goalServings: 1),
            .tweakDailyCumin: (
                // countType: .tweakDailyCumin,
                headingDisplay: String(localized: "tweakDailyCumin.heading"),
                headingCSV: "Daily Cumin",
                goalServings: 2),
            .tweakDailyGreenTea: (
                // countType: .tweakDailyGreenTea,
                headingDisplay: String(localized: "tweakDailyGreenTea.heading"),
                headingCSV: "Daily Green Tea",
                goalServings: 3),
            .tweakDailyHydrate: (
                // countType: .tweakDailyHydrate,
                headingDisplay: String(localized: "tweakDailyHydrate.heading"),
                headingCSV: "Daily Hydrate",
                goalServings: 1),
            .tweakDailyDeflourDiet: (
                // countType: .tweakDailyDeflourDiet,
                headingDisplay: String(localized: "tweakDailyDeflourDiet.heading"),
                headingCSV: "Daily Deflour Diet",
                goalServings: 1),
            .tweakDailyFrontLoad: (
                // countType: .tweakDailyFrontLoad,
                headingDisplay: String(localized: "tweakDailyFrontLoad.heading"),
                headingCSV: "Daily Front-Load",
                goalServings: 1),
            .tweakDailyTimeRestrict: (
                // countType: .tweakDailyTimeRestrict,
                headingDisplay: String(localized: "tweakDailyTimeRestrict.heading"),
                headingCSV: "Daily Time-Restrict",
                goalServings: 1),
            .tweakExerciseTiming: (
                // countType: .tweakExerciseTiming,
                headingDisplay: String(localized: "tweakExerciseTiming.heading"),
                headingCSV: "Exercise Timing",
                goalServings: 1),
            .tweakWeightTwice: (
                // countType: .tweakWeightTwice,
                headingDisplay: String(localized: "tweakWeightTwice.heading"),
                headingCSV: "Weight Twice",
                goalServings: 2),
            .tweakCompleteIntentions: (
                //  countType: .tweakCompleteIntentions,
                headingDisplay: String(localized: "tweakCompleteIntentions.heading"),
                headingCSV: "Complete Intentions",
                goalServings: 3),
            .tweakNightlyFast: (
                // countType: .tweakNightlyFast,
                headingDisplay: String(localized: "tweakNightlyFast.heading"),
                headingCSV: "Nightly Fast",
                goalServings: 1),
            .tweakNightlySleep: (
                //  countType: .tweakNightlySleep,
                headingDisplay: String(localized: "tweakNightlySleep.heading"),
                headingCSV: "Nightly Sleep",
                goalServings: 1),
            .tweakNightlyTrendelenbrug: (
                // countType: .tweakNightlyTrendelenbrug,
                headingDisplay: String(localized: "tweakNightlyTrendelenbrug.heading"),
                headingCSV: "Nightly Trendelenbrug",
                goalServings: 1)
        ]
    }
    
}
