//
//  AllSomeFooterView.swift
//  UICalendarMyOwnTest
//
//

import SwiftUI

// Note: `item_history_*` NutritionFacts localized text keys

struct AllSomeFooterView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color(mainMedium))
            HStack {
                Label {
                    Text("item_history_completed_some")
                }
            icon: { Image(systemName: "circle.fill").foregroundColor(.yellow)
            }
                
                Label {
                    Text("item_history_completed_all")
                }
            icon: { Image(systemName: "circle.fill").foregroundColor(.green)
            }
                
                
            }
        }
    }
}

#Preview {
    AllSomeFooterView()
}
