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
                               // weightViewModel: weightViewModel,
                               // navigateToWeightEntry: $navigateToWeightEntry,
                                onCheck: { count in
                                    guard var updatedRecord = record else { return }
                                    updatedRecord.itemsDict[item]?.datacount_count = count
                                    updateMockDB(with: updatedRecord)
                                    if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                                        records[index] = updatedRecord
                                    }
                                    record = updatedRecord
                                    showStarImage = tweakStateCount == tweakStateCountMaximum
                                    print("Updated record for \(date.datestampSid): count \(count)")
                                }
                               
                            )
                        } //ForEach regular
                        
                    } //VStack
                }
                .onAppear {
                                if let existingRecord = records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date.startOfDay) }) {
                                    record = existingRecord
                                } else {
                                    let newRecord = SqlDailyTracker(date: date.startOfDay)
                                    records.append(newRecord)
                                    updateMockDB(with: newRecord)
                                    record = newRecord
                                    print("Created new record for \(date.datestampSid)")
                                }
                                print("TwentyOnePageView appeared, date: \(date.datestampSid), record: \(record?.date.datestampSid ?? "nil")")
                            }
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
                        }
        }
    
}

//#Preview {
//    @Previewable @State var records: [SqlDailyTracker] = []
//    TwentyOnePageView(date: Date(), records: $records)
//}
