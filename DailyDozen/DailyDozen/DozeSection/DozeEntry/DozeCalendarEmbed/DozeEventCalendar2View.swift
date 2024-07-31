//
//  DozeEventCalendar2View.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeEventCalendar2View: View {
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
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .background(ColorGuide.mainMedium)
                    Text(verbatim: itemType.headingDisplay)
                        .font(.fontSystemMedium17)
                        .foregroundColor(ColorGuide.textWhite)
                }
                ScrollView {
                    DozeCalendar2View(
                        interval: DateInterval(start: .distantPast, end: .now),
                        dateSelected: $dateSelected,
                        displayEvents: $displayEvents,
                        itemType: $itemType
                    )
                }
                EventCalendarFooterView()
            }
        } else {
            // N/A: SwiftUI only used for DailyDozen iOS 16 or newer
        }
    }
}
