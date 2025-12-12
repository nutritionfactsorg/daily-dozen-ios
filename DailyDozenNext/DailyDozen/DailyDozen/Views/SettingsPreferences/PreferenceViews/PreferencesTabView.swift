//
//  PreferencesTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct PreferencesTabView: View {

    @State var canNotify = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 5) {
                    VStack {
                        Section {
                            MeasurementSection()
                              .padding(10)
                            
                        } //End Section
                        Divider()
                        Section {
                            
                            Text("reminder.heading")
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                            
                            NavigationLink(destination: SettingsReminderView()) {
                                HStack {
                                    Text("reminder.settings.enable", comment: "Enable Reminders")
                                    Spacer()
                                    if canNotify {
                                        Text( "reminder.state.on", comment: "'On' as in 'On or Off'")
                                    } else {
                                        Text("reminder.state.off", comment: "'Off' as in 'On or Off'")
                                    }
                                    //TBDz Add navigation indicator or move to same view
                                } //HStack
                            } //NavLink
                         
                            .padding(10)
                        } //End Section
                        Divider()
                    }
                Section {
                     TwentyOneTweakSetting()
                    .padding(10)
                } //End 21 Tweak Section
                Divider()
                Section {
                    ExportHistorySection()
                    .padding(10)
                } //End Export History Section
                Divider()
                Section {

                    AnalyticsPreferenceView()
                    .padding(10)
                } //End Enable Analytics Section
                Divider()
                
                //Generate data for testing !!TBDz not for production
                Section("🧪 Test Data") {
                  GenerateHistoryTestDataView()
                                }
                Spacer()
                }
                .navigationTitle(Text("navtab.preferences")) //!!Needs localization comment
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.brandGreen, for: .navigationBar)
                //            .toolbarColorScheme(.dark) // allows title to be white
                .onAppear {
                    canNotify = UserDefaults.standard.bool(forKey: SettingsKeys.reminderCanNotify)
        #if DEBUG
                  //  print(UserDefaults.standard.dictionaryRepresentation())
        #endif
                }
            }
    }
}

#Preview {
  
        PreferencesTabView()
   // .environment(\.locale, .init(identifier: "de"))
}
