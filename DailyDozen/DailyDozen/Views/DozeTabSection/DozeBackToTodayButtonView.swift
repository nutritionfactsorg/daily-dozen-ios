//
//  dozeBackToTodayButtonView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeBackToTodayButtonView: View {
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        if !isToday {
            Button(action: action) {
               
                Text("dateBackButtonTitle")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)  //internal spacing
                    .padding(.horizontal, 16)
                    .background(Color.nfGreenBrand)
                    //.cornerRadius(8)
                    //.ignoresSafeArea(edges: .horizontal)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))  // Clips the entire padded background
            .ignoresSafeArea(edges: .horizontal)            // Full-bleed horizontally if desired
            .padding(.bottom, 10)
            .shadow(color: .black.opacity(0.15), radius: 6, y: -3)  // Optional: subtle lift
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    //DozeBackToTodayButtonView(isToday: <#Bool#>, action: <#() -> Void#>)
}
