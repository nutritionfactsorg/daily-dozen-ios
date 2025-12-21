//
//  PreferencesTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
//SettingsReminderView   //TBDz Add navigation indicator or move to same view
import SwiftUI

struct PreferencesTabView: View {
    @State private var canNotify = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    MeasurementSection()
                        .padding(.vertical, 4)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("reminder.heading")
                            .textCase(.uppercase)
                        //  .font(.caption)
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        
                        NavigationLink(destination: SettingsReminderView()) {
                            HStack {
                                Text("reminder.settings.enable")
                                Spacer()
                                Text(canNotify ? "reminder.state.on" : "reminder.state.off")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(10)
                } //Section
                
                Section { TwentyOneTweakSetting() }
                Section { ExportHistorySection() }
                //Section { AnalyticsPreferenceView() }
                
                #if DEBUG
                Section {
                    NavigationLink(destination: AdvancedUtilities()) {
                        HStack {
                            Text("Advanced Utilities")
                                .textCase(.uppercase)
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                #endif
            }
            .listStyle(.insetGrouped)
            .navigationTitle("navtab.preferences")
            .whiteInlineGreenTitle("navtab.preferences")

//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarBackground(.nfGreenBrand, for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                canNotify = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
            }
        }
    }
}

#Preview {
  
        PreferencesTabView()
   // .environment(\.locale, .init(identifier: "de"))
}
