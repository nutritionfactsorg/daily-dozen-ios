//
//  TweakEventCalendar2View.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TweakEventCalendar2View: View {
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false
    @State private var itemType: DataCountType
    
    init(dateSelected: DateComponents? = nil, displayEvents: Bool = false, itemType: DataCountType) {
        self.dateSelected = dateSelected
        self.displayEvents = displayEvents
        self.itemType = itemType
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView {
                        TweakCalendar2View(
                            interval: DateInterval(start: .distantPast, end: .now),
                            dateSelected: $dateSelected,
                            displayEvents: $displayEvents,
                            itemType: $itemType
                        )
                    }
                    EventCalendarFooterView()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("item_history_heading", comment: "History")
                            .font(.fontSystemBold21)
                            .foregroundColor(ColorGuide.textWhite)
                            .shadow(color: .gray, radius: 1, x: 0, y: 2)
                    }
                }
                .toolbarBackground(ColorGuide.mainMedium, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
        } else {
            // N/A: SwiftUI only used for DailyDozen iOS 16 or newer
        }
    }
}
