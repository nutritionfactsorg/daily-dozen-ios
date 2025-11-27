//
//  TwentyOneTweaksEntryiRowView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TwentyOneTweaksEntryRowView: View {
    var streakCount = 3000// NYI TBD
    
    let item: DataCountType
    let record: SqlDailyTracker?
    let records: [SqlDailyTracker] = mockDB // needed?
    let date: Date
   // let weightViewModel: WeightEntryViewModel
  //  @Binding var navigateToWeightEntry: Bool
    let onCheck: (Int) -> Void // Callback for when checkbox changes
   // let onWeightUpdate: (SqlDailyTracker) -> Void
    @State private var navigateToWeightEntry = false
    @State private var localCount: Int = 0
    @State private var count: Int = 0 // Initialize with default
   // @State private var navigateToWeightEntry: Bool = false
    
//    private func updateCount() {
//            if item == .tweakWeightTwice {
//                let tracker = weightViewModel.tracker(for: date.startOfDay)
//                let newCount = (tracker.weightAM.dataweight_kg > 0 ? 1 : 0) +
//                              (tracker.weightPM.dataweight_kg > 0 ? 1 : 0)
//                print("Updating count for \(date.startOfDay.datestampSid): \(newCount), AM: \(tracker.weightAM.dataweight_kg), PM: \(tracker.weightPM.dataweight_kg)")
//                          
//                count = newCount
//                localCount = newCount
//                onCheck(newCount)
//            } else {
//                count = record?.itemsDict[item]?.datacount_count ?? localCount
//            }
//        }
    
    private func updateCount() {
        if item == .tweakWeightTwice {
            if let tracker = record {
                let newCount = (tracker.weightAM.dataweight_kg > 0 ? 1 : 0) +
                              (tracker.weightPM.dataweight_kg > 0 ? 1 : 0)
                count = newCount
                localCount = newCount
                onCheck(newCount)
                print("Updated count for \(date.datestampSid): \(newCount), AM: \(tracker.weightAM.dataweight_kg), PM: \(tracker.weightPM.dataweight_kg)")
            } else {
                count = 0
                localCount = 0
            }
        } else {
            count = record?.itemsDict[item]?.datacount_count ?? localCount
        }
    }
    
    var body: some View {
        HStack {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding(5)
            VStack(alignment: .leading) {
                HStack {
                    
                    Text(item.headingDisplay)
                        .padding(5)
                    Spacer()
                    NavigationLink(destination: TwentyOneDetailView(dataCountTypeItem: item)) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.nfDarkGray)
                    }
    
                }
                HStack {
                    //TBDz should clicking boxes on weight do something?
                    if item == .tweakWeightTwice {
                        NavigationLink(destination: WeightChartView()) {
                            Image("ic_calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    } else {
                        //TBDz this section still needs updating
                        NavigationLink(destination: DozeCalendarView(item: item)) {
                            Image("ic_calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    StreakView(streak: record?.itemsDict[item]?.datacount_streak ?? 0) // TBDz: guess at what this might be when implemented
                    Spacer()
                    HStack {
                        
                        let boxes = item.goalServings
                        if item == .tweakWeightTwice {
                            // Custom checkbox interaction for tweakWeightTwice
                            ContiguousCheckboxView(
                                n: boxes,
                                x: $count,
                                direction: .leftToRight,
                                onChange: { _ in },
                                isDisabled: true,
                                onTap: { navigateToWeightEntry = true } )
                        } else {
                            // Default checkbox behavior for other items
                            ContiguousCheckboxView(
                                n: boxes,
                                x: $count,
                                direction: .leftToRight,
                                onChange: { newCount in
                                    if record == nil {
                                        localCount = newCount
                                        onCheck(newCount)
                                    } else {
                                        
                                        onCheck(newCount)
                                    }
                                },
                                isDisabled: false,
                                onTap: nil
                            )
                            
                        }
                    }
                }
            }
        }
        .padding(10)
        .shadowboxed()
        .background(
            NavigationLink(
                            destination: WeightEntryView(initialDate: date.startOfDay),
                            isActive: $navigateToWeightEntry
                        ) { EmptyView() }
                    )
        .onAppear {
            print("TwentyOneTweaksEntryRowView appeared, date: \(date.datestampSid)")
            if item == .tweakWeightTwice {
                if let tracker = mockDB.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                    let newCount = (tracker.weightAM.dataweight_kg > 0 ? 1 : 0) +
                    (tracker.weightPM.dataweight_kg > 0 ? 1 : 0)
                    if newCount != count {
                        count = newCount
                        localCount = newCount
                        onCheck(newCount)
                        print("Updated count from mockDB on appear for \(date.datestampSid): \(newCount), AM: \(tracker.weightAM.dataweight_kg), PM: \(tracker.weightPM.dataweight_kg)")
                    }
                } else {
                    count = 0
                    localCount = 0
                }
            } else {
                updateCount()
            }
        }
        .onChange(of: navigateToWeightEntry) { _, isActive in
                   if !isActive && item == .tweakWeightTwice {
                       print("Returned from WeightEntryView, updating count for \(date.datestampSid)")
                       //weightViewModel.loadTrackers() // Refresh trackers
                      // updateCount() // Update count when returning from WeightEntryView
                   }
               }
        
         .onChange(of: record?.itemsDict[item]?.datacount_count) { _, newCount in
                   if item != .tweakWeightTwice, let newCount = newCount {
                       count = newCount
                   }
               }
    }
}

//#Preview {
//    @Previewable @State var mockCount: Int = 0
//    let mockRecord = SqlDailyTracker(
//        date: Date(),
//        itemsDict: [
//            DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-07-19", datacount_kind_pfnid: 206, datacount_count: 3, datacount_streak: 5)!
//        ]
//    )
//    
//    TwentyOneTweaksEntryRowView(item: .tweakDailyBlackCumin, record: mockRecord, date: Date(), onCheck: { newCount in
//        mockCount = newCount
//        print("Preview: Checkbox changed to \(newCount)")
//    }, onWeightUpdate: <#(SqlDailyTracker) -> Void#>)
//}
