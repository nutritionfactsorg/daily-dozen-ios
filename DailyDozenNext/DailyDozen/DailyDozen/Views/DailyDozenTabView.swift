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
            .navigationTitle(Text("navtab.doze")) //!!Needs localization comment
            .navigationBarTitleDisplayMode(.inline)
//            
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
//            .toolbarColorScheme(.dark) // allows title to be white
        }
    }
}

#Preview {
    DailyDozenTabView()
    //.preferredColorScheme(.dark)
    
}
