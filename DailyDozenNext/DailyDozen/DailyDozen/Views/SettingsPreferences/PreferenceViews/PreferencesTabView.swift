//
//  PreferencesTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct PreferencesTabView: View {
    @State var selectedMesurementUnits =  String(localized: "setting_units_2_toggle")
    
    var unitsSegment: [String] = [String(localized: "setting_units_0_imperial"), String(localized: "setting_units_1_metric"), String(localized: "setting_units_2_toggle")]
//    enum UnitsSegmentState: Int, CaseIterable, Identifiable {
//        var id: Self { self }
//        case imperialState = 0
//        case metricState = 1
//        case toggleUnitsState = 2
//
//        
////        func toLocalizedString() -> String {
////            let value: String
////            
////            switch self {
////            case .imperialState:
////                value = String(localized: "setting_units_0_imperial")
////            case .metricState:
////                value = String(localized: "setting_units_1_metric")
////            case .toggleUnitsState:
////                value = String(localized: "setting_units_2_toggle")
////            }
////            
////            return value
// //       }
//    }
    var body: some View {
        NavigationStack {
            VStack {
               
                VStack {
                    Section {
                        
                        Text("setting_units_header")
                           
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                        //!!GTDz: What is default?
                        Picker(String(localized: "setting_units_header"), selection: $selectedMesurementUnits) {
                            ForEach(unitsSegment, id: \.self) {
                                
                                //Text(String(describing: option))
                                Text($0)
                            }
                        } .pickerStyle(.segmented)
                            .padding(10)
                        //  Text("Value: \(selectedMesurementUnits)") //GTDz remove later
                        Text("setting_units_choice_footer")
                        
                            .padding(10)
                    } //End Section
                    Section {
                    Text("reminder.heading")
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        
                        NavigationLink {
                            SettingsReminderView()
                        } label: {
                            Text("reminder.settings.enable", comment: "Enable Reminders")
                        }
                    
                    } //End Section
                }
                Spacer()
            }
            .navigationTitle(Text("navtab.preferences")) //!!Needs localization comment
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
//            .toolbarColorScheme(.dark) // allows title to be white
        }
    }
}

#Preview {
    PreferencesTabView()
    // .environment(\.locale, .init(identifier: "de"))
}
