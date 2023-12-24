//
//  DBMigrationMaintainer.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation

public struct DBMigrationMaintainer {
    
    static public var shared = DBMigrationMaintainer()
    
    public func doMigration() {
        let level = getMigrationLevel()
        logit.debug("➜➜➜ :DEBUG:WAYPOINT: doMigration() DB level=\(level)")
        
        // DB00: RealmProviderLegacy "main.realm" is no longer supported
        
        if level == 1 {
            // PRESENT: DB01 RealmProvider  "Documents/NutritionFacts.realm"
            //  ABSENT: DB02 RealmProvider  "Library/Database/NutritionFacts.realm"
            //  ABSENT: DB03 SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
            // Start migration from DB01
            doMigration_B_DB01toDB02()
            let filename = doMigration_C_BD02Export()
            doMigration_D_DB02toDB03(filename: filename)
            _ = doMigration_E_BD03Export()
        } else if level == 2 {
            // PRESENT: DB02 RealmProvider  "Library/Database/NutritionFacts.realm"
            //  ABSENT: DB03 SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
            let filename = doMigration_C_BD02Export()
            doMigration_D_DB02toDB03(filename: filename)
            _ = doMigration_E_BD03Export()
        } else if level == 3 {
            // DB03 is either present or will be created by the application
            logit.debug(":GTD:E: DB03 present or created")
        }
    }
    
    /// Level 1 RealmProvider  `Documents/NutritionFacts.realm.*`
    /// Level 2 RealmProvider  `Library/Database/NutritionFacts.realm.*`
    /// Level 3 SQLiteProvider `Library/Database/NutritionFacts.sqlite3`
    private func getMigrationLevel() -> Int {
        let fm = FileManager.default
        
        // DB Version DB03: SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
        let db03Url = URL.inDatabase(filename: SQLiteConnector.sqliteFilename)
        if fm.fileExists(atPath: db03Url.path) {
            logit.info("""
            Migration Level: 3 SQLiteProvider Library/Database/NutritionFacts.sqlite3 
            """)
            return 3
        }
        
        // DB Version DB02: RealmProvider "Library/Database/NutritionFacts.realm"
        let db02Url = URL.inDatabase(filename: RealmProvider.realmFilename)
        if fm.fileExists(atPath: db02Url.path) {
            logit.info("""
            Migration Level: 2 RealmProvider  `Library/Database/NutritionFacts.realm.*` 
            """)
            return 2
        }
        
        // DB Version DB01: RealmProvider "Documents/NutritionFacts.realm"
        let db01Url = URL.inDocuments(filename: RealmProvider.realmFilename)
        if fm.fileExists(atPath: db01Url.path) {
            logit.info("""
            Migration Level 1 RealmProvider `Documents/NutritionFacts.realm.*`
            """)
            return 1
        }
        
        // DB Version DB00: RealmProviderLegacy "main.realm"
        // DB00 is no longer supported
        
        // Create Library/Database directory if not present
        let databaseUrl = URL.inLibrary()
            .appendingPathComponent("Database", isDirectory: true)
        do {
            try fm.createDirectory(at: databaseUrl, withIntermediateDirectories: true)
        } catch {
            logit.error(" \(error)")
        }
        
        // If no realm or sqlite databases are present, 
        // then use the highest migration level.
        // Application will create a new empty database, if needed.
        logit.info("""
        Migration Level: 3 SQLiteProvider no database present 
        """)
        return 3
    }
    
    /// Move realm database from Documents/ to Library/Database
    public func doMigration_B_DB01toDB02() {
        let fm = FileManager.default
        // Create Library/Database directory if not present
        let databaseUrl = URL.inLibrary()
            .appendingPathComponent("Database", isDirectory: true)
        do {
            try fm.createDirectory(at: databaseUrl, withIntermediateDirectories: true)
        } catch {
            logit.error(" \(error)")
        }

        let fromUrl01 = URL.inDocuments(filename: "NutritionFacts.realm")
        let fromUrl02 = URL.inDocuments(filename: "NutritionFacts.realm.lock")
        let fromUrl03 = URL.inDocuments(filename: "NutritionFacts.realm.management")
        let toUrl01 = URL.inDatabase(filename: "NutritionFacts.realm")
        let toUrl02 = URL.inDatabase(filename: "NutritionFacts.realm.lock")
        let toUrl03 = URL.inDatabase(filename: "NutritionFacts.realm.management")
        
        guard 
            fm.fileExists(atPath: fromUrl01.path),
            fm.fileExists(atPath: fromUrl02.path),
            fm.fileExists(atPath: fromUrl03.path),
            fm.fileExists(atPath: toUrl01.path) == false,
            fm.fileExists(atPath: toUrl02.path) == false,
            fm.fileExists(atPath: toUrl03.path) == false        
            else {
                logit.error("doMigration_B_DB01toDB02 file existance criteria not met.")
                return
        }
        
        do {
            try fm.copyItem(at: fromUrl01, to: toUrl01) // file copy
            try fm.copyItem(at: fromUrl02, to: toUrl02) // file copy
            try fm.copyItem(at: fromUrl03, to: toUrl03) // dir copy
        } catch {
            logit.error("doMigration_B_DB01toDB02 '\(error)'")
        }
        
        #if DEBUG
        let realmManager = RealmManager()
        _ = realmManager.csvExport(marker: "migration_pre_data")
        _ = realmManager.csvExportWeight(marker: "migration_pre_weight")
        HealthSynchronizer.shared.syncWeightExport(marker: "migration_pre_hk_sync")
        #endif
        
        // clear and re-sync "NutritionFacts.realm" with HealthKit
        HealthSynchronizer.shared.resetSyncAll()
    }
    
    /// Export BD02 to Library/Backup/
    public func doMigration_C_BD02Export() -> String {
        logit.debug("••BEGIN•• DBMigrationMaintainer doMigration_C_BD02Export()")
        let realmMngr = RealmManager(newThread: true)
        let filename = realmMngr.csvExport(marker: "db_export_data")
        
        #if DEBUG_NOT
        _ = realmMngr.csvExportWeight(marker: "db_export_weight")
        HealthSynchronizer.shared.syncWeightExport(marker: "hk_export_weight")
        #endif
        
        logit.debug("••EXIT•• DBMigrationMaintainer doMigration_C_BD02Export()")
        return filename
    }
    
    func doMigration_D_DB02toDB03(filename: String) { // :GTD:C: DB03 Import
        logit.debug("••BEGIN•• DBMigrationMaintainer doMigration_D_DB02toDB03()")
        // Import to SQLite
        SQLiteConnector.dot.csvImport(filename: filename)
    }
    
    func doMigration_E_BD03Export() -> String { // :GTD:D: DB03 export
        logit.debug("••BEGIN•• DBMigrationMaintainer doMigration_E_BD03Export()")
        // Export from SQLite
        let filename = SQLiteConnector.dot.csvExport(marker: "migrated", activity: nil)
        return filename
    }
}
