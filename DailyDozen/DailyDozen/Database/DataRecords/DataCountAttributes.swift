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
        let headingDisplay: String
        let headingCSV: String
        let maxServings: Int
    }
    
    static let shared = DataCountAttributes()
    
    let dict: [DataCountType: Attribute] = [
        // Daily Dozen Servings
        .dozeBeans: Attribute(
            countType: .dozeBeans,
            headingDisplay: NSLocalizedString("dozeBeans.heading", comment: "display heading."),
            headingCSV: "Beans",
            maxServings: 3),
        .dozeBerries: Attribute(
            countType: .dozeBerries,
            headingDisplay: NSLocalizedString("dozeBerries.heading", comment: "display heading."),
            headingCSV: "Berries",
            maxServings: 1),
        .dozeFruitsOther: Attribute(
            countType: .dozeFruitsOther,
            headingDisplay: NSLocalizedString("dozeFruitsOther.heading", comment: "display heading"),
            headingCSV: "Other Fruits",
            maxServings: 3),
        .dozeVegetablesCruciferous: Attribute(
            countType: .dozeVegetablesCruciferous,
            headingDisplay: NSLocalizedString("dozeVegetablesCruciferous.heading", comment: "display heading"),
            headingCSV: "Cruciferous Vegetables",
            maxServings: 1),
        .dozeGreens: Attribute(
            countType: .dozeGreens,
            headingDisplay: NSLocalizedString("dozeGreens.heading", comment: "display heading"),
            headingCSV: "Greens",
            maxServings: 2),
        .dozeVegetablesOther: Attribute(
            countType: .dozeVegetablesOther,
            headingDisplay: NSLocalizedString("dozeVegetablesOther.heading", comment: "display heading"),
            headingCSV: "Other Vegetables",
            maxServings: 2),
        .dozeFlaxseeds: Attribute(
            countType: .dozeFlaxseeds,
            headingDisplay: NSLocalizedString("dozeFlaxseeds.heading", comment: "display heading"),
            headingCSV: "Flaxseeds",
            maxServings: 1),
        .dozeNuts: Attribute(
            countType: .dozeNuts,
            headingDisplay: NSLocalizedString("dozeNuts.heading", comment: "display heading"),
            headingCSV: "Nuts",
            maxServings: 1),
        .dozeSpices: Attribute(
            countType: .dozeSpices,
            headingDisplay: NSLocalizedString("dozeSpices.heading", comment: "display heading"),
            headingCSV: "Spices",
            maxServings: 1),
        .dozeWholeGrains: Attribute(
            countType: .dozeWholeGrains,
            headingDisplay: NSLocalizedString("dozeWholeGrains.heading", comment: "display heading"),
            headingCSV: "Whole Grains",
            maxServings: 3),
        .dozeBeverages: Attribute(
            countType: .dozeBeverages,
            headingDisplay: NSLocalizedString("dozeBeverages.heading", comment: "display heading"),
            headingCSV: "Beverages",
            maxServings: 5),
        .dozeExercise: Attribute(
            countType: .dozeExercise,
            headingDisplay: NSLocalizedString("dozeExercise.heading", comment: "display heading"),
            headingCSV: "Exercise",
            maxServings: 1),
        .otherVitaminB12: Attribute(
            countType: .otherVitaminB12,
            headingDisplay: NSLocalizedString("otherVitaminB12.heading", comment: "display heading"),
            headingCSV: "Vitamin B12",
            maxServings: 1),
        .otherVitaminD: Attribute(
            countType: .otherVitaminD,
            headingDisplay: NSLocalizedString("otherVitaminD.heading", comment: "display heading"),
            headingCSV: "Vitamin D",
            maxServings: 1),
        .otherOmega3: Attribute(
            countType: .otherOmega3,
            headingDisplay: NSLocalizedString("otherOmega3.heading", comment: "display heading"),
            headingCSV: "Omega 3",
            maxServings: 1),
        // 21 Tweaks
        .tweakMealWater: Attribute(
            countType: .tweakMealWater,
            headingDisplay: NSLocalizedString("tweakMealWater.heading", comment: "display heading"),
            headingCSV: "Meal Water",
            maxServings: 3),
        .tweakMealNegCal: Attribute(
            countType: .tweakMealNegCal,
            headingDisplay: NSLocalizedString("tweakMealNegCal.heading", comment: "display heading"),
            headingCSV: "Meal NegCal",
            maxServings: 3),
        .tweakMealVinegar: Attribute(
            countType: .tweakMealVinegar,
            headingDisplay: NSLocalizedString("tweakMealVinegar.heading", comment: "display heading"),
            headingCSV: "Meal Vinegar",
            maxServings: 3),
        .tweakMealUndistracted: Attribute(
            countType: .tweakMealUndistracted,
            headingDisplay: NSLocalizedString("tweakMealUndistracted.heading", comment: "display heading"),
            headingCSV: "Meal Undistracted",
            maxServings: 3),
        .tweakMeal20Minutes: Attribute(
            countType: .tweakMeal20Minutes,
            headingDisplay: NSLocalizedString("tweakMeal20Minutes.heading", comment: "display heading"),
            headingCSV: "Meal 20 Minutes",
            maxServings: 3),
        .tweakDailyBlackCumin: Attribute(
            countType: .tweakDailyBlackCumin,
            headingDisplay: NSLocalizedString("tweakDailyBlackCumin.heading", comment: "display heading"),
            headingCSV: "Daily Black Cumin",
            maxServings: 1),
        .tweakDailyGarlic: Attribute(
            countType: .tweakDailyGarlic,
            headingDisplay: NSLocalizedString("tweakDailyGarlic.heading", comment: "display heading"),
            headingCSV: "Daily Garlic",
            maxServings: 1),
        .tweakDailyGinger: Attribute(
            countType: .tweakDailyGinger,
            headingDisplay: NSLocalizedString("tweakDailyGinger.heading", comment: "display heading"),
            headingCSV: "Daily Ginger",
            maxServings: 1),
        .tweakDailyNutriYeast: Attribute(
            countType: .tweakDailyNutriYeast,
            headingDisplay: NSLocalizedString("tweakDailyNutriYeast.heading", comment: "display heading"),
            headingCSV: "Daily NutriYeast",
            maxServings: 1),
        .tweakDailyCumin: Attribute(
            countType: .tweakDailyCumin,
            headingDisplay: NSLocalizedString("tweakDailyCumin.heading", comment: "display heading"),
            headingCSV: "Daily Cumin",
            maxServings: 2),
        .tweakDailyGreenTea: Attribute(
            countType: .tweakDailyGreenTea,
            headingDisplay: NSLocalizedString("tweakDailyGreenTea.heading", comment: "display heading"),
            headingCSV: "Daily Green Tea",
            maxServings: 3),
        .tweakDailyHydrate: Attribute(
            countType: .tweakDailyHydrate,
            headingDisplay: NSLocalizedString("tweakDailyHydrate.heading", comment: "display heading"),
            headingCSV: "Daily Hydrate",
            maxServings: 1),
        .tweakDailyDeflourDiet: Attribute(
            countType: .tweakDailyDeflourDiet,
            headingDisplay: NSLocalizedString("tweakDailyDeflourDiet.heading", comment: "display heading"),
            headingCSV: "Daily Deflour Diet",
            maxServings: 1),
        .tweakDailyFrontLoad: Attribute(
            countType: .tweakDailyFrontLoad,
            headingDisplay: NSLocalizedString("tweakDailyFrontLoad.heading", comment: "display heading"),
            headingCSV: "Daily Front-Load",
            maxServings: 1),
        .tweakDailyTimeRestrict: Attribute(
            countType: .tweakDailyTimeRestrict,
            headingDisplay: NSLocalizedString("tweakDailyTimeRestrict.heading", comment: "display heading"),
            headingCSV: "Daily Time-Restrict",
            maxServings: 1),
        .tweakExerciseTiming: Attribute(
            countType: .tweakExerciseTiming,
            headingDisplay: NSLocalizedString("tweakExerciseTiming.heading", comment: "display heading"),
            headingCSV: "Exercise Timing",
            maxServings: 1),
        .tweakWeightTwice: Attribute(
            countType: .tweakWeightTwice,
            headingDisplay: NSLocalizedString("tweakWeightTwice.heading", comment: "display heading"),
            headingCSV: "Weight Twice",
            maxServings: 2),
        .tweakCompleteIntentions: Attribute(
            countType: .tweakCompleteIntentions,
            headingDisplay: NSLocalizedString("tweakCompleteIntentions.heading", comment: "display heading"),
            headingCSV: "Complete Intentions",
            maxServings: 3),
        .tweakNightlyFast: Attribute(
            countType: .tweakNightlyFast,
            headingDisplay: NSLocalizedString("tweakNightlyFast.heading", comment: "display heading"),
            headingCSV: "Nightly Fast",
            maxServings: 1),
        .tweakNightlySleep: Attribute(
            countType: .tweakNightlySleep,
            headingDisplay: NSLocalizedString("tweakNightlySleep.heading", comment: "display heading"),
            headingCSV: "Nightly Sleep",
            maxServings: 1),
        .tweakNightlyTrendelenbrug: Attribute(
            countType: .tweakNightlyTrendelenbrug,
            headingDisplay: NSLocalizedString("tweakNightlyTrendelenbrug.heading", comment: "display heading"),
            headingCSV: "Nightly Trendelenbrug",
            maxServings: 1)
    ]
    
}
