//
//  EventsCalendarView.swift
//  UICalendarMyOwnTest
//
//

import SwiftUI

struct EventsCalendarView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false
    // var itemHistoryFooterAll: UILabel!
    // var itemHistoryFooterSome: UILabel!
    // var itemHistoryHeader: UIView!
    // var itemHistoryHeaderLabel: UILabel!
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    // VStack {
                    CalendarView(interval: DateInterval(start: .distantPast, end: .distantFuture),
                                 eventStore: eventStore,
                                 dateSelected: $dateSelected,
                                 displayEvents: $displayEvents)
                    //                HStack {
                    //                    Text( NSLocalizedString("item_history_heading", comment: "History"))
                    //                }
                    //          }
                    //                itemHistoryHeaderLabel.text = NSLocalizedString("item_history_heading", comment: "History")
                    //                itemHistoryFooterAll.text = NSLocalizedString("item_history_completed_all", comment: "All completed")
                    //                itemHistoryFooterSome.text = NSLocalizedString("item_history_completed_some", comment: "Some completed")
                    //          }
                }
                AllSomeFooterView()
                //        HStack {
                //            Label {
                //                Text("item_history_completed_all")
                //            }
                //        icon: { Image(systemName: "circle.fill").foregroundColor(.green)
                //            }
                //
                //            Label {
                //                Text("item_history_completed_some")
                //            }
                //        icon: { Image(systemName: "circle.fill").foregroundColor(.yellow)
                //            }
                //        }
                //        Label {
                //            Text("item_history_completed_all",
                //                 comment: "A label that displays 'completed' and a corresponding image.")
                //        } icon: {
                //            Image("circle.fill")
                //                .tint(.yellow)
                //        }
                
                
                
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
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Text("History")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .shadow(color: .gray, radius: 1,  x: 0, y: 2)
                    //.shadow(color: .black, radius: 5, x: 0, y: 2)
                }
            }
            .toolbarBackground(
                Color(mainMedium),
                for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            
        }
    }
}

#Preview {
    //let myEvents = EventStore(preview: true)
    EventsCalendarView()
        .environmentObject(EventStore(preview:true))
}
