//
//  MeasurementSection.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
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
        // print("**", unitTypePrefStr)
        // print(selectedMesurementUnits)
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
           // print(2)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {  //GTDz may need to try 10
            Text("setting_units_header")
                .textCase(.uppercase)
                .font(.subheadline.bold())            // matches Settings style
               .foregroundStyle(.secondary)

            Picker(String(localized: "setting_units_header"), selection: $selectedMesurementUnits) {
                ForEach(unitsSegment, id: \.self) { unit in
                    Text(unit)
                      //  .font(.system(size: 14, weight: .medium))  // ← fits "mmol/L" perfectly on SE
                        .tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()               // removes the hidden label that was pushing things right

            Text("setting_units_choice_footer")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)                      //padding, now on the whole VStack
        .onAppear {
            setUnitsMeasureSegment()
        }
        .onChange(of: selectedMesurementUnits) { _, newValue in
            if let index = unitsSegment.firstIndex(of: newValue) {
                saveUnitsTypePref(index: index)
            } else {
                print("this case should not happen.")
            }
        }
    }
}

#Preview {
    MeasurementSection()
    // .environment(\.locale, .init(identifier: "de"))
}
