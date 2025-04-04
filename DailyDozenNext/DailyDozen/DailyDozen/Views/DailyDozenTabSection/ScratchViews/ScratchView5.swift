//
//  ScratchView5.swift
//  DailyDozen
//
//  Created by mc on 3/26/25.
//
import SwiftUI

//struct SqlDailyTracker2 {
//   // let id = UUID()
//    let date: Date
//    var itemsDict: [String] // Simplified as an array of strings
//}
   //  Your data model
//
    // Main View
struct ScratchView5: View {
        // Your data (example initialization)
//        @State private var records: [SqlDailyTracker2] = [
//            SqlDailyTracker2(date: Date(timeIntervalSinceReferenceDate: 732828019), itemsDict: ["Meeting Notes"]), // Approx 2025-03-26 01:20:19 +0000
//            SqlDailyTracker2(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, itemsDict: ["Lunch Plans"]),
//            SqlDailyTracker2(date: Calendar.current.date(byAdding: .day, value: -365, to: Date())!, itemsDict: ["Old Task"])
 //       ]
    @State private var records: [SqlDailyTracker] = returnSQLDataArray()
    
        @State private var selectedDate = Date()
        @State private var showingDatePicker = false
        @State private var currentIndex = 0
        @State private var dateRange: [Date] = []

    // Set Date Format
    // Initializer for your data
    init(records: [SqlDailyTracker]) {
        self._records = State(initialValue: records)
    }
        // Initialize or extend date range
        private func extendDateRangeIfNeeded(for index: Int) {
            let calendar = Calendar.current
            let bufferDays = 30
            
            if dateRange.isEmpty {
                let today = calendar.startOfDay(for: Date())
                dateRange = (-bufferDays...bufferDays).map { offset in
                    calendar.date(byAdding: .day, value: offset, to: today)!
                }
                if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                    currentIndex = todayIndex
                    selectedDate = dateRange[todayIndex]
                }
            }
            
            if index <= bufferDays {
                let earliestDate = dateRange.first!
                let newDates = (1...bufferDays).map { offset in
                    calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
                }.reversed()
                dateRange.insert(contentsOf: newDates, at: 0)
                currentIndex += bufferDays
            }
            
            if index >= dateRange.count - bufferDays - 1 {
                let latestDate = dateRange.last!
                let newDates = (1...bufferDays).map { offset in
                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
                }
                dateRange.append(contentsOf: newDates)
            }
        }
        
        // Find record for a given date
        private func recordForDate(_ date: Date) -> SqlDailyTracker? {
            records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
        }
        
        var body: some View {
            VStack {
                TabView(selection: $currentIndex) {
                  
                    ForEach(Array(dateRange.indices), id: \.self) { index in
                        
                        let date = dateRange[index]
                        Text(date, style: .date)
                       // Text(String(from: date))
//                      Text(formatter1.string(from: date))
                        let record = recordForDate(date)
                        VStack {
                            if let record = record {
                              
                                ForEach(DozeEntryViewModel.rowTypeArray, id: \.self) { item in
                                    VStack {
                                        let itemData = record.itemsDict[item]
                                        // Text(record.itemsDict[item])
                                    
                                        Text(item.headingDisplay)
                                       // Text("There's something")
                                       // Text item
                                    }
                                } //ForEach
                                
                                //Text(record.itemsDict.count)
                                
                                //                                    .font(.largeTitle)
                            }
//                            if let record = record {
//                                Text(record.itemsDict.count)
//                                Text(record.itemsDict[.dozeBeans]?.datacount_count)
//                                    .font(.largeTitle)
//                                Text(record.date, style: .date)
                        else {
                             Text("No Record")
                                  .font(.largeTitle)
                             Text(date, style: .date)
                           }
                       }
                        .tag(index)
                    } //ForEach
                }
                .tabViewStyle(.page)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: currentIndex) { newIndex in
                    selectedDate = dateRange[newIndex]
                    extendDateRangeIfNeeded(for: newIndex)
                }
                Button(action: { showingDatePicker.toggle() }) {
                    Text("Select Date")
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView3b(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
            }
            .onAppear {
                extendDateRangeIfNeeded(for: currentIndex)
            }
        }
        
    }

    // Date Picker View
    struct DatePickerView3b: View {
        @Binding var selectedDate: Date
        @Binding var dateRange: [Date]
        @Binding var currentIndex: Int
        @Environment(\.dismiss) var dismiss
        
        private func extendDateRangeForSelectedDate() {
            let calendar = Calendar.current
            if let earliestDate = dateRange.first, let latestDate = dateRange.last {
                if selectedDate < earliestDate {
                    let daysToAdd = calendar.dateComponents([.day], from: selectedDate, to: earliestDate).day!
                    let newDates = (1...daysToAdd).map { offset in
                        calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
                    }.reversed()
                    dateRange.insert(contentsOf: newDates, at: 0)
                    currentIndex += daysToAdd
                } else if selectedDate > latestDate {
                    let daysToAdd = calendar.dateComponents([.day], from: latestDate, to: selectedDate).day!
                    let newDates = (1...daysToAdd).map { offset in
                        calendar.date(byAdding: .day, value: offset, to: latestDate)!
                    }
                    dateRange.append(contentsOf: newDates)
                }
            }
        }
        
        var body: some View {
            VStack {
                DatePicker("Select Date", selection: $selectedDate,
                           in: ...Date(),
                           displayedComponents: .date)
                
                    .datePickerStyle(.graphical)
                Button("Done") {
                    extendDateRangeForSelectedDate()
                    if let index = dateRange.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
                        currentIndex = index
                    }
                    dismiss()
                }
            }
            .padding()
        }
    }

#Preview {
   ScratchView5(records: sampleSQLArray)
   // ScratchView5()
}
