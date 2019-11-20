//
//  DataCountAttributes.swift
//  DatabaseMigration
//
//  Created by marc on 2019.11.08.
//  Copyright © 2019 NutritionFacts.org. All rights reserved.
//

import Foundation

struct DataCountAttributes {
    
    struct Attribute {
        let type: DataCountType
        let title: String
        let csvHeading: String
        let maxServings: Int    
    }
    
    static let shared = DataCountAttributes()
    
    let dict: [DataCountType: Attribute] = [
        //.date: Attribute(
        //    type: .date, 
        //    title: NSLocalizedString("date.title", comment: "display heading"), 
        //    csvHeading: "Date", 
        //    maxServings: 0),
        //.streak: Attribute(
        //    type: .streak,
        //    title: NSLocalizedString("streak.title", comment: "display heading"),
        //    csvHeading: "Streak",
        //    maxServings: 0),
    // Daily Dozen Servings
    .dozeBeans: Attribute(
        type: .dozeBeans,
        title: NSLocalizedString("dozeBeans.title", comment: "display heading."),
        csvHeading: "Beans", 
        maxServings: 3),
    .dozeBerries: Attribute(
        type: .dozeBerries, 
        title: NSLocalizedString("dozeBerries.title", comment: "display heading."),
        csvHeading: "Berries", 
        maxServings: 1),
    .dozeFruitsOther: Attribute(
        type: .dozeFruitsOther,
        title: NSLocalizedString("dozeFruitsOther.title", comment: "display heading"),
        csvHeading: "Other Fruits",
        maxServings: 3),
    .dozeVegetablesCruciferous: Attribute(
        type: .dozeVegetablesCruciferous,
        title: NSLocalizedString("dozeVegetablesCruciferous.title", comment: "display heading"),
        csvHeading: "Cruciferous Vegetables",
        maxServings: 1),
    .dozeGreens: Attribute(
        type: .dozeGreens,
        title: NSLocalizedString("dozeGreens.title", comment: "display heading"),
        csvHeading: "Greens",
        maxServings: 2),
    .dozeVegetablesOther: Attribute(
        type: .dozeVegetablesOther,
        title: NSLocalizedString("dozeVegetablesOther.title", comment: "display heading"),
        csvHeading: "Other Vegetables",
        maxServings: 2),
    .dozeFlaxseeds: Attribute(
        type: .dozeFlaxseeds,
        title: NSLocalizedString("dozeFlaxseeds.title", comment: "display heading"),
        csvHeading: "Flaxseeds",
        maxServings: 1),
    .dozeNuts: Attribute(
        type: .dozeNuts,
        title: NSLocalizedString("dozeNuts.title", comment: "display heading"),
        csvHeading: "Nuts",
        maxServings: 1),
    .dozeSpices: Attribute(
        type: .dozeSpices,
        title: NSLocalizedString("dozeSpices.title", comment: "display heading"),
        csvHeading: "Spices",
        maxServings: 1),
    .dozeWholeGrains: Attribute(
        type: .dozeWholeGrains,
        title: NSLocalizedString("dozeWholeGrains.title", comment: "display heading"),
        csvHeading: "Whole Grains",
        maxServings: 3),
    .dozeBeverages: Attribute(
        type: .dozeBeverages,
        title: NSLocalizedString("dozeBeverages.title", comment: "display heading"),
        csvHeading: "Beverages",
        maxServings: 5),
    .dozeExercise: Attribute(
        type: .dozeExercise,
        title: NSLocalizedString("dozeExercise.title", comment: "display heading"),
        csvHeading: "Exercise",
        maxServings: 1),
    // Daily Dozen Other
    .otherVitaminB12: Attribute(
        type: .otherVitaminB12,
        title: NSLocalizedString("otherVitaminB12.title", comment: "display heading"),
        csvHeading: "Vitamin B12",
        maxServings: 1),
    .otherVitaminD: Attribute(
        type: .otherVitaminD,
        title: NSLocalizedString("otherVitaminD.title", comment: "display heading"),
        csvHeading: "Vitamin D",
        maxServings: 1),
    .otherOmega3: Attribute(
        type: .otherOmega3,
        title: NSLocalizedString("otherOmega3.title", comment: "display heading"),
        csvHeading: "Omega 3",
        maxServings: 1),
    // 21 Tweaks
    .tweakMealWater: Attribute(
        type: .tweakMealWater,
        title: NSLocalizedString("tweakMealWater.title", comment: "display heading"),
        csvHeading: "Meal Water",
        maxServings: 3),
    .tweakMealNegCal: Attribute(
        type: .tweakMealNegCal,
        title: NSLocalizedString("tweakMealNegCal.title", comment: "display heading"),
        csvHeading: "Meal NegCal",
        maxServings: 3),
    .tweakMealVinegar: Attribute(
        type: .tweakMealVinegar,
        title: NSLocalizedString("tweakMealVinegar.title", comment: "display heading"),
        csvHeading: "Meal Vinegar",
        maxServings: 3),
    .tweakMealUndistracted: Attribute(
        type: .tweakMealUndistracted,
        title: NSLocalizedString("tweakMealUndistracted.title", comment: "display heading"),
        csvHeading: "Meal Undistracted",
        maxServings: 3),
    .tweakMeal20Minutes: Attribute(
        type: .tweakMeal20Minutes,
        title: NSLocalizedString("tweakMeal20Minutes.title", comment: "display heading"),
        csvHeading: "Meal 20 Minutes",
        maxServings: 3),
    .tweakDailyBlackCumin: Attribute(
        type: .tweakDailyBlackCumin,
        title: NSLocalizedString("tweakDailyBlackCumin.title", comment: "display heading"),
        csvHeading: "Daily Black Cumin",
        maxServings: 1),
    .tweakDailyGarlic: Attribute(
        type: .tweakDailyGarlic,
        title: NSLocalizedString("tweakDailyGarlic.title", comment: "display heading"),
        csvHeading: "Daily Garlic",
        maxServings: 1),
    .tweakDailyGinger: Attribute(
        type: .tweakDailyGinger,
        title: NSLocalizedString("tweakDailyGinger.title", comment: "display heading"),
        csvHeading: "Daily Ginger",
        maxServings: 1),
    .tweakDailyNutriYeast: Attribute(
        type: .tweakDailyNutriYeast,
        title: NSLocalizedString("tweakDailyNutriYeast.title", comment: "display heading"),
        csvHeading: "Daily NutriYeast",
        maxServings: 1),
    .tweakDailyCumin: Attribute(
        type: .tweakDailyCumin,
        title: NSLocalizedString("tweakDailyCumin.title", comment: "display heading"),
        csvHeading: "Daily Cumin",
        maxServings: 2),
    .tweakDailyGreenTea: Attribute(
        type: .tweakDailyGreenTea,
        title: NSLocalizedString("tweakDailyGreenTea.title", comment: "display heading"),
        csvHeading: "Daily Green Tea",
        maxServings: 3),
    .tweakDailyHydrate: Attribute(
        type: .tweakDailyHydrate,
        title: NSLocalizedString("tweakDailyHydrate.title", comment: "display heading"),
        csvHeading: "Daily Hydrate",
        maxServings: 1),
    .tweakDailyDeflourDiet: Attribute(
        type: .tweakDailyDeflourDiet,
        title: NSLocalizedString("tweakDailyDeflourDiet.title", comment: "display heading"),
        csvHeading: "Daily Deflour Diet",
        maxServings: 1),
    .tweakDailyFrontLoad: Attribute(
        type: .tweakDailyFrontLoad,
        title: NSLocalizedString("tweakDailyFrontLoad.title", comment: "display heading"),
        csvHeading: "Daily Front-Load",
        maxServings: 1),
    .tweakDailyTimeRestrict: Attribute(
        type: .tweakDailyTimeRestrict,
        title: NSLocalizedString("tweakDailyTimeRestrict.title", comment: "display heading"),
        csvHeading: "Daily Time-Restrict",
        maxServings: 1),
    .tweakExerciseTiming: Attribute(
        type: .tweakExerciseTiming,
        title: NSLocalizedString("tweakExerciseTiming.title", comment: "display heading"),
        csvHeading: "Exercise Timing",
        maxServings: 1),
    .tweakWeightTwice: Attribute(
        type: .tweakWeightTwice,
        title: NSLocalizedString("tweakWeightTwice.title", comment: "display heading"),
        csvHeading: "Weight Twice",
        maxServings: 2),
    .tweakCompleteIntentions: Attribute(
        type: .tweakCompleteIntentions,
        title: NSLocalizedString("tweakCompleteIntentions.title", comment: "display heading"),
        csvHeading: "Complete Intentions",
        maxServings: 3),
    .tweakNightlyFast: Attribute(
        type: .tweakNightlyFast,
        title: NSLocalizedString("tweakNightlyFast.title", comment: "display heading"),
        csvHeading: "Nightly Fast",
        maxServings: 1),
    .tweakNightlySleep: Attribute(
        type: .tweakNightlySleep,
        title: NSLocalizedString("tweakNightlySleep.title", comment: "display heading"),
        csvHeading: "Nightly Sleep",
        maxServings: 1),
    .tweakNightlyTrendelenbrug: Attribute(
        type: .tweakNightlyTrendelenbrug,
        title: NSLocalizedString("tweakNightlyTrendelenbrug.title", comment: "display heading"),
        csvHeading: "Nightly Trendelenbrug",
        maxServings: 1),
    ]
    
}
