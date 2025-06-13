//
//  DozeTabPageView.swift
//  DailyDozen
//
//  Created by mc on 3/27/25.
//

import SwiftUI
import StoreKit

struct DozeTabPageView: View {
    @Environment(\.requestReview) var requestReview
    let date: Date
    @State var record: SqlDailyTracker?
    @Binding var records: [SqlDailyTracker] // Binding to main records array for saving
   // let onCountChange: (Int) -> Void // Callback to report count
    @State private var showingAlert = false
    @State private var showStarImage = false
//    private var dozeDailyStateCount: Int {
//            record?.itemsDict.values.reduce(0) { $0 + $1.datacount_count } ?? 0
//        }
    private var dozeDailyStateCount: Int {
            guard let record = record else {
                return 0
            }
        var total = 0
                for (itemType, itemRecord) in record.itemsDict {
                    if !supplementItems.contains(itemType) {
                        total += itemRecord.datacount_count
                    }
        }
            return total
        }

    private let dozeDailyStateCountMaximum = 24
    
    private var regularItems: [DataCountType] {
            DozeEntryViewModel.rowTypeArray.filter { $0 != .otherVitaminB12 }
        }
        
        private var supplementItems: [DataCountType] {
            DozeEntryViewModel.rowTypeArray.filter { $0 == .otherVitaminB12 }
        }
       
    var body: some View {
       // ScrollView {
        VStack {
            HStack {
                Text("doze_entry_header")
                Spacer()
                if showStarImage {
                    Image("ic_star")
                        .onAppear {
                            requestReview()
                        }
                }
                // Text("4/24") // TBDz, NYI
                Text("\(dozeDailyStateCount)/\(dozeDailyStateCountMaximum)")
                //Text("\(dozeDailyStateCount)/\(DozeEntryViewModel.rowTypeArray.reduce(0) { $0 + $1.goalServings })")
                NavigationLink(destination: DozeServingsHistoryView(trackers: fetchSQLData())) {
                    Image("ic_stat")
                }
                
            }
            
            .padding(10)
            ScrollView {
                VStack {
                    //  Text(date, style: .date)
                    ForEach(regularItems, id: \.self) { item in
                        DozeEntryRowView(
                            item: item,
                            record: record,
                            date: date,
                            onCheck: { count in
                                // create tracker, if tracker does not exist i.e. == nil.
                                if record == nil {
                                    let newRecord = SqlDailyTracker(date: date)
                                    record = newRecord
                                    records.append(newRecord)
                                }
                                // update the tracker
                                record?.itemsDict[item]?.datacount_count = count
                                showStarImage = dozeDailyStateCount == dozeDailyStateCountMaximum // Update star visibility
                            }
                        )
                    } //ForEach regular
                    if !supplementItems.isEmpty {
                        HStack {
                            Text("dozeOtherInfo.section")
                                .font(.headline)
                                .padding(.top, 20)
                                .padding(.horizontal, 10)
                            Button {
                                showingAlert.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.nfDarkGray)
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text( "dozeOtherInfo.title"), message: Text("dozeOtherInfo.message"))
                            }
                        }
                        
                        ForEach(supplementItems, id: \.self) { item in
                            DozeEntryRowView(
                                item: item,
                                record: record,
                                date: date,
                                onCheck: { count in
                                    // create tracker, if tracker does not exist i.e. == nil.
                                    if record == nil {
                                        let newRecord = SqlDailyTracker(date: date)
                                        record = newRecord
                                        records.append(newRecord)
                                    }
                                    // update the tracker
                                    record?.itemsDict[item]?.datacount_count = count
                                }
                            )
                        }
                    }
                } //VStack
            }
        }
         .onAppear {
                     record = records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    // onCountChange(dozeDailyStateCount) // Initial count
//             print("DatePageView onAppear: date = \(date), record = \(String(describing: record?.itemsDict))")
//             print("***")
                    showStarImage = dozeDailyStateCount == dozeDailyStateCountMaximum
                 }
     }
 }
//#Preview {
//    DozeTabPageView(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), record: b, records: [b])
//}
//(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), records: $records)
//#Preview {
//    
//    @State var records = [a,b]
//    
//        DozeTabPageView(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), records: $records)
//}

//#Preview {
//    DozeTabPageView(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), records: .constant([a, b]))
//}
//Add logic in DatePageView’s onCheck to modify the existing record when a checkbox changes:

//
//if record != nil {
//    var updatedItemsDict = record!.itemsDict
//    updatedItemsDict[item] = SqlDataCountRecord(
//        datacount_date_psid: DateFormatter.sqliteDateFormat.string(from: date),
//        datacount_kind_pfnid: item.hashValue,
//        datacount_count: count,
//        datacount_streak: updatedItemsDict[item]?.datacount_streak ?? 0
//    )
//    let updatedRecord = SqlDailyTracker(date: date, itemsDict: updatedItemsDict)
//    if let index = records.firstIndex(where: { $0.date == date }) {
//        records[index] = updatedRecord
//    }
//    record = updatedRecord
//}
//
//Database Integration:
//Replace records.append and array updates with your database calls (e.g., SQLite inserts/updates).

struct DozeTabPageView_Previews: PreviewProvider {
    static var previews: some View {
        // Wrapper to provide state for preview
        struct PreviewWrapper: View {
            @State private var records: [SqlDailyTracker] = []
            @State private var countDisplay: Int = 0
            
            var body: some View {
                VStack {
                    DozeTabPageView(
                        date: Date(),
                        records: $records
                       // onCountChange: { newCount in
                           // countDisplay = newCount
                      //  }
                    )
//                    Text("Total Checkboxes: \(countDisplay)")
//                        .padding()
                }
            }
        }
        
        return PreviewWrapper()
    }
}
