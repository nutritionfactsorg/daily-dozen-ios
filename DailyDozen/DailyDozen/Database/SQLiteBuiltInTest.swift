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
        
        // :GTD:01: create initial realm database state
        
        // CASE:01A: minimal Realm database initial state, no HealthKit
        RealmBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 3, defaultDB: false)
        
        // CASE:01B: multi-year Realm database
        //SQLiteBuiltInTest.shared.doGenerateDBHistoryBIT(numberOfDays: 365*3, defaultDB: false) // 1095 days, 2190 weight entries
        
        // CASE:01C: minimal SQLite database
        
        // CASE:01D: SQLite database round trip. create, export, clear, export, import first, export

        // HEALTHKIT
        //doGenerateHKSampleDataBIT()
    }
    
}
