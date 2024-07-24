//
//  EventCalendarView.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct EventCalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView {
                        CalendarView(interval: DateInterval(start: .distantPast, end: .now),
                                     eventStore: eventStore,
                                     dateSelected: $dateSelected,
                                     displayEvents: $displayEvents)
                        
                    }
                    
                    EventCalendarFooterView()
                    
                    // Text(LocalizedStringKey("item_history_completed_some")
                    //        .toolbar {
                    //            ToolbarItem(placement: .navigationBarTrailing) {
                    //                Button {
                    //                    formType = .new
                    //                } label: {
                    //                    Image(systemName: "plus.circle.fill")
                    //                        .imageScale(.medium)
                    //                }
                    //            }
                    //        }
                    //        .sheet(item: $formType) { $0 }
                    //        .sheet(isPresented: $displayEvents) {
                    //            DaysEventsListView(dateSelected: $dateSelected)
                    //                .presentationDetents([.medium, .large])
                    //        }
                    
                }
                //.navigationTitle("History View")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("item_history_heading", comment: "History")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(color: .gray, radius: 1, x: 0, y: 2)
                        //.shadow(color: .gray, radius: 5, x: 0, y: 2)
                    }
                }
                .toolbarBackground(
                    .orange, // :GTD:COLOR:
                    for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    //let myEvents = EventStore(preview: true)
    EventCalendarView()
        .environmentObject(EventStore(preview: true))
}
