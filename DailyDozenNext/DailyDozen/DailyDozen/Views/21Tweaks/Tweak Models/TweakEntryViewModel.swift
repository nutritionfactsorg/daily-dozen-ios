//
//  TweakEntryViewModel.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
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
    
    private let tracker: SqlDailyTracker
    
    /// Returns Daily Dozen item count.
    var count: Int {
        return DozeEntryViewModel.rowTypeArray.count
    }
    
    var trackerDate: Date {
        tracker.date
    }
    
    // MARK: - Inits
    init(tracker: SqlDailyTracker) {
        self.tracker = tracker
    }
    
    func itemInfo(rowIndex: Int) -> DataCountType {
        return TweakEntryViewModel.rowTypeArray[rowIndex]
    }
    
    func topicURL(itemTypeKey: String) -> URL {
        let topic = TweakTextsProvider.shared.getTopic(itemTypeKey: itemTypeKey)
        return LinksService.shared.link(topic: topic)
    }
    
//    func itemPid(rowIndex: Int) -> String {
//        let itemType = TweakEntryViewModel.rowTypeArray[rowIndex]
//        return tracker.getPid(typeKey: itemType)
//    }

    /// Returns an image name for the current index.
    ///
    /// - Parameter index: The current table row index.
    /// - Returns: The image name.
    func imageName(rowIndex: Int) -> String {
        return TweakEntryViewModel.rowTypeArray[rowIndex].imageName
    }
    
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

}
