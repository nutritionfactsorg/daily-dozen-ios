//
//  DozeTabView.swift
//  DailyDozen
//
//  Created by mc on 3/27/25.
//

import SwiftUI

struct DozeTabView: View {
    
    var streakCount = 3000 // NYI Calulation on how to calculate streek -- just a placeholder for now
    @State private var records: [SqlDailyTracker] = returnSQLDataArray()
    // @State private var records: [SqlDailyTracker] = []
    @State private var isShowingSheet = false
    @State private var selectedRecord: SqlDailyTracker?
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
   // @State private var dozeDailyStateCount: Int = 0
    
    let direction: Direction = .leftToRight
    //@State var xCheckbox: Int = 1
    
    private func recordForDate(_ date: Date) -> SqlDailyTracker? {
        records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    //  TBDz :: Would this be needed in production?
    //        init(records: [SqlDailyTracker]) {
    //            self._records = State(initialValue: records)
    //        }
    private func extendDateRangeIfNeeded(for index: Int) {
        let calendar = Calendar.current
        let bufferDays = 30
        let today = calendar.startOfDay(for: Date()) // User's current date
        
        // If dateRange is empty, initialize it from 30 days before today up to today
        if dateRange.isEmpty {
            dateRange = (-bufferDays...0).map { offset in
                calendar.date(byAdding: .day, value: offset, to: today)!
            }
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = todayIndex
                selectedDate = dateRange[todayIndex]
            }
        }
        
        // Extend backward if approaching the start
        if index <= bufferDays {
            let earliestDate = dateRange.first!
            let newDates = (1...bufferDays).map { offset in
                calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
            }.reversed()
            dateRange.insert(contentsOf: newDates, at: 0)
            currentIndex += bufferDays // Adjust index after inserting new dates
        }
        
        // Extend forward only up to today, if needed
        if index >= dateRange.count - bufferDays - 1 {
            let latestDate = dateRange.last!
            if latestDate < today { // Only extend if not yet at today
                let daysToToday = calendar.dateComponents([.day], from: latestDate, to: today).day!
                let daysToAdd = min(bufferDays, max(daysToToday, 0)) // Cap at today
                let newDates = (1...daysToAdd).map { offset in
                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
                }
                dateRange.append(contentsOf: newDates)
            }
            // Prevent currentIndex from exceeding today's index
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = min(currentIndex, todayIndex)
            }
        }
    }
    
    private var isToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard !dateRange.isEmpty, currentIndex >= 0, currentIndex < dateRange.count else {
            return false // Default to false if dateRange isn’t ready
        }
        return calendar.isDate(dateRange[currentIndex], inSameDayAs: today)
    }
    
    private func goToToday() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            currentIndex = todayIndex
            selectedDate = dateRange[todayIndex]
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) { // Use ZStack to layer content
                VStack {
                    DozeHeaderView(isShowingSheet: $isShowingSheet,
                                   currentDate: dateRange.isEmpty ? Date() : dateRange[currentIndex]
                    )
                    
                    TabView(selection: $currentIndex) {
                        ForEach(dateRange.indices, id: \.self) { index in
                            DozeTabPageView(
                                date: dateRange[index],
                                records: $records
                            )
                            .tag(index)
                        }  //ForEach
                        //  }
                        
                    } //TabView
                    //.tabViewStyle(.page)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 500)
                    //  .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: currentIndex) { newIndex in
                        selectedDate = dateRange[newIndex]
                        extendDateRangeIfNeeded(for: newIndex)
                    } //onChange
                    //Spacer to push content up if needed
                   // Spacer()
                }//VStack
                DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                    .frame(maxWidth: .infinity) // Ensure it spans the width
                    .background(Color.clear) // Avoid obstructing content behind
            } //ZStack
            
            .sheet(isPresented: $isShowingSheet) {
                DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
                    .presentationDetents([.medium])
            } //sheet
            .onAppear {
                extendDateRangeIfNeeded(for: currentIndex)
            }
            .navigationTitle(Text("navtab.doze")) //!!Needs localization comment
            .navigationBarTitleDisplayMode(.inline)
            //
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
        }//NavStack
    }
}

//#Preview {
//   // DozeTabView(records: sampleSQLArray)
//    DozeTabView()
//}

// Wrapper to initialize state for preview
#Preview {
    struct PreviewWrapper: View {
        @State private var records: [SqlDailyTracker] = []
        @State private var dateRange: [Date] = (-30...0).map { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        }
        @State private var currentIndex = 0 // Start 30 days ago to show button
        
        var body: some View {
            DozeTabView()
            // .environment(\.records, $records)
            // Inject initial state to avoid relying solely on onAppear
            // .environmentObject(DozeTabViewModel(dateRange: dateRange, currentIndex: currentIndex))
        }
    }
    
    return PreviewWrapper()
}

//extension EnvironmentValues {
//    var records: Binding<[SqlDailyTracker]> {
//        get { self[RecordsEnvironmentKey.self] }
//        set { self[RecordsEnvironmentKey.self] = newValue }
//    }
//}

//#Preview {
//    struct PreviewWrapper: View {
//        @State private var records: [SqlDailyTracker] = []
//        @State private var currentIndex = 0
//        @State private var dateRange: [Date] = (-30...0).map { offset in
//            Calendar.current.date(byAdding: .day, value: offset, to: Date())!
//        }
//
//        var body: some View {
//            DozeTabView()
//              //  .environment(\.records, $records)
//              //  .environment(\.currentIndex, $currentIndex) // If you add this as an environment value
//             //   .environment(\.dateRange, $dateRange)
//        }
//    }
//
//    return PreviewWrapper()
//}

//    #Preview {
//        DozeTabView(records: [
//            SqlDailyTracker(date: Date(timeIntervalSinceReferenceDate: 732828019)),
//            //SqlDailyTracker(date: Calendar.current.startOfDay(for: Date()),
//            SqlDailyTracker(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
//            SqlDailyTracker(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!)
//        ])
//    }

//func updateCheckedCount(_ newCount: Int, totalCheckboxes: Int) {
//var checkedCount = min(newCount, totalCheckboxes)  // Keep it within bounds
//// You'd also save this to the database here
//}
//private func handleTap(index: Int, numBoxes: Int, numxCheckedBoxes: Int) {
//let x = numxCheckedBoxes
//// xCheckbox = numBoxes
//let adjustedIndex = direction == .leftToRight ? index : (numBoxes - 1 - index)
//
//// If tapping an unchecked box
//if adjustedIndex >= x {
//    // x = adjustedIndex + 1
//    updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
//}
//// If tapping a checked box
//else {
//    // Uncheck this box and everything after it
//    // x = adjustedIndex
//    updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
//}
//
//print("Tap \(adjustedIndex)")
////saveToDatabase here if want to save after each tap. might be overkill and may want to just save when View Disappears
//}
