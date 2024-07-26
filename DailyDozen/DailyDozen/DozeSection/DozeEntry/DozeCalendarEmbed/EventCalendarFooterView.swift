//
//  EventCalendarFooterView.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct EventCalendarFooterView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(ColorGuide.calendarFooter)
            HStack {
                Label(
                    title: { Text("item_history_completed_some") },
                    icon: { Image(systemName: "circle.fill")
                            .foregroundColor(ColorGuide.calendarSomeChecked) }
                )
                Label(
                    title: { Text("item_history_completed_all") },
                    icon: { Image(systemName: "circle.fill")
                            .foregroundColor(ColorGuide.calendarAllChecked) }
                )
            }
        }
    }
}

#Preview {
    EventCalendarFooterView()
}
