//
//  21TweakSetting.swift
//  DailyDozen
//
//  Created by mc on 2/17/25.
//

import SwiftUI

struct TwentyOneTweakSetting: View {
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
        VStack {
            Text("setting_tweak_header")
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
    
                Picker(String(localized: "setting_units_header"), selection: $selectedTweakVisibilityControl) {
                    ForEach(tweakVisibilityControl, id: \.self) {
                        Text($0)
                    }
                } .pickerStyle(.segmented)
                    .onChange(of: selectedTweakVisibilityControl) { newValue in
                    if let index = tweakVisibilityControl.firstIndex(of: newValue) {
                      
                        saveTweakChangeState(index: index)
                              
                          } else {
                              print("this case should not happen.")
                          }
                }
                .padding(10)
//           
            Text("setting_doze_tweak_footer").font(.footnote)
                .multilineTextAlignment(.leading)
            //  .padding(10)
        } //VStack
        .onAppear {
            let shouldShow21Tweaks = UserDefaults.standard.bool(forKey: SettingsKeys.show21TweaksPref)
            
            if  shouldShow21Tweaks == true {
                selectedTweakVisibilityControl = tweakVisibilityControl[1]
            } else {
                selectedTweakVisibilityControl = tweakVisibilityControl[0]
            }            
        }
    }
}

#Preview {
    TwentyOneTweakSetting()
}
