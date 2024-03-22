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
        // case db00 RealmProviderLegacy "main.realm" is no longer supported
        /// DB01 RealmProvider  "Documents/NutritionFacts.realm"
        case db01
        /// DB02 RealmProvider  "Library/Database/NutritionFacts.realm"
        case db02
        /// DB03 SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
        case db03
        /// none. deletes any existing database
        case dbDel
        /// no change to whatever database may or may not be present
        case dbNoop
    }
    
    public func setupInitialState(_ scenario: InitialState, numberOfDays: Int = 3) {
        let isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        logit.info(":: SQLiteBuiltInTest setupInitialState()")
        logit.info(":: HKHealthStore.isHealthDataAvailable() \(isHealthDataAvailable)")
        
        // Note: `3*365` is 1095 days, 2190 weight entries
        switch scenario {
        case .db01:
            logit.info(
                "•• InitialState:db01: Realm Documents/NutritionFacts.realm"
            )
            removeExistingDBs()
            RealmBuiltInTest.shared
                .doGenerateDBHistoryBIT(numberOfDays: numberOfDays, inLibDbDir: false)
        case .db02:
            logit.info(
                "•• InitialState:db02: Realm Library/Database/NutritionFacts.realm"
            )
            removeExistingDBs()
            RealmBuiltInTest.shared
                .doGenerateDBHistoryBIT(numberOfDays: numberOfDays, inLibDbDir: true)
        case .db03:
            logit.info(
                "•• InitialState:db03: SQLite Library/Database/NutritionFacts.sqlite"
            )
            removeExistingDBs()
            let dbConnect = SQLiteConnector.shared
            dbConnect.generateHistoryBIT(numberOfDays: numberOfDays)
        case .dbDel:
            logit.info(
                "•• InitialState:dbDel: delete existing database"
            )
            removeExistingDBs()
        case .dbNoop:
            logit.info(
                "•• InitialState:dbNoop: use existing database, if present"
            )
        }
        
        //HealthManager.shared.exportHKWeight(name: "BIT00")
        
        // :NYI: SQLite database round trip. create, export, clear, export, import first, export
        
        // :NYI: HEALTHKIT doGenerateHKSampleDataBIT()
    }
    
    /// Deletes any existing DB01, DB02, DB03, `Database/` via FileManager
    func removeExistingDBs() {
        logit.info(":: … removeExistingDBs()")
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
