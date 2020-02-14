//
//  DailyTweaksViewModel.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

class DailyTweaksViewModel {
    
    static let rowTypeArray: [DataCountType] = [
        .tweakMealWater,
        .tweakMealNegCal,
        .tweakMealVinegar,
        .tweakMealUndistracted,
        .tweakMeal20Minutes,
        .tweakDailyBlackCumin,
        .tweakDailyGarlic,
        .tweakDailyGinger,
        .tweakDailyNutriYeast,
        .tweakDailyCumin,
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
        return DailyTweaksViewModel.rowTypeArray.count
    }
    
    var trackerDate: Date {
        tracker.date
    }
    
    // MARK: - Inits
    init(tracker: DailyTracker) {
        self.tracker = tracker
    }
    
    // MARK: - Methods
    /// Returns an item name and type in the doze for the current index.
    ///
    /// - Parameter index: The current table row index.
    /// - Returns: A tuple with the item heading, image name and supplemental flag.
    func itemInfo(rowIndex: Int) -> (itemType: DataCountType, isSupplemental: Bool) {
        let rowType: DataCountType = DailyTweaksViewModel.rowTypeArray[rowIndex]
        let heading = rowType.headingDisplay
        let isSupplemental = heading.contains("Vitamin")
            || heading.contains("Omega")
        
        return (rowType, isSupplemental)
    }
    
    /// Returns an item streak count for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The streak count.
    func itemStreak(rowIndex: Int) -> Int {
        let itemType = DailyTweaksViewModel.rowTypeArray[rowIndex]
        if let dataCountRecord = tracker.itemsDict[itemType] {
            return dataCountRecord.streak
        } else {
            return 0
        }
    }
    
    /// Returns a url for the current item name.
    ///
    /// - Parameter itemName: The item name.
    /// - Returns: A NutritionFacts topic url.
    func topicURL(itemTypeKey: String) -> URL {
        let topic = TweakTextsProvider.shared.getTopic(itemTypeKey: itemTypeKey)
        return LinksService.shared.link(forTopic: topic)
    }
    
    /// Returns item states in the doze for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The states booland array.
    func itemStates(rowIndex: Int) -> [Bool] {
        let rowType = DailyTweaksViewModel.rowTypeArray[rowIndex]
        var states = [Bool](repeating: false, count: rowType.maxServings)
        if let count = tracker.itemsDict[rowType]?.count {
            for i in 0..<count {
                states[i] = true
            }
        }
        return states
    }
    
    /// Returns an item type type in the tracker for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The item DataCountType.
    func itemType(rowIndex: Int) -> DataCountType {
        return DailyTweaksViewModel.rowTypeArray[rowIndex]
    }
    
    /// Returns an item type key in the tracker for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The item type key string.
    func itemTypeKey(rowIndex: Int) -> String {
        return DailyTweaksViewModel.rowTypeArray[rowIndex].typeKey
    }

    func itemPid(rowIndex: Int) -> String {
        let itemType = DailyTweaksViewModel.rowTypeArray[rowIndex]
        return tracker.getPid(typeKey: itemType)
    }

    /// Returns an image name for the current index.
    ///
    /// - Parameter index: The current table row index.
    /// - Returns: The image name.
    func imageName(rowIndex: Int) -> String {
        return DailyTweaksViewModel.rowTypeArray[rowIndex].imageName
    }
    
}
