//
//  MeasurementSection.swift
//  DailyDozen
//
//  Created by mc on 2/10/25.
//

import SwiftUI

struct MeasurementSection: View {
    
//    enum UnitsSegmentState: Int {
//        case imperialState = 0
//        case metricState = 1
//        case toggleUnitsState = 2
//    }
    
    @State var selectedMesurementUnits =  String(localized: "setting_units_2_toggle")
    var unitsSegment: [String] = [
        String(localized: "setting_units_0_imperial", comment: "Imperial"),
        String(localized: "setting_units_1_metric", comment: "Metric"),
        String(localized: "setting_units_2_toggle", comment: "Toggle Units")]
    
    func setUnitsMeasureSegment() {
        let shouldShowUnitsToggle = UserDefaults.standard.bool(forKey: SettingsKeys.unitsTypeToggleShowPref)
        
        guard
            let unitTypePrefStr =  UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let unitTypePref = UnitsType(rawValue: unitTypePrefStr)
        else { return }
        
        if  shouldShowUnitsToggle == true {
            selectedMesurementUnits = unitsSegment[2]
        } else {
            if unitTypePref == .imperial {
                selectedMesurementUnits = unitsSegment[0]
            }
            if unitTypePref == .metric {
                selectedMesurementUnits = unitsSegment[1]
            }
        }
        print("**", unitTypePrefStr)
        print(selectedMesurementUnits)
    }
    
    func saveUnitsTypePref(index: Int) {
        //
        //NYIz: change to case?
        if index == 0 {
            UserDefaults.standard.set(UnitsType.imperial.rawValue, forKey: SettingsKeys.unitsTypePref)
            let shouldShowUnitsToggle = false
            UserDefaults.standard.set(shouldShowUnitsToggle, forKey: SettingsKeys.unitsTypeToggleShowPref)
        }
        
        if index == 1 {
            UserDefaults.standard.set(UnitsType.metric.rawValue, forKey: SettingsKeys.unitsTypePref)
            let shouldShowUnitsToggle = false
            UserDefaults.standard.set(shouldShowUnitsToggle, forKey: SettingsKeys.unitsTypeToggleShowPref)
        }
        
        if index == 2 {
            let shouldShowUnitsToggle = true
            UserDefaults.standard.set(shouldShowUnitsToggle, forKey: SettingsKeys.unitsTypeToggleShowPref)
            print(2)
        }
    }
    
    var body: some View {
        VStack {
            Text("setting_units_header")
            
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
              //  .padding(10)
            //!!GTDz: What is default?  TBDz register defaults at the beginning of app
            Picker(String(localized: "setting_units_header"), selection: $selectedMesurementUnits) {
                ForEach(unitsSegment, id: \.self) {
                    
                    Text($0)
                }
            } .pickerStyle(.segmented)
              .padding(10)
              .onChange(of: selectedMesurementUnits) { newValue in
                    if let index = unitsSegment.firstIndex(of: newValue) {
                
                        saveUnitsTypePref(index: index)
                        
                    } else {
                        print("this case should not happen.")
                    }
                }
            Text("setting_units_choice_footer").font(.footnote)
            
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)  //Don't know if this is needed with footnote font
            //below didn't work
            //   .frame(maxWidth: .infinity, alignment: .leading)
            //  .lineLimit(nil)
            //.frame(width: 300)  //might want to set this a different number.
            // .frame(maxWidth: .infinity, alignment: .leading)
            
        }//.padding(10)
            .onAppear {
                setUnitsMeasureSegment()
                
            }
    }
}

#Preview {
    MeasurementSection()
    // .environment(\.locale, .init(identifier: "de"))
}
