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
            headingDisplay: headingString("dozeBeans.heading"),
            headingCSV: "Beans",
            maxServings: 3),
        .dozeBerries: Attribute(
            countType: .dozeBerries,
            headingDisplay: headingString("dozeBerries.heading"),
            headingCSV: "Berries",
            maxServings: 1),
        .dozeFruitsOther: Attribute(
            countType: .dozeFruitsOther,
            headingDisplay: headingString("dozeFruitsOther.heading"),
            headingCSV: "Other Fruits",
            maxServings: 3),
        .dozeVegetablesCruciferous: Attribute(
            countType: .dozeVegetablesCruciferous,
            headingDisplay: headingString("dozeVegetablesCruciferous.heading"),
            headingCSV: "Cruciferous Vegetables",
            maxServings: 1),
        .dozeGreens: Attribute(
            countType: .dozeGreens,
            headingDisplay: headingString("dozeGreens.heading"),
            headingCSV: "Greens",
            maxServings: 2),
        .dozeVegetablesOther: Attribute(
            countType: .dozeVegetablesOther,
            headingDisplay: headingString("dozeVegetablesOther.heading"),
            headingCSV: "Other Vegetables",
            maxServings: 2),
        .dozeFlaxseeds: Attribute(
            countType: .dozeFlaxseeds,
            headingDisplay: headingString("dozeFlaxseeds.heading"),
            headingCSV: "Flaxseeds",
            maxServings: 1),
        .dozeNuts: Attribute(
            countType: .dozeNuts,
            headingDisplay: headingString("dozeNuts.heading"),
            headingCSV: "Nuts",
            maxServings: 1),
        .dozeSpices: Attribute(
            countType: .dozeSpices,
            headingDisplay: headingString("dozeSpices.heading"),
            headingCSV: "Spices",
            maxServings: 1),
        .dozeWholeGrains: Attribute(
            countType: .dozeWholeGrains,
            headingDisplay: headingString("dozeWholeGrains.heading"),
            headingCSV: "Whole Grains",
            maxServings: 3),
        .dozeBeverages: Attribute(
            countType: .dozeBeverages,
            headingDisplay: headingString("dozeBeverages.heading"),
            headingCSV: "Beverages",
            maxServings: 5),
        .dozeExercise: Attribute(
            countType: .dozeExercise,
            headingDisplay: headingString("dozeExercise.heading"),
            headingCSV: "Exercise",
            maxServings: 1),
        .otherVitaminB12: Attribute(
            countType: .otherVitaminB12,
            headingDisplay: headingString("otherVitaminB12.heading"),
            headingCSV: "Vitamin B12",
            maxServings: 1),
        .otherVitaminD: Attribute(
            countType: .otherVitaminD,
            headingDisplay: headingString("otherVitaminD.heading"),
            headingCSV: "Vitamin D",
            maxServings: 1),
        .otherOmega3: Attribute(
            countType: .otherOmega3,
            headingDisplay: headingString("otherOmega3.heading"),
            headingCSV: "Omega 3",
            maxServings: 1),
        // 21 Tweaks
        .tweakMealWater: Attribute(
            countType: .tweakMealWater,
            headingDisplay: headingString("tweakMealWater.heading"),
            headingCSV: "Meal Water",
            maxServings: 3),
        .tweakMealNegCal: Attribute(
            countType: .tweakMealNegCal,
            headingDisplay: headingString("tweakMealNegCal.heading"),
            headingCSV: "Meal NegCal",
            maxServings: 3),
        .tweakMealVinegar: Attribute(
            countType: .tweakMealVinegar,
            headingDisplay: headingString("tweakMealVinegar.heading"),
            headingCSV: "Meal Vinegar",
            maxServings: 3),
        .tweakMealUndistracted: Attribute(
            countType: .tweakMealUndistracted,
            headingDisplay: headingString("tweakMealUndistracted.heading"),
            headingCSV: "Meal Undistracted",
            maxServings: 3),
        .tweakMeal20Minutes: Attribute(
            countType: .tweakMeal20Minutes,
            headingDisplay: headingString("tweakMeal20Minutes.heading"),
            headingCSV: "Meal 20 Minutes",
            maxServings: 3),
        .tweakDailyBlackCumin: Attribute(
            countType: .tweakDailyBlackCumin,
            headingDisplay: headingString("tweakDailyBlackCumin.heading"),
            headingCSV: "Daily Black Cumin",
            maxServings: 1),
        .tweakDailyGarlic: Attribute(
            countType: .tweakDailyGarlic,
            headingDisplay: headingString("tweakDailyGarlic.heading"),
            headingCSV: "Daily Garlic",
            maxServings: 1),
        .tweakDailyGinger: Attribute(
            countType: .tweakDailyGinger,
            headingDisplay: headingString("tweakDailyGinger.heading"),
            headingCSV: "Daily Ginger",
            maxServings: 1),
        .tweakDailyNutriYeast: Attribute(
            countType: .tweakDailyNutriYeast,
            headingDisplay: headingString("tweakDailyNutriYeast.heading"),
            headingCSV: "Daily NutriYeast",
            maxServings: 1),
        .tweakDailyCumin: Attribute(
            countType: .tweakDailyCumin,
            headingDisplay: headingString("tweakDailyCumin.heading"),
            headingCSV: "Daily Cumin",
            maxServings: 2),
        .tweakDailyGreenTea: Attribute(
            countType: .tweakDailyGreenTea,
            headingDisplay: headingString("tweakDailyGreenTea.heading"),
            headingCSV: "Daily Green Tea",
            maxServings: 3),
        .tweakDailyHydrate: Attribute(
            countType: .tweakDailyHydrate,
            headingDisplay: headingString("tweakDailyHydrate.heading"),
            headingCSV: "Daily Hydrate",
            maxServings: 1),
        .tweakDailyDeflourDiet: Attribute(
            countType: .tweakDailyDeflourDiet,
            headingDisplay: headingString("tweakDailyDeflourDiet.heading"),
            headingCSV: "Daily Deflour Diet",
            maxServings: 1),
        .tweakDailyFrontLoad: Attribute(
            countType: .tweakDailyFrontLoad,
            headingDisplay: headingString("tweakDailyFrontLoad.heading"),
            headingCSV: "Daily Front-Load",
            maxServings: 1),
        .tweakDailyTimeRestrict: Attribute(
            countType: .tweakDailyTimeRestrict,
            headingDisplay: headingString("tweakDailyTimeRestrict.heading"),
            headingCSV: "Daily Time-Restrict",
            maxServings: 1),
        .tweakExerciseTiming: Attribute(
            countType: .tweakExerciseTiming,
            headingDisplay: headingString("tweakExerciseTiming.heading"),
            headingCSV: "Exercise Timing",
            maxServings: 1),
        .tweakWeightTwice: Attribute(
            countType: .tweakWeightTwice,
            headingDisplay: headingString("tweakWeightTwice.heading"),
            headingCSV: "Weight Twice",
            maxServings: 2),
        .tweakCompleteIntentions: Attribute(
            countType: .tweakCompleteIntentions,
            headingDisplay: headingString("tweakCompleteIntentions.heading"),
            headingCSV: "Complete Intentions",
            maxServings: 3),
        .tweakNightlyFast: Attribute(
            countType: .tweakNightlyFast,
            headingDisplay: headingString("tweakNightlyFast.heading"),
            headingCSV: "Nightly Fast",
            maxServings: 1),
        .tweakNightlySleep: Attribute(
            countType: .tweakNightlySleep,
            headingDisplay: headingString("tweakNightlySleep.heading"),
            headingCSV: "Nightly Sleep",
            maxServings: 1),
        .tweakNightlyTrendelenbrug: Attribute(
            countType: .tweakNightlyTrendelenbrug,
            headingDisplay: headingString("tweakNightlyTrendelenbrug.heading"),
            headingCSV: "Nightly Trendelenbrug",
            maxServings: 1)
    ]
    
    private func headingString(_ s: String) -> String {
        return NSLocalizedString(s, comment: "heading for daily data entry item")
    }
}
