//
//  DozeCalendarView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org
//

import SwiftUI

// •TBDz•  Be sure an check impact on Persian
struct DozeCalendarView: View {
    let item: DataCountType
    //let records: [SqlDailyTracker] = fetchSQLData()
   // @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var currentMonth: Date = Calendar.current.startOfMonth(for: Date())
    
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    
    var body: some View {
        ZStack(alignment: .bottom ) {
                UICalendarViewRepresentable(item: item, currentMonth: $currentMonth)
                //  .frame(height: 400)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
               // Spacer()
                
                LegendView()
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                   // .background(Color.white)
            }
           
                    // Explanation:
                    // - geometry.safeAreaInsets.bottom is ~50pt on devices with tab bar
                    // - We subtract 10 to avoid too much gap on larger screens
                    // - But enforce minimum 20pt so on SE there's still breathing room and no overlap
        
        .whiteInlineGreenTitle(item.headingDisplay)
        .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 0) // Ensures room for tab bar
            }
    //    .safeAreaInset(edge: .bottom, spacing: 0) {
                // This adds exactly the tab bar height as padding at the bottom
                // So the LegendView sits fully above the tab bar
           //     Color.clear
               //     .frame(height: 0)
                
                // Uncomment below if you want a little extra breathing room:
                // .frame(height: 10)
           // }
 
    }
}
    
    #Preview {
        
        NavigationStack {
            DozeCalendarView(
                item: .dozeBeans
               // records: mockDB
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
