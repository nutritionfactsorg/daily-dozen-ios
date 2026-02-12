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
                .foregroundStyle(.secondary)
            Picker(String(localized: "setting_units_header"), selection: $selectedTweakVisibilityControl) {
                ForEach(tweakVisibilityControl, id: \.self) { control in
                    Text(control)
                        .font(.subheadline)      // Smaller base → less aggressive scaling
                        .minimumScaleFactor(0.7) // Shrinks gracefully to fit in large text
                        .lineLimit(1)
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
        .padding(.horizontal, 10)
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
