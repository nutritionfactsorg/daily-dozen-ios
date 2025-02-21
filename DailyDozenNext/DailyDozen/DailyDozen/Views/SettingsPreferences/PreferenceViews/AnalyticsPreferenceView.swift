//
//  AnalyticsPreferenceView.swift
//  DailyDozen
//
//  Created by mc on 2/7/25.
//

import SwiftUI

struct AnalyticsPreferenceView: View {
    @State private var enableAnalytics: Bool = false
    
    func saveAnalyticsAllowed() {
        UserDefaults.standard.set(enableAnalytics, forKey: SettingsKeys.analyticsIsEnabledPref)
        print(enableAnalytics)
    }
    
    func loadAnalyticsAllowedIndicator() {
        enableAnalytics = UserDefaults.standard.bool(forKey: SettingsKeys.analyticsIsEnabledPref)
        print(enableAnalytics)
    }
    var body: some View {
        VStack {
            Text("setting_analytics_title")
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                if #available(iOS 17.0, *) {
                    Toggle(String(localized: "setting_analytics_enable"), isOn: $enableAnalytics) //NYIz put to user defaults and add popup alert
                        .onChange(of: enableAnalytics) {
                            saveAnalyticsAllowed()
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .brandGreen))
                } else {
                    // Fallback on earlier versions
                    Toggle(String(localized: "setting_analytics_enable"), isOn: $enableAnalytics) //NYIz put to user defaults and add popup alert
                        .onChange(of: enableAnalytics) { _ in
                            saveAnalyticsAllowed()
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .brandGreen))
                }
            }
            
        }
        .onAppear {
            loadAnalyticsAllowedIndicator()
        }
    }
}

#Preview {
    AnalyticsPreferenceView()
}
