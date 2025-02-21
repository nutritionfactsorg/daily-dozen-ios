//
//  TwentyOneTweaksTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import HealthKit

struct TwentyOneTweaksTabView: View {
    func checkHealthAvail() {
        if HKHealthStore.isHealthDataAvailable() {
            // add code to use HealthKit here...
            logit.debug("Yes, HealthKit is Available")
            let healthManager = HealthManager()
            healthManager.requestPermissions()
        } else {
            logit.debug("There is a problem accessing HealthKit")
        }
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(changedWeight(notification:)),
//            name: Notification.Name(rawValue: "NoticeChangedWeight"),
//            object: nil)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Twenty-One Tweaks View")
            }
            .navigationTitle(Text("navtab.tweaks")) //!!Needs localization comment
            .navigationBarTitleDisplayMode(.inline)
//
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
//            .toolbarColorScheme(.dark) // allows title to be white
            .onAppear {
                checkHealthAvail()
            }
        }
    }
}

#Preview {
    TwentyOneTweaksTabView()
}
