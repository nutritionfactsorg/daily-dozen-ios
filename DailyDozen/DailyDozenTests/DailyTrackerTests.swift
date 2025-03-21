//
//  DailyTrackerTests.swift
//  DailyDozenTests
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
// "Swift Testing Unit Test" type file

import Foundation
import Testing
@testable import DailyDozen // module

struct DailyTrackerTests {

    @Test func testSqlTracker() async throws {
        let date = Date()
        
        var tracker = SqlDailyTracker(date: date)
        
        // Add count 3 for beans
        let countBeans = SqlDataCountRecord(
            date: date, 
            countType: DataCountType.dozeBeans, 
            count: 3,
            streak: 1
        )
        tracker.itemsDict[.dozeBeans] = countBeans
        
        // add count 1 for greens
        let countGreens = SqlDataCountRecord(
            date: date, 
            countType: DataCountType.dozeGreens, 
            count: 1,
            streak: 1
        )
        tracker.itemsDict[.dozeGreens] = countGreens
        
        // add weight
        tracker.weightAM = SqlDataWeightRecord(
            date: date, 
            weightType: DataWeightType.am,
            kg: 59)
        
        print(tracker)
    }

}
