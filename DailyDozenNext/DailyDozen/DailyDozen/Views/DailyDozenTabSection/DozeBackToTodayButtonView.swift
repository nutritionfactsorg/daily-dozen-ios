//
//  dozeBackToTodayButtonView.swift
//  DailyDozen
//
//  Created by mc on 3/12/25.
//

import SwiftUI

struct DozeBackToTodayButtonView: View {
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

#Preview {
    DozeBackToTodayButtonView()
}
