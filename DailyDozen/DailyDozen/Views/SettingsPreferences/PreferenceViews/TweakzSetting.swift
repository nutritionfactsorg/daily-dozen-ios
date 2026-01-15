//
//  TweakzSetting.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TweakzSetting: View {
    @State var selectedTweakVisibilityControl = String(localized: "setting_doze_only_choice")
    var tweakVisibilityControl: [String] = [String(localized: "setting_doze_only_choice", comment: "Daily Dozen Only"), String(localized: "setting_doze_tweak_choice", comment: "Daily Dozen + 21 Tweaks")]
    
    func saveTweakChangeState(index: Int) {
        if index == 0 {
            UserDefaults.standard.set(false, forKey: SettingsKeys.show21TweaksPref)
        } else {
            UserDefaults.standard.set(true, forKey: SettingsKeys.show21TweaksPref)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("setting_tweak_header")
                .textCase(.uppercase)
                .font(.subheadline.bold())
               // .font(.system(size: 16, weight: .medium))
            // .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
            Picker(String(localized: "setting_units_header"), selection: $selectedTweakVisibilityControl) {
                ForEach(tweakVisibilityControl, id: \.self) { control in
                    Text(control)
                    .tag(control)
                }
               
            }
                .pickerStyle(.segmented)
                .labelsHidden()
                .onAppear {
                   
                            UISegmentedControl.appearance().apportionsSegmentWidthsByContent = true
                        }
                        .onDisappear {
                            UISegmentedControl.appearance().apportionsSegmentWidthsByContent = false  // clean reset
                        }            //
            Text("setting_doze_tweak_footer")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            //  .padding(10)
        } //VStack
        .padding(.horizontal, 10)     // ← reduced from 10 → gives the picker ~8 extra points of width
        .padding(.vertical, 10)
        .onAppear {
           // UISegmentedControl.appearance().apportionsSegmentWidthsByContent = true
            let shouldShow21Tweaks = UserDefaults.standard.bool(forKey: SettingsKeys.show21TweaksPref)
            
            if  shouldShow21Tweaks == true {
                selectedTweakVisibilityControl = tweakVisibilityControl[1]
            } else {
                selectedTweakVisibilityControl = tweakVisibilityControl[0]
            }
        }
        .onChange(of: selectedTweakVisibilityControl) { _, newValue in
            if let index = tweakVisibilityControl.firstIndex(of: newValue) {
                
                saveTweakChangeState(index: index)
                
            } else {
                print("this case should not happen.")
            }
        }
    }
}

#Preview {
    TweakzSetting()
}

//if want to tweak segments more:

//    let seg = UISegmentedControl.appearance()
//    
//    seg.apportionsSegmentWidthsByContent = true         
//    seg.selectedSegmentTintColor = UIColor(Color.accentColor)  // proper tint
//    // Reduce the huge default horizontal padding if you still want it tighter:
//    seg.setContentPositionAdjustment(UIOffset(horizontal: -8, vertical: 0),
//                                     forSegmentType: .any,
//                                     barMetrics: .default)
