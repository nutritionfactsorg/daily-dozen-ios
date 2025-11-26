//
//  DozeCalendarView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

//TBDz:  Be sure an check impact on Persian
struct DozeCalendarView: View {
    let item: DataCountType
    let records: [SqlDailyTracker]
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    
    var body: some View {
        VStack {
            UICalendarViewRepresentable(item: item, records: records, currentMonth: $currentMonth)
                .frame(height: 400)
            
           // Push the footer to the bottom
//               
//            LegendView() // Add the footer with the legend
//                .padding(.bottom, 0) // Remove bottom padding
//                .background(
//                     Color.white
//                        //.ignoresSafeArea(edges: .bottom)
//                       )
            Spacer()
                .safeAreaInset(edge: .bottom) {
                    LegendView()
                        .background(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                }
        }
        .navigationTitle(item.headingDisplay) // NYIzTBD:  Is this localized?  Right now Simplified to just the item name
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.brandGreen, for: .navigationBar)
       
//        .safeAreaInset(edge: .bottom) {
//                    Color.clear // Transparent placeholder to account for the TabView's safe area
//                        .frame(height: 0) // Minimal height, just to trigger safe area adjustment
//                }
                       // .frame(height: 0) // Minimal height, just to trigger safe area adjustment
              //  }
    }
}
    
    #Preview {
        
        NavigationStack {
            DozeCalendarView(
                item: .dozeBeans,
                records: fetchSQLData()
            )
        }
        //  .previewDisplayName("Beans Calendar")
        
//        NavigationStack {
//            DozeCalendarView(
//                item: .otherVitaminB12,
//                records: returnSQLDataArray()
//            )
//        }
        //   .previewDisplayName("Vitamin B12 Calendar")
    }
