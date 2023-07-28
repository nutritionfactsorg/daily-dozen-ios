//
//  DataCountAttributes.swift
//  SQLiteApi
//

import Foundation

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
            headingDisplay: NSLocalizedString("dozeBeans.heading", comment: ""),
            headingCSV: "Beans",
            maxServings: 3),
        .dozeBerries: Attribute(
            countType: .dozeBerries,
            headingDisplay: NSLocalizedString("dozeBerries.heading", comment: ""),
            headingCSV: "Berries",
            maxServings: 1),
        .dozeFruitsOther: Attribute(
            countType: .dozeFruitsOther,
            headingDisplay: NSLocalizedString("dozeFruitsOther.heading", comment: ""),
            headingCSV: "Other Fruits",
            maxServings: 3),
        .dozeVegetablesCruciferous: Attribute(
            countType: .dozeVegetablesCruciferous,
            headingDisplay: NSLocalizedString("dozeVegetablesCruciferous.heading", comment: ""),
            headingCSV: "Cruciferous Vegetables",
            maxServings: 1),
        .dozeGreens: Attribute(
            countType: .dozeGreens,
            headingDisplay: NSLocalizedString("dozeGreens.heading", comment: ""),
            headingCSV: "Greens",
            maxServings: 2),
        .dozeVegetablesOther: Attribute(
            countType: .dozeVegetablesOther,
            headingDisplay: NSLocalizedString("dozeVegetablesOther.heading", comment: ""),
            headingCSV: "Other Vegetables",
            maxServings: 2),
        .dozeFlaxseeds: Attribute(
            countType: .dozeFlaxseeds,
            headingDisplay: NSLocalizedString("dozeFlaxseeds.heading", comment: ""),
            headingCSV: "Flaxseeds",
            maxServings: 1),
        .dozeNuts: Attribute(
            countType: .dozeNuts,
            headingDisplay: NSLocalizedString("dozeNuts.heading", comment: ""),
            headingCSV: "Nuts",
            maxServings: 1),
        .dozeSpices: Attribute(
            countType: .dozeSpices,
            headingDisplay: NSLocalizedString("dozeSpices.heading", comment: ""),
            headingCSV: "Spices",
            maxServings: 1),
        .dozeWholeGrains: Attribute(
            countType: .dozeWholeGrains,
            headingDisplay: NSLocalizedString("dozeWholeGrains.heading", comment: ""),
            headingCSV: "Whole Grains",
            maxServings: 3),
        .dozeBeverages: Attribute(
            countType: .dozeBeverages,
            headingDisplay: NSLocalizedString("dozeBeverages.heading", comment: ""),
            headingCSV: "Beverages",
            maxServings: 5),
        .dozeExercise: Attribute(
            countType: .dozeExercise,
            headingDisplay: NSLocalizedString("dozeExercise.heading", comment: ""),
            headingCSV: "Exercise",
            maxServings: 1),
        .otherVitaminB12: Attribute(
            countType: .otherVitaminB12,
            headingDisplay: NSLocalizedString("otherVitaminB12.heading", comment: ""),
            headingCSV: "Vitamin B12",
            maxServings: 1),
        .otherVitaminD: Attribute(
            countType: .otherVitaminD,
            headingDisplay: NSLocalizedString("otherVitaminD.heading", comment: ""),
            headingCSV: "Vitamin D",
            maxServings: 1),
        .otherOmega3: Attribute(
            countType: .otherOmega3,
            headingDisplay: NSLocalizedString("otherOmega3.heading", comment: ""),
            headingCSV: "Omega 3",
            maxServings: 1),
        // 21 Tweaks
        .tweakMealWater: Attribute(
            countType: .tweakMealWater,
            headingDisplay: NSLocalizedString("tweakMealWater.heading", comment: ""),
            headingCSV: "Meal Water",
            maxServings: 3),
        .tweakMealNegCal: Attribute(
            countType: .tweakMealNegCal,
            headingDisplay: NSLocalizedString("tweakMealNegCal.heading", comment: ""),
            headingCSV: "Meal NegCal",
            maxServings: 3),
        .tweakMealVinegar: Attribute(
            countType: .tweakMealVinegar,
            headingDisplay: NSLocalizedString("tweakMealVinegar.heading", comment: ""),
            headingCSV: "Meal Vinegar",
            maxServings: 3),
        .tweakMealUndistracted: Attribute(
            countType: .tweakMealUndistracted,
            headingDisplay: NSLocalizedString("tweakMealUndistracted.heading", comment: ""),
            headingCSV: "Meal Undistracted",
            maxServings: 3),
        .tweakMeal20Minutes: Attribute(
            countType: .tweakMeal20Minutes,
            headingDisplay: NSLocalizedString("tweakMeal20Minutes.heading", comment: ""),
            headingCSV: "Meal 20 Minutes",
            maxServings: 3),
        .tweakDailyBlackCumin: Attribute(
            countType: .tweakDailyBlackCumin,
            headingDisplay: NSLocalizedString("tweakDailyBlackCumin.heading", comment: ""),
            headingCSV: "Daily Black Cumin",
            maxServings: 1),
        .tweakDailyGarlic: Attribute(
            countType: .tweakDailyGarlic,
            headingDisplay: NSLocalizedString("tweakDailyGarlic.heading", comment: ""),
            headingCSV: "Daily Garlic",
            maxServings: 1),
        .tweakDailyGinger: Attribute(
            countType: .tweakDailyGinger,
            headingDisplay: NSLocalizedString("tweakDailyGinger.heading", comment: ""),
            headingCSV: "Daily Ginger",
            maxServings: 1),
        .tweakDailyNutriYeast: Attribute(
            countType: .tweakDailyNutriYeast,
            headingDisplay: NSLocalizedString("tweakDailyNutriYeast.heading", comment: ""),
            headingCSV: "Daily NutriYeast",
            maxServings: 1),
        .tweakDailyCumin: Attribute(
            countType: .tweakDailyCumin,
            headingDisplay: NSLocalizedString("tweakDailyCumin.heading", comment: ""),
            headingCSV: "Daily Cumin",
            maxServings: 2),
        .tweakDailyGreenTea: Attribute(
            countType: .tweakDailyGreenTea,
            headingDisplay: NSLocalizedString("tweakDailyGreenTea.heading", comment: ""),
            headingCSV: "Daily Green Tea",
            maxServings: 3),
        .tweakDailyHydrate: Attribute(
            countType: .tweakDailyHydrate,
            headingDisplay: NSLocalizedString("tweakDailyHydrate.heading", comment: ""),
            headingCSV: "Daily Hydrate",
            maxServings: 1),
        .tweakDailyDeflourDiet: Attribute(
            countType: .tweakDailyDeflourDiet,
            headingDisplay: NSLocalizedString("tweakDailyDeflourDiet.heading", comment: ""),
            headingCSV: "Daily Deflour Diet",
            maxServings: 1),
        .tweakDailyFrontLoad: Attribute(
            countType: .tweakDailyFrontLoad,
            headingDisplay: NSLocalizedString("tweakDailyFrontLoad.heading", comment: ""),
            headingCSV: "Daily Front-Load",
            maxServings: 1),
        .tweakDailyTimeRestrict: Attribute(
            countType: .tweakDailyTimeRestrict,
            headingDisplay: NSLocalizedString("tweakDailyTimeRestrict.heading", comment: ""),
            headingCSV: "Daily Time-Restrict",
            maxServings: 1),
        .tweakExerciseTiming: Attribute(
            countType: .tweakExerciseTiming,
            headingDisplay: NSLocalizedString("tweakExerciseTiming.heading", comment: ""),
            headingCSV: "Exercise Timing",
            maxServings: 1),
        .tweakWeightTwice: Attribute(
            countType: .tweakWeightTwice,
            headingDisplay: NSLocalizedString("tweakWeightTwice.heading", comment: ""),
            headingCSV: "Weight Twice",
            maxServings: 2),
        .tweakCompleteIntentions: Attribute(
            countType: .tweakCompleteIntentions,
            headingDisplay: NSLocalizedString("tweakCompleteIntentions.heading", comment: ""),
            headingCSV: "Complete Intentions",
            maxServings: 3),
        .tweakNightlyFast: Attribute(
            countType: .tweakNightlyFast,
            headingDisplay: NSLocalizedString("tweakNightlyFast.heading", comment: ""),
            headingCSV: "Nightly Fast",
            maxServings: 1),
        .tweakNightlySleep: Attribute(
            countType: .tweakNightlySleep,
            headingDisplay: NSLocalizedString("tweakNightlySleep.heading", comment: ""),
            headingCSV: "Nightly Sleep",
            maxServings: 1),
        .tweakNightlyTrendelenbrug: Attribute(
            countType: .tweakNightlyTrendelenbrug,
            headingDisplay: NSLocalizedString("tweakNightlyTrendelenbrug.heading", comment: ""),
            headingCSV: "Nightly Trendelenbrug",
            maxServings: 1)
    ]
    

}
