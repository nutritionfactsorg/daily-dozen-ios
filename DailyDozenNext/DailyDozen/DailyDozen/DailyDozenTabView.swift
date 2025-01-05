//
//  DailyDozenTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DailyDozenTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Daily Dozen View")
            }
//            navigationTitle("Daily Dozen") //!!Needs localization
//            .navigationBarTitleDisplayMode(.inline)
//            
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarBackground(.brandGreen, for: .navigationBar)
//            .toolbarColorScheme(.dark) // allows title to be white
        }
    }
}

#Preview {
    DailyDozenTabView()
}
