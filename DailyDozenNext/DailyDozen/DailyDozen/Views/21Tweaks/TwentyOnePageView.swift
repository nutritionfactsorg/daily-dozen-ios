//
//  TwentyOnePageView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

enum NavigationDestination: Hashable {
   // case detail(DataCountType)
    case calendar(DataCountType)
    case chart(String)
   // case weightEntry(Date)
}

import SwiftUI

struct TwentyOnePageView: View {
    let date: Date
    
    @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
   
    @State private var showingAlert = false
    @State private var showStarImage = false
   // @State private var dbTrigger = UUID() // Trigger refresh on changes
    @State private var localTweakStateCount: Int = 0
   
//    private var tweakStateCount: Int {
//            let tracker = viewModel.tracker(for: date)
//            return tracker.itemsDict
//                 .filter { TweakEntryViewModel.rowTypeArray.contains($0.key) }
//                 .reduce(0) { $0 + $1.value.datacount_count }
//    }
    
    private let tweakStateCountMaximum = 37
    
    private var regularItems: [DataCountType] {
        TweakEntryViewModel.rowTypeArray
    }
    
    private func syncRecordWithDB() async {
    
                let localTracker = viewModel.tracker(for: date)
                localTweakStateCount = localTracker.itemsDict
                    .filter { TweakEntryViewModel.rowTypeArray.contains($0.key) }
                    .reduce(0) { $0 + $1.value.datacount_count } ?? 0
                print("🟢 •Sync• Updated localTweakStateCount for \(date.datestampSid): \(localTweakStateCount)")
    }
    
    var body: some View {
        //NavigationStack(path: $navigationPath) {
            VStack {
                HStack {
                    Text("tweak_entry_header")
                    Spacer()
                    if showStarImage {
                        Image("ic_star")
                        
                    }
                    // Text("4/24") // TBDz, NYI
                    Text("\(localTweakStateCount)/\(tweakStateCountMaximum)")
                    
                    NavigationLink {
                        TweakServingsHistoryView()
                            .environmentObject(SqlDailyTrackerViewModel())
                    } label: {
                        Image("ic_stat")
                    }
                }
                
                .padding(10)
                ScrollView {
                    VStack {
                        //  Text(date, style: .date)
                        ForEach(regularItems, id: \.self) { item in
                            TwentyOneTweaksEntryRowView(
                                item: item,
                               // record: record,
                                date: date,
                                onCheck: { _ in
                                    Task {
                                        await syncRecordWithDB()
                                        print("🟢 •Parent• onCheck called for \(item.headingDisplay) on \(date.datestampSid) (no action needed)")
                                    }
//                                    Task { @MainActor in
//                                        await viewModel.setCountAndUpdateStreak(for: item, count: count, date: date)
//                                        localTweakStateCount = viewModel.tracker?.itemsDict
//                                            .filter { $0.key.isTweak && TweakEntryViewModel.rowTypeArray.contains($0.key) }
//                                            .reduce(0) { $0 + $1.value.datacount_count } ?? 0
//                                    }
//                                    Task {@MainActor in
//                                       // let existingCount = viewModel.getCount(for: item)
//                                       // if count == 0 && existingCount == 0 && item != .tweakWeightTwice {
//                                        //    return
//                                       // }
//                                        //may need to insert await viewModel.getTrackerOrCreate(for)
                                        ///await viewModel.loadTracker(forDate: date.startOfDay)
//                                        //await viewModel.setCount(for: item, count: count, date: date.startOfDay)
//                                        localTweakStateCount = viewModel.tracker?.itemsDict
//                                                   .filter { TweakEntryViewModel.rowTypeArray.contains($0.key) }
//                                                   .reduce(0) { $0 + $1.value.datacount_count } ?? 0
//                                      //  countRecord.datacount_count = count
////                                        updatedRecord.itemsDict[item] = countRecord
////                                        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
////                                            records[index] = updatedRecord
////                                        } else {
////                                            records.append(updatedRecord)
////                                        }
////                                        record = updatedRecord
//                                        //print("🟢 •Update• Record created/updated for \(date.datestampSid): \(item.headingDisplay) count \(count)")
//                                    } //Task
                                }
                                
                            )
                            .id(item) // Ensure stable identity
                        } //ForEach regular
                        
                    } //VStack
                } //Scroll
                .frame(maxHeight: .infinity) ///TBDz is needed?
                // }//
            }

            .onAppear {
               Task { await syncRecordWithDB() }
                print("🟢 •Appear• TwentyOnePageView appeared for \(date.datestampSid)")
                //print("🟢 •Appear• TwentyOnePageView appeared for \(date.datestampSid), record: \(record?.date.datestampSid ?? "nil")")     //  print("TwentyOnePageView appeared, date: \(date.datestampSid), record: \(record?.date.datestampSid ?? "nil")")
            }
        
            .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
          //  .onReceive(WeightEntryViewModel.mockDBTrigger) { _ in
                Task { await syncRecordWithDB() }
               // dbTrigger = UUID()
            }
       // } //NavStack
    }
    
}

//#Preview {
//    @Previewable @State var records: [SqlDailyTracker] = []
//    TwentyOnePageView(date: Date(), records: $records)
//}
