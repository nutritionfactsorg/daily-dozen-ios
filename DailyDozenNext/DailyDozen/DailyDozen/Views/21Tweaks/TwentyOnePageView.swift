//
//  TwentyOnePageView.swift
//  DailyDozen
//
//
//

import SwiftUI

struct TwentyOnePageView: View {
    let date: Date
    @State var record: SqlDailyTracker?
   // @StateObject private var weightViewModel = WeightEntryViewModel()
    @Binding var records: [SqlDailyTracker] // Binding
    @State private var showingAlert = false
    @State private var showStarImage = false
   // @Binding var navigateToWeightEntry: Bool
   // let onWeightUpdate: (SqlDailyTracker) -> Void
  //  @State private var mockDBUpdateTrigger: Int = 0 // Trigger for mockDB updates
    private var tweakStateCount: Int {
            guard let record = record else {
                return 0
            }
        var total = 0
                for (itemType, itemRecord) in record.itemsDict {
                   
                        total += itemRecord.datacount_count
                    
        }
            return total
        }

    private let tweakStateCountMaximum = 37
    
    private var regularItems: [DataCountType] {
            TweakEntryViewModel.rowTypeArray
        }
    
    private func syncRecordWithMockDB() {
            if let existingRecord = mockDB.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                record = existingRecord
                if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                    records[index] = existingRecord
                } else {
                    records.append(existingRecord)
                }
            } else {
                let newRecord = SqlDailyTracker(date: date.startOfDay)
                records.append(newRecord)
                updateMockDB(with: newRecord)
                record = newRecord
                print("Created new record for \(date.datestampSid)")
            }
        }
    
    var body: some View {
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
                                var updatedRecord = record ?? SqlDailyTracker(date: date.startOfDay)
                                if item != .tweakWeightTwice {
                                    var countRecord = updatedRecord.itemsDict[item] ?? SqlDataCountRecord(
                                        date: date.startOfDay,
                                        countType: item,
                                        count: 0,
                                        streak: updatedRecord.itemsDict[item]?.datacount_streak ?? 0
                                    )
                                    countRecord.datacount_count = count
                                    updatedRecord.itemsDict[item] = countRecord
                                    updateMockDB(with: updatedRecord)
                                }
                                //updateMockDB(with: updatedRecord)
                                if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                                    records[index] = updatedRecord
                                } else {
                                    records.append(updatedRecord)
                                }
                                record = updatedRecord
                                // mockDBUpdateTrigger += 1 // Trigger child views to sync
                                //  print("Updated record for \(date.datestampSid): \(item.headingDisplay) count \(count)")
                            }
                        )
                    } //ForEach regular
                    
                } //VStack
            }
            .onAppear {
                syncRecordWithMockDB()
                //  print("TwentyOnePageView appeared, date: \(date.datestampSid), record: \(record?.date.datestampSid ?? "nil")")
            }
            //                .onChange(of: mockDBUpdateTrigger) { _, _ in
            //                                syncRecordWithMockDB()
            //                                print("Record updated due to mockDBUpdateTrigger for \(date.datestampSid)")
            //                 }
            //                            .onChange(of: navigateToWeightEntry) { _, isActive in
            //                                if !isActive {
            //                                    if let updatedTracker = mockDB.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
            //                                        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
            //                                            records[index] = updatedTracker
            //                                        } else {
            //                                            records.append(updatedTracker)
            //                                        }
            //                                        record = updatedTracker
            //                                        print("Updated record from mockDB after WeightEntryView for \(date.datestampSid)")
            //                                    }
            //                                }
            //                            }
            //                .onChange(of: records) { _, newRecords in
            //                                if let updatedRecord = newRecords.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
            //                                    record = updatedRecord
            //                                    print("Updated record for \(date.datestampSid) from records change")
            //                                }
            //                            }
        }
    }
    
}

//#Preview {
//    @Previewable @State var records: [SqlDailyTracker] = []
//    TwentyOnePageView(date: Date(), records: $records)
//}
