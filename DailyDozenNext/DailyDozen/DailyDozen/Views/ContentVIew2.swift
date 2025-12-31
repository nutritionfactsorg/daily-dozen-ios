//
//  ContentVIew2.swift
//  DailyDozen
//
//  Created to test safari link errors/warnings
//

import SwiftUI

struct ContentView2: View {
    var body: some View {
        Button("Open nutritionfacts.org") {
            let url = URL(string: "https://nutritionfacts.org")!
            UIApplication.shared.open(url)
        }
        .padding()
        .background(Color.nfRedFlamePea)
        .foregroundColor(.white)  // :TBDz:color: color check
    }
}
