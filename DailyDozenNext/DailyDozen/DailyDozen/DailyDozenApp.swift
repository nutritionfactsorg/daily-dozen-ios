//
//  DailyDozenApp.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

@main
struct DailyDozenApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
   // @StateObject var viewModel = SqlDailyTrackerViewModel()
    init() {
        UNUserNotificationCenter.current().setBadgeCount(0) //set badge count to 0, but don't know if it removes notifications. Done in previous versions
        //TBDz: Does this really need to be set here?  Doesn't work here

        //        let center = UNUserNotificationCenter.current

//        do {
//            try await center.requestAuthorization(options: [.alert, .sound, .badge])
//        } catch {
//            // Handle the error here.
//        }
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
        }
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environmentObject(SqlDailyTrackerViewModel.shared)
                .environment(\.dataCountAttributes, .shared)
        }
        .onChange(of: scenePhase) { _, newPhase in
                    Task {
                        switch newPhase {
                        case .background:
                            await SqliteDatabaseActor.shared.close()
                            print("🟢 •App• Database closed on entering background")
                        case .active, .inactive:
                            // Optionally reopen or reinitialize database if needed
                            break
                        @unknown default:
                            break
                        }
                    }
                }
    }
}
