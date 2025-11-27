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
    // let records: [SqlDailyTracker] = mockDB // needed?
    let date: Date
    // let weightViewModel: WeightEntryViewModel
    //  @Binding var navigateToWeightEntry: Bool
    let onCheck: (Int) -> Void // Callback for when checkbox changes
    // let onWeightUpdate: (SqlDailyTracker) -> Void
    @State private var navigateToWeightEntry: Bool = false
    @State private var localCount: Int = 0
    @State private var count: Int = 0 // Initialize with default
    
    private func updateCount() {
        if item == .tweakWeightTwice {
            
            if let tracker = mockDB.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                let amWeight = tracker.weightAM.dataweight_kg
                let pmWeight = tracker.weightPM.dataweight_kg
                let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                count = newCount
                localCount = newCount
                onCheck(newCount)
                // print("Updated count for \(date.datestampSid): \(newCount), AM: \(amWeight), PM: \(pmWeight)")
            } else {
                count = 0
                localCount = 0
                onCheck(0)
                // print("No tracker found for \(date.datestampSid), count set to 0")
            }
        } else {
            count = record?.itemsDict[item]?.datacount_count ?? localCount
            localCount = count
            onCheck(count)
            //print("Updated count for \(item.headingDisplay): \(count)")
        }
    }
    
    var body: some View {
        NavigationStack {
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
                        //
                        ContiguousCheckboxView(
                            n: item.goalServings,
                            x: $count,
                            direction: .leftToRight,
                            onChange: { newCount in
                                if item == .tweakWeightTwice {
                                    navigateToWeightEntry = true // Navigate to WeightEntryView
                                } else {
                                    localCount = newCount
                                    onCheck(newCount) // Update non-weight item count
                                    print("Checkbox changed for \(item.headingDisplay): \(newCount)")
                                }
                            },
                            isDisabled: item == .tweakWeightTwice,
                            onTap: item == .tweakWeightTwice ? { navigateToWeightEntry = true } : nil
                        )
                    }
                }
            } //HStack
            .padding(10)
            .shadowboxed()
            
            .navigationDestination(isPresented: $navigateToWeightEntry) {
                WeightEntryView(initialDate: date.startOfDay)
            }
        }
        //
        //      .background(
        //            NavigationLink(
        //                destination: WeightEntryView(initialDate: date.startOfDay),
        //                isActive: $navigateToWeightEntry
        //            ) { EmptyView() }
        //        )
        .onAppear {
            updateCount()
            
        }
        .onChange(of: navigateToWeightEntry) { _, isActive in
            if !isActive && item == .tweakWeightTwice {
                print("Returned from WeightEntryView, updating count for \(date.datestampSid)")
                //weightViewModel.loadTrackers() // Refresh trackers
                updateCount() // Update count when returning from WeightEntryView
            }
        }
        //TBDz is this needed?
        .onChange(of: record?.itemsDict[item]?.datacount_count) { _, newCount in
            if item != .tweakWeightTwice, let newCount = newCount {
                count = newCount
                localCount = newCount
                onCheck(newCount)
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
struct TwentyOneTweaksEntryRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockDate = Date().startOfDay
        let mockTracker = SqlDailyTracker(date: mockDate)
       // let mockDataCountType = DataCountType.tweakWeightTwice // Adjust based on your DataCountType
        return NavigationStack {
            VStack {
                TwentyOneTweaksEntryRowView(
                    item: DataCountType.dozeBeans,
                    record: mockTracker,
                    date: mockDate,
                    onCheck: { _ in }
                )
                TwentyOneTweaksEntryRowView(
                    item: .tweakWeightTwice,
                    record: mockTracker,
                    date: mockDate,
                    onCheck: { newCount in
                        print("Preview: Count updated for tweakWeightTwice: \(newCount)")
                    }
                )
            }
        }
    }
}
