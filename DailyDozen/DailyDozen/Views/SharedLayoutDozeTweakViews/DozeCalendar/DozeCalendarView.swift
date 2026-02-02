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
            ScrollView {
                VStack(spacing: 24) {
                    UICalendarViewRepresentable(item: item, currentMonth: $currentMonth)
                        .frame(maxWidth: .infinity)
                   
                    LegendView()
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
           
            .whiteInlineGreenTitle(item.headingDisplay)
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
