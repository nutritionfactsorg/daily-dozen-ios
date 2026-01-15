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
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(Color.nfGreenBrand)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.nfGreenBrand)
//                    )
                    //.cornerRadius(8)
                    .ignoresSafeArea(edges: .horizontal)
            }
            //.padding(.horizontal)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    //DozeBackToTodayButtonView(isToday: <#Bool#>, action: <#() -> Void#>)
}
