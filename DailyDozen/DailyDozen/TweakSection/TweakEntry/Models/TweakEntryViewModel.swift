//
//  TweakEntryViewModel.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

class TweakEntryViewModel {
    
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
    private let tracker: RealmDailyTracker
    
    /// Returns 21 Tweak item count.
    var count: Int {
        return TweakEntryViewModel.rowTypeArray.count
    }
    
    var trackerDate: Date {
        tracker.date
    }
    
    // MARK: - Inits
    init(tracker: RealmDailyTracker) {
        self.tracker = tracker
        logit.debug("@DATE \(tracker.date.datestampKey) TweakEntryViewModel.init()")
    }
    
    // MARK: - Methods
    /// Returns an item name and type in the doze for the current index.
    ///
    /// - Parameter index: The current table row index.
    /// - Returns: DataCountType
    func itemInfo(rowIndex: Int) -> DataCountType {
        return TweakEntryViewModel.rowTypeArray[rowIndex]
    }
    
    /// Returns an item streak count for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The streak count.
    func itemStreak(rowIndex: Int) -> Int {
        let itemType = TweakEntryViewModel.rowTypeArray[rowIndex]
        if let realmDataCountRecord = tracker.itemsDict[itemType] {
            return realmDataCountRecord.streak
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
        return LinksService.shared.link(topic: topic)
    }
    
    /// Returns item states in the doze for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The states booland array.
    func tweakItemStates(rowIndex: Int) -> [Bool] {
        let rowType = TweakEntryViewModel.rowTypeArray[rowIndex]
        var states = [Bool](repeating: false, count: rowType.goalServings)
        if let count = tracker.itemsDict[rowType]?.count {
            for i in 0..<count {
                states[i] = true
            }
        }
        if rowIndex == 16 {
            logit.verbose("# TweakEntryViewModel itemStates \(rowIndex):\(itemPid(rowIndex: rowIndex)) \(states)")
        }
        return states
    }
    
    /// Returns an item type type in the tracker for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The item DataCountType.
    func itemType(rowIndex: Int) -> DataCountType {
        return TweakEntryViewModel.rowTypeArray[rowIndex]
    }
    
    /// Returns an item type key in the tracker for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The item type key string.
    func itemTypeKey(rowIndex: Int) -> String {
        return TweakEntryViewModel.rowTypeArray[rowIndex].typeKey
    }

    func itemPid(rowIndex: Int) -> String {
        let itemType = TweakEntryViewModel.rowTypeArray[rowIndex]
        return tracker.getPid(typeKey: itemType)
    }

    /// Returns an image name for the current index.
    ///
    /// - Parameter index: The current table row index.
    /// - Returns: The image name.
    func imageName(rowIndex: Int) -> String {
        return TweakEntryViewModel.rowTypeArray[rowIndex].imageName
    }
    
}
