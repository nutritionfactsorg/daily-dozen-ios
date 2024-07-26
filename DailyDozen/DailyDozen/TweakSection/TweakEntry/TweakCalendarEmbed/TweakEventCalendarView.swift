//
//  TweakEventCalendarView.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TweakEventCalendarView: View {
    @EnvironmentObject var eventStore: TweakEventStore
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView {
                        TweakCalendarView(
                            interval: DateInterval(start: .distantPast, end: .now),
                            eventStore: eventStore,
                            dateSelected: $dateSelected,
                            displayEvents: $displayEvents)
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

#Preview {
    //let myEvents = TweakEventStore(preview: true)
    TweakEventCalendarView()
        .environmentObject(TweakEventStore(preview: true))
}
