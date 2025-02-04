//
//  TwentyOneTweaksTabView.swift
//  NFTest
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TwentyOneTweaksTabView: View {
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
        }
    }
}

#Preview {
    TwentyOneTweaksTabView()
}
