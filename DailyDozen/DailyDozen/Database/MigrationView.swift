//
//  MigrationView.swift
//  DailyDozen/Database
//
//  Copyright © 2025-2026 NutritionFacts.org. All rights reserved.
//

import SwiftUI

struct MigrationView: View {
    @Environment(MigrationManager.self) private var manager
    
    var body: some View {
        
        ZStack {
            // Background
            Rectangle()
                .foregroundColor(.white)
                .ignoresSafeArea() // Full-screen loading view
            
            // Foreground
            VStack {
               
                Spacer() // approximate 1/3 spacings
                
                Image("launchBannerImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
                
                Spacer()
                
                ProgressView(value: manager.migrationProgress) {
                    Text("\(Int(manager.migrationProgress * 100))%")
                        .foregroundStyle(.gray)
                }
                .progressViewStyle(.linear)
                .tint(.gray)
                .frame(maxWidth: 300)
                .scaleEffect(y: 3)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.ignoresSafeArea()
        }

    }
}
