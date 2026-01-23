//
//  MigrationManager.swift
//  DailyDozen/Database
//
//  Copyright © 2025-2026 NutritionFacts.org. All rights reserved.
//

import SwiftUI

@MainActor
@Observable
final class MigrationManager {
    static let shared = MigrationManager()
        
    var migrationProgress: Double = 0.0
    var isComplete: Bool = false
    
    private init() {
        print("•INFO•DB•WATCH• MigrationManager init() \(Date().datestampyyyyMMddHHmmssSSS)")
        if isRealmDatabaseVersion3Present() {
            isComplete = false
        } else {
            isComplete = true // no Realm data to migrate
        }
    }

    func isRealmDatabaseVersion3Present() -> Bool {
        let fm = FileManager.default
        let realmURL = URL.inDatabase(filename: "NutritionFacts.realm")
        return fm.fileExists(atPath: realmURL.path)
    }

    func performMigrationIfNeeded() async {
        print("•INFO•DB•WATCH• MigrationManager performMigrationIfNeeded()")
        guard !isComplete, isRealmDatabaseVersion3Present() else { return }

        migrationProgress = 0.0
        
        print("•INFO•DB•WATCH• MigrationManager performMigrationIfNeeded() migration started \(Date().datestampyyyyMMddHHmmssSSS)")
        let clock = ContinuousClock()
        let benchmarkStart = clock.now
        
        Task(priority: .background) {
            print("•INFO•DB•WATCH• MigrationManager performMigrationIfNeeded() Task migration started \(Date().datestampyyyyMMddHHmmssSSS)")
            let fm = FileManager.default
            let migrator = RealmMigrator.shared
            let connector = SQLiteConnector.shared
            let realmURL = URL.inDatabase(filename: "NutritionFacts.realm")
            //let sqliteURL = connector.sqliteFilenameUrl

            // Step 1: Generate CSV from Realm (sync, but actor-isolated)
            guard let csvURL = await migrator.generateCSV() // If made async
            else {
                print("•ERROR•DB• Migration failed: CSV generation")
                return
            }
            
            // Step 2: Import CSV and rebuild SQLite (async, mutating)
            do {
                let tempConnector = connector  // Since mutating
                try await tempConnector.performCSVImportAndRebuildBulk(from: csvURL)
                
                // Step 3: Cleanup
                
                // Optional: Delete old Realm file post-success
                try? fm.removeItem(at: realmURL)
                
                UserDefaults.standard.set(true, forKey: "hasMigratedToSQLitev4") // •NYI•
                NotificationCenter.default.post(name: .sqlDBUpdated, object: Date()) // •WATCH•
                print("•INFO•DB•WATCH• MigrationManager migration completed successfully")
            } catch {
                print("•ERROR•DB• MigrationManager migration failed import or rebuild - \(error)")
                // Optional: Cleanup partial CSV // •NYI•
            }
            
            let benchmarkDuration = clock.now - benchmarkStart
            print("•INFO•DB•WATCH• MigrationManager performMigrationIfNeeded() finished \(Date().datestampyyyyMMddHHmmssSSS)")
            print("Total duration: \(benchmarkDuration.formatted(.units(allowed: [.seconds, .milliseconds, .microseconds])))")
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.8)) {
                    migrationProgress = 1.0
                    isComplete = true
                }
            }
        } // Task
    }
    
}
