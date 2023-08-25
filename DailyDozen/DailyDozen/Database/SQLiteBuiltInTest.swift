//
//  SQLiteBuiltInTest.swift
//  DailyDozen
//
//  Created by mc on 8/23/23.
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import HealthKit

/// Utilities to support Built-In-Test (BIT).
public struct SQLiteBuiltInTest {
    static public var shared = SQLiteBuiltInTest()
    
    public let hkHealthStore = HKHealthStore()
    
    public func runSuite() {
        LogService.shared.debug(">>> :DEBUG:WAYPOINT: SQLiteBuiltInTest runSuite()")        
        LogService.shared.debug(">>> HKHealthStore.isHealthDataAvailable() \(HKHealthStore.isHealthDataAvailable())")
        
        //HealthManager.shared.exportHKWeight(name: "BIT00")
        //SQLiteBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 3, defaultDB: false)
        //SQLiteBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 365*3, defaultDB: false) // 1095 days, 2190 weight entries
        
        //doGenerateHKSampleDataBIT()
    }
    
}
