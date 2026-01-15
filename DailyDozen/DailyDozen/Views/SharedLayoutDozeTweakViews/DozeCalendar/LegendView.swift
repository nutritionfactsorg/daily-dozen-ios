//
//  LegendView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct LegendView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Some servings (yellow)
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.nfCalendarSomeChecked)
                    .frame(width: 20, height: 20)
                Text("item_history_completed_some")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.nfCalendarAllChecked)
                    .frame(width: 20, height: 20)
                Text("item_history_completed_all")
                    .font(.caption)
                    .foregroundColor(.black)
            }
           
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color.nfGray50.opacity(0.2))
        
    }
}

#Preview {
    LegendView()
}
