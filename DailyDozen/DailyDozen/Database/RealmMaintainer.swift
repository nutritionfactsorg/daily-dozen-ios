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
        LogService.shared.debug("→→→ :DEBUG:WAYPOINT: doMigration() level=\(level)")
        
        if level == 1 {
            // V01 is present, but not V02
            // Start migration from V01
            doMigration_B_V02toV03()
            doMigration_C_Backup()
        } else if level == 2 {
            // :GTD:!!!: needs level 2 to level 3 migration 
            // no migration needed.
        } else if level == 3 {
            // no migration needed.
        }
    }
    
    private func getMigrationLevel() -> Int {
        let fm = FileManager.default
        // Check for version V03 SQLite
        if fm.fileExists(atPath: URL.inDatabase(filename: SqliteConnector.sqliteFilename).path) {
            return 3
        }

        // Check for version V02
        if fm.fileExists(atPath: URL.inDatabase(filename: RealmProvider.realmFilename).path) {
            return 2
        }
        
        // Check for version V01
        if fm.fileExists(atPath: URL.inDocuments(filename: RealmProvider.realmFilename).path) {
            return 1
        }
        
        // Check for version Legacy (V00)
        // return 0 -- no longer supported
        
        // Create Libary/Database directory if not present
        let databaseUrl = URL.inLibrary().appendingPathComponent("Database", isDirectory: true)
        do {
            try fm.createDirectory(at: databaseUrl, withIntermediateDirectories: true)
        } catch {
            LogService.shared.error(" \(error)")
        }
        
        // If no realm or sqlite databases are present, 
        // then use the most recent version.
        return 3
    }
    
    /// PreHKSyncRealm
    public func doMigration_B_V02toV03() {
        let fm = FileManager.default
        // Create Libary/Database directory if not present
        let databaseUrl = URL.inLibrary().appendingPathComponent("Database", isDirectory: true)
        do {
            try fm.createDirectory(at: databaseUrl, withIntermediateDirectories: true)
        } catch {
            LogService.shared.error(" \(error)")
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
                LogService.shared.error("doMigration_B_V02toV03 file existance criteria not met.")
                return
        }
        
        do {
            try fm.copyItem(at: fromUrl01, to: toUrl01)
            try fm.copyItem(at: fromUrl02, to: toUrl02)            
            // Directory copy
            try fm.copyItem(at: fromUrl03, to: toUrl03)            
        } catch {
            LogService.shared.error("doMigration_B_V02toV03 '\(error)'")
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
    
    /// Move Documents/* to Library/Backup/
    public func doMigration_C_Backup() {
        LogService.shared.debug(
            "••BEGIN•• UtilityTableViewController doMigration_C_Backup()"
        )
        let fm = FileManager.default        
        let documentsUrl = URL.inDocuments()
        
        var backupUrl = URL.inBackup()
        // Add timestamp subdirectory
        let timestamp = DateManager.currentDatetime().datestampyyyyMMddHHmmss
        backupUrl.appendPathComponent(timestamp, isDirectory: true)
        
        do {
            try fm.createDirectory(at: backupUrl, withIntermediateDirectories: true)
            
            let keys: [URLResourceKey] = [.isDirectoryKey]
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
            let contentUrls = try fm.contentsOfDirectory(
                at: documentsUrl, 
                includingPropertiesForKeys: keys, 
                options: options)
            for fromUrl in contentUrls {
                // skip: leave log* files in Documents/
                if fromUrl.lastPathComponent.hasPrefix("log") ||
                    fromUrl.lastPathComponent.hasSuffix("csv") {
                    continue
                }
                
                let toUrl = backupUrl.appendingPathComponent(fromUrl.lastPathComponent)
                LogService.shared.debug("→→→ from: \(fromUrl)")
                LogService.shared.debug("→→→   to: \(toUrl)")
                // Move file or directory to new location synchronously.
                try fm.moveItem(at: fromUrl, to: toUrl)
            }
                        
        } catch {
            LogService.shared.error(
                "DBMigrationMaintainer doMigration_C_Backup \(error.localizedDescription)"
            )
        }
    
        LogService.shared.debug(
            "••EXIT•• UtilityTableViewController doMigration_C_Backup()"
        )
    }
    
}
