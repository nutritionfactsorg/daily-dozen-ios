//
//  DailyDozenApp.swift
//  DailyDozen
//
//  Copyright © 2024-2025 NutritionFacts.org. All rights reserved.
//
// swiftlint:disable function_body_length

import SwiftUI
import UserNotifications

@main
struct DailyDozenApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage(SettingsKeys.hasSeenLaunchV4) private var hasSeenTweaks = false
    //    @AppStorage(SettingsKeys.reminderCanNotify) private var reminderCanNotify = false
    //    @AppStorage("hasRequestedNotificationPermission") private var hasRequestedPermission = false
    
    @State private var showingTweaksSheet = false
    
    // @StateObject var viewModel = SqlDailyTrackerViewModel()
    init() {
        
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            if settings.authorizationStatus == .notDetermined {
                do {
                    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                    await MainActor.run {
                        print("Notification permission granted: \(granted)")
                        // You can update @State or @ObservedObject here if needed
                    }
                } catch {
                    await MainActor.run {
                        print("Error requesting notification permission: \(error.localizedDescription)")
                    }
                }
            } else {
                await MainActor.run {
                    print("Current authorization status: \(settings.authorizationStatus.rawValue)")
                    // Optional: Handle .denied or .authorized cases
                }
            }
        }
        UNUserNotificationCenter.current().setBadgeCount(0) // set notification badge count to 0
        // :TBDz: Does this really need to be set here?  Doesn't work here   maybe set to 0 someplace else?
        
        var registeredUnitType: String
        //TBDz Need to determine which need to be registered and what setting. These are not written to disk
        if Locale.current.measurementSystem == .metric {
            //Register defaults
            registeredUnitType = "metric"
        } else {
            registeredUnitType = "imperial"
        }
        
        UserDefaults.standard.register(defaults: [
            SettingsKeys.unitsTypeToggleShowPref: true,
            SettingsKeys.unitsTypePref: registeredUnitType,
            SettingsKeys.show21TweaksPref: false
        ])
        
        // =====  GLOBAL SETUP  =====
        
        let fm = FileManager.default
        let databaseDir = URL
            .libraryDirectory
            .appending(component: "Database", directoryHint: .isDirectory)
        if fm.fileExists(atPath: databaseDir.path) == false {
            do {
                try fm.createDirectory(at: databaseDir, withIntermediateDirectories: true)
            } catch {
                print("@main init() failed to create Database/")
            }
        }
        
        // ----- SQLite Database Setup -----
        Task {
            do {
                try await SqliteDatabaseActor.shared.ensureInitialized()
            } catch {
                print(":ERROR: Failed initial DB setup: \(error)")
            }
        }
        
        // ----- Realm Database Migration -----
        performMigration()
        
        // ----- User Interface Setup -----
        
        // ----- Notification Setup -----
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dataCountAttributes, .shared)
                .onAppear {
                    if !hasSeenTweaks {
                        Task {
                            try? await Task.sleep(for: .seconds(0.6))  // iOS 16+ / macOS 13+
                            // Or for older deployments: try? await Task.sleep(nanoseconds: 600_000_000)
                            await MainActor.run {
                                showingTweaksSheet = true
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingTweaksSheet) {
                    WelcomeTweaksChoiceView()
                        .interactiveDismissDisabled()
                }
        }
        
        .onChange(of: scenePhase) { _, newPhase in
            Task {
                switch newPhase {
                case .background:
                    await SqliteDatabaseActor.shared.close()
                    print("🟢 •App• Database closed on entering background")
                case .active, .inactive:
                    do {
                        try await SqliteDatabaseActor.shared.ensureInitialized()
                        print("App active → DB ready")
                    } catch {
                        print(":ERROR: Failed to reopen DB on foreground: \(error)")
                    }
                @unknown default:
                    break
                }
            }
        } // onChange
    }
    
    private func performMigration() {
        print("=== Migration Started at \(Date()) ===")
        let clock = ContinuousClock()
        let benchmarkStart = clock.now
        
        Task(priority: .background) {
            let fm = FileManager.default
            let migrator = RealmMigrator.shared
            let connector = SQLiteConnector.shared
            
            // Step 1. One-time check
            let realmURL = URL.inDatabase(filename: "NutritionFacts.realm")
            let sqliteURL = connector.sqliteFilenameUrl
            
            guard fm.fileExists(atPath: realmURL.path),
                  !fm.fileExists(atPath: sqliteURL.path),
                  !UserDefaults.standard.bool(forKey: "hasMigratedToSQLitev4")
            else {
                print("Migration skipped: Already done or no Realm data")
                return
            }
            
            // Step 2: Generate CSV from Realm (sync, but actor-isolated)
            guard let csvURL = await migrator.generateCSV() // If made async
            else {
                print("Migration failed: CSV generation")
                return
            }
            
            // Step 3: Import CSV and rebuild SQLite (async, mutating)
            do {
                let tempConnector = connector  // Since mutating
                try await tempConnector.performCSVImportAndRebuild(from: csvURL)
                
                // Step 4: Cleanup
                
                // Optional: Delete old Realm file post-success
                try? fm.removeItem(at: realmURL)
                
                UserDefaults.standard.set(true, forKey: "hasMigratedToSQLitev4") // :NYI:
                print("Migration completed successfully")
            } catch {
                print("Migration failed: Import/rebuild - \(error)")
                // Optional: Cleanup partial CSV // :NYI:
            }
            
        }
        
        let benchmarkDuration = clock.now - benchmarkStart
        print("=== Migration Finished at \(Date()) ===")
        print("Total duration: \(benchmarkDuration.formatted(.units(allowed: [.seconds, .milliseconds, .microseconds])))")
    }
    
}
