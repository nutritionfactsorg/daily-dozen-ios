//
//  TestLinkView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TestLinkView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("TEST VIEW – nothing else on screen")
                .font(.largeTitle)
            
            // THIS IS THE ONLY THING THAT CAN OPEN A URL
            Button("TAP ME – opens in real Safari") {
                let url = URL(string: "https://nutritionfacts.org/topics/vitamin-d")!
                print("Button tapped – opening URL now")
                UIApplication.shared.open(url)
            }
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button("TEST – DELAYED OPEN") {
                let url = URL(string: "https://nutritionfacts.org/topics/vitamin-d")!
                print("Button tapped – delaying 2 seconds...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow.opacity(0.3))
    }
}
