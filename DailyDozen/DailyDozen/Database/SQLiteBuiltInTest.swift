//
//  SQLiteBuiltInTest.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation
import HealthKit

/// Utilities to support Built-In-Test (BIT).
public struct SQLiteBuiltInTest {
    static public var shared = SQLiteBuiltInTest()
    
    public let hkHealthStore = HKHealthStore()
    
    public func setupInitialState(_ scenario: Int = 1) {
        let isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        LogService.shared.debug(
            """
            >>> :BIT:WAYPOINT: SQLiteBuiltInTest setupInitialState()")
            >>> HKHealthStore.isHealthDataAvailable() \(isHealthDataAvailable)
            
            """)
        
        let realmBIT = RealmBuiltInTest.shared
        switch scenario {
        case 1: // :GTD:01.b: create initial realm database state
            // minimal Realm database initial state, no HealthKit Data
            realmBIT.doGenerateDBHistoryBIT(numberOfDays: 3, defaultDB: false)
        case 2: // :NYI: multi-year Realm database
            // 1095 days, 2190 weight entries
            realmBIT.doGenerateDBHistoryBIT(numberOfDays: 365*3, defaultDB: false)
        case 3: // :NYI: minimal SQLite database
            break
        default:
            break
        }
        
        //HealthManager.shared.exportHKWeight(name: "BIT00")
        
        // :NYI: SQLite database round trip. create, export, clear, export, import first, export
        
        // :NYI: HEALTHKIT doGenerateHKSampleDataBIT()
    }
    
}
