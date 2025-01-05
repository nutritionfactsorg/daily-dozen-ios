//
//  DailyDozenTabView.swift
//  NFTest
//
//  Created by mc on 1/2/25.
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
