//
//  DailyTweaksViewModel.swift
//  DailyDozen
//
//  Created by marc on 2019.11.26.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

class DailyTweaksViewModel {
    
    private let itemTypeArray: [DataCountType] = [
        .tweakMealWater,
        .tweakMealNegCal,
        .tweakMealVinegar,
        .tweakMealUndistracted,
        .tweakMeal20Minutes,
        .tweakDailyBlackCumin,
        .tweakDailyGarlic,
        .tweakDailyGinger,
        .tweakDailyNutriYeast,
        .tweakDailyNutriYeast,
        .tweakDailyGreenTea,
        .tweakDailyHydrate,
        .tweakDailyDeflourDiet,
        .tweakDailyFrontLoad,
        .tweakDailyTimeRestrict,
        .tweakExerciseTiming,
        .tweakWeightTwice,
        .tweakCompleteIntentions,
        .tweakNightlyFast,
        .tweakNightlySleep,
        .tweakNightlyTrendelenbrug
    ]
    
    // MARK: - Properties
    private let tracker: DailyTracker
    
    /// Returns 21 Tweak item count.
    var count: Int {
        return itemTypeArray.count
    }
    
    var trackerDate: Date {
        tracker.date
    }
    
    // MARK: - Inits
    init(tracker: DailyTracker) {
        self.tracker = tracker
    }
    
}
