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
}

import SwiftUI

struct TwentyOnePageView: View {
    let date: Date
    @State var record: SqlDailyTracker?
    @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    //@State private var navigationPath = NavigationPath()

    // @StateObject private var weightViewModel = WeightEntryViewModel()
    @Binding var records: [SqlDailyTracker] // Binding
    @State private var showingAlert = false
    @State private var showStarImage = false
    @State private var dbTrigger = UUID() // Trigger refresh on changes
    
    private var tweakStateCount: Int {
        guard let record = record else {
            return 0
        }
        return record.itemsDict
            .filter { TweakEntryViewModel.rowTypeArray.contains($0.key) }
            .reduce(0) { $0 + $1.value.datacount_count }
    }
    
    private let tweakStateCountMaximum = 37
    
    private var regularItems: [DataCountType] {
        TweakEntryViewModel.rowTypeArray
    }
    
    private func syncRecordWithDB() async {
        let db = SqliteDatabaseActor.shared
        let tracker = await db.fetchDailyTracker(forDate: date.startOfDay)
        record = tracker
        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
            records[index] = tracker
        } else {
            records.append(tracker)
        }
        print("🟢 •Sync• Loaded record from SQLite for \(date.datestampSid)")
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
                    Text("\(tweakStateCount)/\(tweakStateCountMaximum)")
                    //Text("\(dozeDailyStateCount)/\(DozeEntryViewModel.rowTypeArray.reduce(0) { $0 + $1.goalServings })")
                    //                NavigationLink(destination:   TBDz"  NYI Need link info DozeServingsHistoryView(trackers: fetchSQLData())) {
                    //                    Image("ic_stat")
                    //                }
                    
                }
                
                .padding(10)
                ScrollView {
                    VStack {
                        //  Text(date, style: .date)
                        ForEach(regularItems, id: \.self) { item in
                            TwentyOneTweaksEntryRowView(
                                item: item,
                                record: record,
                                date: date,
                                onCheck: { count in
                                    
                                    Task {@MainActor in
                                        let existingCount = record?.itemsDict[item]?.datacount_count ?? 0
                                        if count == 0 && existingCount == 0 && item != .tweakWeightTwice {
                                            return
                                        }
                                        //may need to insert await viewMode.getTrackerOrCreate(for)
                                        var updatedRecord = record ?? SqlDailyTracker(date: date.startOfDay)
                                        var countRecord = updatedRecord.itemsDict[item] ?? SqlDataCountRecord(
                                            date: date.startOfDay,
                                            countType: item,
                                            count: 0,
                                            streak: updatedRecord.itemsDict[item]?.datacount_streak ?? 0
                                        )
                                        countRecord.datacount_count = count
                                        updatedRecord.itemsDict[item] = countRecord
                                        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                                            records[index] = updatedRecord
                                        } else {
                                            records.append(updatedRecord)
                                        }
                                        record = updatedRecord
                                        //print("🟢 •Update• Record created/updated for \(date.datestampSid): \(item.headingDisplay) count \(count)")
                                    }
                                }
                                
                            )
                            .id(item) // Ensure stable identity
                        } //ForEach regular
                        
                    } //VStack
                } //Scroll
                .frame(maxHeight: .infinity) ///TBDz is needed?
                // }//
            }
//                .navigationDestination(for: NavigationDestination.self) { destination in
//                    switch destination {
//                    case .chart:
//                        WeightChartView()
//                            .environmentObject(SqlDailyTrackerViewModel())
//                    case .calendar(.tweakWeightTwice):
//                        WeightEntryView(initialDate: date.startOfDay)
//                            .environmentObject(SqlDailyTrackerViewModel())
//                    case .calendar(let item):
//                        DozeCalendarView(item: item)
//                            .environmentObject(SqlDailyTrackerViewModel())
//                  //  case .detail(let item):
//                     //   TwentyOneDetailView(dataCountTypeItem: item)
//                    }
//                }
                
                //TBDZ!!!!!!! I'm sure this is needed somehow
                //                .navigationDestination(isPresented: $record.map { $0 != nil && $0.weightAM == nil && $0.weightPM == nil && Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) } ?? .constant(false)) {
                //                    WeightEntryView(initialDate: date.startOfDay)
                //                }
                //  } //VStack
            
            .onAppear {
                Task { await syncRecordWithDB() }
                print("🟢 •Appear• TwentyOnePageView appeared for \(date.datestampSid), record: \(record?.date.datestampSid ?? "nil")")     //  print("TwentyOnePageView appeared, date: \(date.datestampSid), record: \(record?.date.datestampSid ?? "nil")")
            }
            
//            .onChange(of: navigationPath) { _, newPath in
//                            print("🟢 •Nav• TwentyOnePageView navigation path changed: \(newPath)")
//                        }
            
            .onReceive(WeightEntryViewModel.mockDBTrigger) { _ in
                Task { await syncRecordWithDB() }
                dbTrigger = UUID()
            }
       // } //NavStack
    }
    
}

//#Preview {
//    @Previewable @State var records: [SqlDailyTracker] = []
//    TwentyOnePageView(date: Date(), records: $records)
//}
