//
//  AdvancedUtilities.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct AdvancedUtilities: View {
    
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var darkOrLight = 0
    @State private var showResetAll = false
    @State private var showClearSqlDB = false
   
    var body: some View {
        List {
            Section("Test Data") {
                GenerateHistoryTestDataView()
            }
            Section("Streak Test Data") {
                Button("Clear DB and Generate Streak Data") {
                    Task {
                        await clearDB()
                        await viewModel.generateStreakTestData()
                    }
                    
                }
                .buttonStyle(.borderedProminent)
            }
            Section("SQLite Utilities") {
                VStack(spacing: 20) {
                    Button("Clear Database") {
                        //print(":INFO: SQLite 'Clear Database' tapped!")
                        showClearSqlDB = true
                    }
                    .buttonStyle(.borderedProminent)
                    .reusableConfirmDialog(
                        isPresented: $showClearSqlDB,
                        title: "Clear DB?",
                        confirmTitle: "Clear DB"
                    ) {
                        print(":INFO: SQLite 'Clear DB' tapped!")
                        Task {
                            await clearDB()
                        }
                    }
                    
                    Button("Data Export") {
                        print(":INFO: SQLite 'Data Export' tapped!")
                        Task {
                            await SQLiteConnector.shared.exportData()
                        }
                    }
                    .buttonStyle(.bordered)
                    Section {  ImportCSVtoSQLiteView() }
                    
                    Button("Generate Counts: A") {
                        print("Generate Counts: A tapped!")
                    }
                    .buttonStyle(.plain)
                    Button("Generate Counts: B") {
                        print("Generate Counts: B tapped!")
                    }
                    .buttonStyle(.plain)
                    Button("Generate Counts: C") {
                        print("Generate Counts: C tapped!")
                    }
                    .buttonStyle(.plain)
                    Button("Generate Counts: D") {
                        print("Generate Counts: D tapped!")
                    }
                    .buttonStyle(.plain)
                    Button("Generate Weights: A") {
                        print("Generate Weights: A tapped!")
                    }
                    .buttonStyle(.plain)
                    Button("Generate Weights: B") {
                        print("Generate Weights: B tapped!")
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            Section("Realm Utilities") {
                VStack(spacing: 20) {
                    //Button("Clear Database") {
                    //    print("Clear Database Realm tapped!")
                    //    RealmMigrator.shared.doClearDB()
                    //}
                    //.buttonStyle(.borderedProminent)
                    
                    Button("Data Export") {
                        print(":INFO: Realm 'Data Export' tapped!")
                        Task.detached(priority: .utility) {  // or .background
                            let csvMigrateURL = await RealmMigrator.shared.generateCSV()
                            
                            await MainActor.run {
                                if csvMigrateURL != nil {
                                    print("Realm export completed successfully")
                                } else {
                                    print("Realm export did not happen")
                                }
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    //Button("Generate Test Data") {
                    //    print("Generate Test Data Realm tapped!")
                    //    RealmMigrator.shared.doGenerateTestData()
                    //}
                    //.buttonStyle(.plain)
                }
            }
            Section("Date & Time Test Utilities") {
                Button("Add One Date") {
                    print("Add One Date tapped!")
                    Task {
                            await DateManager.shared.incrementDay()
                        }
                }
                .buttonStyle(.plain)
            }
            Section("HealthKit") {
                Button("Print HK Status") {
                    HealthManager.shared.debugPrintAuthorizationStatus()
                }

                Button("Force HK Permission Prompt (or Skipped)") {
                    HealthManager.shared.debugForceHealthKitPermissionPrompt()
                }
                .tint(.orange)
                Button("Open Reset HK Permissions", role: .destructive) {
                    // Direct deep-link to YOUR app's Health permissions page
                    if let url = URL(string: "App-prefs:Privacy&path=HEALTH") {
                        UIApplication.shared.open(url)
                    }
                }
                .tint(.blue)
                Button("Delete All Body Mass Data in HK", role: .destructive) {
                    HealthManager.shared.debugDeleteAllBodyMassData()
                }
                .tint(.nfRedFlamePea)
                .buttonStyle(.borderedProminent)
            }
            Section("Appearance") {
                VStack {
                    Picker("What is your favorite color?", selection: $darkOrLight) {
                        Text("Light").tag(0)
                        Text("Dark").tag(1)
                        
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Value: \(darkOrLight)")
                }
            }
            Section("Settings") {
                VStack(spacing: 20) {
                    Button("Reset Settings") {
                        SettingsKeys.resetAllMySettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.nfRedFlamePea)
                    Button("Show Settings") {
                        printAppUserDefaults()
                    }
                    .buttonStyle(.plain)
                    Button("Show Apple Language Settings") {
                        UserDefaults.standard.printAppleLanguageSettingsOnly()
                    }
                    .buttonStyle(.plain)
                    
                }
            }
            Section("Reset") {
                    Button("Reset Language to System Language") {
                        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                        UserDefaults.standard.removeObject(forKey: "AppleLocale")
                        print("Language override cleared")
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Reset ALL") {
                        showResetAll = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.nfRedFlamePea)
                    .reusableConfirmDialog(
                        isPresented: $showResetAll,
                        title: "Reset All?",
                        message: "This cannot be undone.",
                        confirmTitle: "Reset"   // ← shows "Reset" instead of "Yes"
                    ) {
                        print("Reset!")
                        //put action here
                    }
               
            }
            
        }
    }
    
    func printAllUserDefaults() {
        print("--- User Defaults ---")
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value)")
        }
        print("---------------------")
    }
    
    func printAppUserDefaults() {
        //print("unitsType:  \(UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref) ??  "None")")
        SettingsKeys.debugPrintMySettings()
    }
    
    func clearDB() async {
        await viewModel.clearSQLFile()
    }
    
}

#Preview {
    AdvancedUtilities()
}
