//
//  DBMigrationMaintainer.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation
/// 
///
///
///
///
///
///
///
public struct DBMigrationMaintainer {
    
    static public var shared = DBMigrationMaintainer()
    
    public func doMigration() {
        let level = getMigrationLevel()
        logit.info("➜➜➜ :DEBUG:WAYPOINT: doMigration() DB level=\(level)")
        
        // DB00: RealmProviderLegacy "main.realm" is no longer supported
        
        if level == 1 {
            logit.info(
            """
            ••DB_STATE••MIGRATE_1••BEGIN•• Migration Level == 1
            PRESENT: DB01 RealmProvider  "Documents/NutritionFacts.realm"
             ABSENT: DB02 RealmProvider  "Library/Database/NutritionFacts.realm"
             ABSENT: DB03 SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
            Start migration by relocating DB01 to DB02 …
            """)
            doMigration_B_DB01toDB02()

            logit.info("••DB_STATE••MIGRATE_1•• DB01 moved to DB02. starting DB02 export …")
            let filename = doMigration_C_BD02Export()

            logit.info("••DB_STATE••MIGRATE_1•• DB02 export completed, starting DB03 import …")
            doMigration_D_DB02toDB03(filename: filename)

            logit.info("••DB_STATE••MIGRATE_1•• DB03 import completed. starting DB03 backup export …")
            _ = doMigration_E_BD03Export()

            logit.info("••DB_STATE••MIGRATE_1•••END••• Migration Level == 1 completed.")
        } else if level == 2 {
            logit.info(
            """
            ••DB_STATE••MIGRATE_2••BEGIN•• Migration Level == 2
            PRESENT: DB02 RealmProvider  "Library/Database/NutritionFacts.realm"
             ABSENT: DB03 SQLiteProvider "Library/Database/NutritionFacts.sqlite3"
                     … starting DB02 export.
            """)
            let filename = doMigration_C_BD02Export()
            
            logit.info("••DB_STATE••MIGRATE_2•• DB02 export completed, starting DB03 import …")
            doMigration_D_DB02toDB03(filename: filename)
            
            logit.info("••DB_STATE••MIGRATE_2•• DB03 import completed. starting DB03 backup export …")
            _ = doMigration_E_BD03Export()
            
            logit.info("••DB_STATE••MIGRATE_2•••END••• Migration Level == 2 completed.")
        } else if level == 3 {
            logit.info(
            """
            ••DB_STATE••MIGRATE_3••NO-OP•• Migration Level == 3 (nothing to migration)
            DB03 is either present or will be created by the application
            """)
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
        _ = realmManager.csvExport(marker: "DB02_MigrationB_Moved_Data")
        _ = realmManager.csvExportWeight(marker: "DB02_MigrationB_Moved_Weights")
        HealthSynchronizer.shared.syncWeightExport(marker: "HK02_MigrationB_Moved")
        #endif
        
        // clear and re-sync "NutritionFacts.realm" with HealthKit
        HealthSynchronizer.shared.resetSyncAll()
        
        #if DEBUG
        let realmMngr = RealmManager()
        _ = realmMngr.csvExport(marker: "DB02_MigrationB_Synced_Data")
        _ = realmMngr.csvExportWeight(marker: "DB02_MigrationB_Synced_Weights")
        HealthSynchronizer.shared.syncWeightExport(marker: "HK02_MigrationB_Synced")
        #endif
    }
    
    /// Export BD02 to Library/Backup/
    public func doMigration_C_BD02Export() -> String {
        logit.debug("••BEGIN•• DBMigrationMaintainer doMigration_C_BD02Export()")
        let realmMngr = RealmManager(newThread: true)
        let filename = realmMngr.csvExport(marker: "DB02_MigrationC_Data")
        
        #if DEBUG_NOT
        _ = realmMngr.csvExportWeight(marker: "DB02_MigrationC_Weights")
        HealthSynchronizer.shared.syncWeightExport(marker: "HK02_MigrationC")
        #endif
        
        logit.debug("•••END••• DBMigrationMaintainer doMigration_C_BD02Export()")
        return filename
    }
    
    func doMigration_D_DB02toDB03(filename: String) { // :GTD:C: DB03 Import
        logit.debug("••BEGIN•• DBMigrationMaintainer doMigration_D_DB02toDB03()")
        // Import to SQLite
        var dbConnect = SQLiteConnector.shared
        dbConnect.csvImport(filename: filename)
        logit.debug("•••END••• DBMigrationMaintainer doMigration_D_DB02toDB03()")
    }
    
    func doMigration_E_BD03Export() -> String { // :GTD:D: DB03 export
        logit.debug("••BEGIN•• DBMigrationMaintainer doMigration_E_BD03Export()")
        // Export from SQLite
        let dbConnect = SQLiteConnector.shared
        let filename = dbConnect.csvExport(marker: "DB03_MigrationE_Data", activity: nil)
        logit.debug("•••END••• DBMigrationMaintainer doMigration_E_BD03Export()")
        return filename
    }
}
