//
//  LegendView.swift
//  DailyDozen
//
//  Created by mc on 4/21/25.
//

import SwiftUI

struct LegendView: View {
    var body: some View {
        HStack(spacing: 20) {
            // Some servings (yellow)
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.calendarSomeChecked)
                    .frame(width: 20, height: 20)
                Text("Some servings")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.calendarAllChecked)
                    .frame(width: 20, height: 20)
                Text("All servings")
                    .font(.caption)
                    .foregroundColor(.black)
            }
           
        }
        .padding()
        .ignoresSafeArea(edges: .horizontal)
        .frame(maxWidth: .infinity)
       // .padding()
        .background(Color.gray.opacity(0.2)) //.ignoresSafeArea(edges: .bottom)) // Light gray background   !!NYIz needs to be NF gray
       // .padding(.horizontal)
        
    }
}

#Preview {
    LegendView()
}
