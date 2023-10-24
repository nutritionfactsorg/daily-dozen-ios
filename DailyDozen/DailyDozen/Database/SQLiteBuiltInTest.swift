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
        
    // MARK: - Initial State Management
    
    public enum InitialState {
        /// DB01 RealmProvider  "Documents/NutritionFacts.realm"
        case db01
        /// DB02 RealmProvider  "Library/Database/NutritionFacts.realm"
        case db02
        /// DB03 SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
        case db03
        /// none. deletes any existing database
        case deleteExistingDB
        /// no change to whatever database may or may not be present
        case noop
    }
    
    public func setupInitialState(_ scenario: InitialState) {
        let isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        logit.debug(
            """
            >>> :BIT:WAYPOINT: SQLiteBuiltInTest setupInitialState()")
            >>> HKHealthStore.isHealthDataAvailable() \(isHealthDataAvailable)
            
            """)
        
        // Note: `3*365` is 1095 days, 2190 weight entries
        switch scenario {
        case .db01:
            removeExistingDBs()
            RealmBuiltInTest.shared
                .doGenerateDBHistoryBIT(numberOfDays: 3, inLibDbDir: false)
        case .db02:
            removeExistingDBs()
            RealmBuiltInTest.shared
                .doGenerateDBHistoryBIT(numberOfDays: 3, inLibDbDir: true)
        case .db03:
            removeExistingDBs()
            SQLiteConnector.api.generateHistoryBIT(numberOfDays: 3)
        case .deleteExistingDB:
            removeExistingDBs()
        case .noop:
            break
        }
        
        //HealthManager.shared.exportHKWeight(name: "BIT00")
        
        // :NYI: SQLite database round trip. create, export, clear, export, import first, export
        
        // :NYI: HEALTHKIT doGenerateHKSampleDataBIT()
    }
    
    func removeExistingDBs() {
        let fm = FileManager.default
        
        // DB Version DB01: RealmProvider "Documents/NutritionFacts.realm"
        var url = URL.inDocuments(filename: RealmProvider.realmFilename)
        try? fm.removeItem(at: url)
        try? fm.removeItem(at: url.appendingPathExtension("lock"))
        try? fm.removeItem(at: url.appendingPathExtension("management"))
        
        // DB Version DB02: RealmProvider "LibraryDatabase/NutritionFacts.realm"
        url = URL.inDatabase(filename: RealmProvider.realmFilename)
        try? fm.removeItem(at: url)
        try? fm.removeItem(at: url.appendingPathExtension("lock"))
        try? fm.removeItem(at: url.appendingPathExtension("management"))
        
        // DB Version DB03: SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
        url = URL.inDatabase(filename: SQLiteConnector.sqliteFilename)
        try? fm.removeItem(at: url)
        
        url = URL.inDatabase()
        try? fm.removeItem(at: url)
    }
    
}
