//
//  DailyDozenApp.swift
//  DailyDozen
//
//  Copyright © 2024-2026 NutritionFacts.org. All rights reserved.
//

import SwiftUI
import UserNotifications

@main
struct DailyDozenApp: App {
    private let manager = MigrationManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage(SettingsKeys.hasSeenLaunchV4) private var hasSeenTweaks = false
    //@AppStorage(SettingsKeys.reminderCanNotify) private var reminderCanNotify = false
    //@AppStorage("hasRequestedNotificationPermission") private var hasRequestedPermission = false
    
    @State private var showingTweaksSheet = false
    
    // @StateObject var viewModel = SqlDailyTrackerViewModel()
    
    init() {
        print("•INFO•DB• DailyDozenApp init() \(Date().datestampyyyyMMddHHmmssSSS)")
        // •TEST•
        // UserDefaults.standard.set(["fr"], forKey: "AppleLanguages")
        // UserDefaults.standard.set("fr_FR", forKey: "AppleLocale")
        //
        // UserDefaults.standard.set(["he"], forKey: "AppleLanguages")
        // UserDefaults.standard.set("he_IL", forKey: "AppleLocale")
        //
        // UserDefaults.standard.set(["fa"], forKey: "AppleLanguages")
        // UserDefaults.standard.set("fa_IR", forKey: "AppleLocale")

        initDatabase()
        initNotifications()
        initSettings()
    }
    
    func initDatabase() {
        print("•INFO•DB• DailyDozenApp initDatabase() \(Date().datestampyyyyMMddHHmmssSSS)")
        let fm = FileManager.default
        let databaseDir = URL
            .libraryDirectory
            .appending(component: "Database", directoryHint: .isDirectory)
        if fm.fileExists(atPath: databaseDir.path) == false {
            do {
                try fm.createDirectory(at: databaseDir, withIntermediateDirectories: true)
            } catch {
                print("•ERROR• @main init() failed to create Database/")
            }
        }
        
        // ----- SQLite Database Setup -----
        Task {
            do {
                try await SqliteDatabaseActor.shared.ensureInitialized()
                // ----- Realm Database Migration -----
                Task {
                    await MigrationManager.shared.performMigrationIfNeeded()
                }
            } catch {
                print("•ERROR• Failed initial DB setup: \(error)")
            }
        }
    }
    
    func initNotifications() {
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
        UNUserNotificationCenter.current().setBadgeCount(0) // For post-authorization cold launch
    }
    
    func initSettings() {
        var registeredUnitType: String
        //TBDz Need to determine which need to be registered and what setting. These are not written to disk
        if Locale.current.measurementSystem == .metric {
            //Register defaults
            registeredUnitType = "metric"
        } else {
            registeredUnitType = "imperial"
        }
        
        let isUpgrade = UserDefaults.standard.object(forKey: SettingsKeys.show21TweaksPref) != nil
        
        UserDefaults.standard.register(defaults: [
            SettingsKeys.unitsTypeToggleShowPref: true,
            SettingsKeys.unitsTypePref: registeredUnitType,
            SettingsKeys.show21TweaksPref: false,
            SettingsKeys.hasSeenLaunchV4: isUpgrade
        ])
    }
    
    func logMemoryUsage() {
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / 4)
            let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                }
            }
            if kerr == KERN_SUCCESS {
                print("•TRACE•APP• Memory used: \(info.resident_size / 1024 / 1024) MB")
            } else {
                print("•TRACE•APP• Error getting memory info: \(kerr)")
            }
        }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if manager.isComplete {
                    ContentView()
                        .environment(\.dataCountAttributes, .shared)
                        .onAppear {
                            if !hasSeenTweaks {
                                Task {
                                    try? await Task.sleep(for: .seconds(0.6))
                                    await MainActor.run {
                                        showingTweaksSheet = true
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $showingTweaksSheet) {
                            TweakzWelcomeChoiceView()
                                .interactiveDismissDisabled()
                        }
                } else {
                    MigrationView()
                        .environment(manager)
                        .transition(.opacity)
                }
            }
            
        }
        .onChange(of: scenePhase) { (oldPhase: ScenePhase, newPhase: ScenePhase) in
            Task {
                switch newPhase {
                case .background:
                    await SqliteDatabaseActor.shared.close()
                    print("•TRACE•APP• Database closed on entering background")
                    //logMemoryUsage()
                case .active, .inactive:
                    do {
                        try await SqliteDatabaseActor.shared.ensureInitialized()
                        print("•TRACE•APP• DB ensureInitialized() \(oldPhase) → \(newPhase)")
                    } catch {
                        print("•ERROR•APP• Failed to reopen DB on foreground: \(error)")
                    }
                    //logMemoryUsage()
                @unknown default:
                    break
                }
            }
        } // onChange
    }
    
}
