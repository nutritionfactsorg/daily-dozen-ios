//
//  dozeBackToTodayButtonView.swift
//  DailyDozen
//
//  Created by mc on 3/12/25.
//

import SwiftUI

struct DozeBackToTodayButtonViewWAS: View {
    var body: some View {
        VStack {
            
            Button(action: {
                print("button pushed")
            }, label: {
                Text("dateBackButtonTitle")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
           
            .ignoresSafeArea(edges: .horizontal)
            .tint(.brandGreen)
           // .padding(5)
        }
    }
}

struct DozeBackToTodayButtonView: View {
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        if !isToday {
            Button(action: action) {
                Text("dateBackButtonTitle")
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .background(Color.brandGreen)
                    .foregroundColor(.white)
                    //.cornerRadius(8)
                    .ignoresSafeArea(edges: .horizontal)
            }
            //.padding(.horizontal)
           // .padding(.bottom, 10)
        }
    }
}

#Preview {
    //DozeBackToTodayButtonView(isToday: <#Bool#>, action: <#() -> Void#>)
}
