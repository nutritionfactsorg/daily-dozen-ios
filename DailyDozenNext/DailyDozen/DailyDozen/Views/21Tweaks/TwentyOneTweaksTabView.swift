//
//  TwentyOneTweaksTabView.swift
//
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import HealthKit

struct TwentyOneTweaksTabView: View {
    var streakCount = 3000 // NYI Calulation on how to calculate streek -- just a placeholder for now
    @State private var records: [SqlDailyTracker] = fetchSQLData()
    // @State private var records: [SqlDailyTracker] = []
    @State private var isShowingSheet = false
    @State private var selectedRecord: SqlDailyTracker?
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
   // @State private var navigateToWeightEntry = false
   // @State private var dozeDailyStateCount: Int = 0
  //  @State private var mockDBUpdateTrigger: Int = 0 // Trigger for mockDB updates
    let direction: Direction = .leftToRight
    
    func checkHealthAvail() {  //TBDz: Is this really done elsewhere?
        if HKHealthStore.isHealthDataAvailable() {
            // add code to use HealthKit here...
            logit.debug("Yes, HealthKit is Available")
            let healthManager = HealthManager()
            healthManager.requestPermissions()
        } else {
            logit.debug("There is a problem accessing HealthKit")
        }
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(changedWeight(notification:)),
//            name: Notification.Name(rawValue: "NoticeChangedWeight"),
//            object: nil)
    }
    
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
                               
                                TwentyOnePageView(
                                    date: dateRange[index],
                                    records: $records
                                    //navigateToWeightEntry: $navigateToWeightEntry
                                )
                                .tag(index)
                            }  //ForEach
                            //  }
                            
                        } //TabView
                        //.tabViewStyle(.page)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(minHeight: 300, maxHeight: .infinity)
                        //  .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onChange(of: currentIndex) { _, newIndex in
                            selectedDate = dateRange[newIndex]
                            extendDateRangeIfNeeded(for: newIndex)
                            // Refresh records from mockDB
                            records = fetchSQLData()
                          //  mockDBUpdateTrigger += 1 // Trigger child views to sync
//                            print("Updated records for index \(newIndex), date: \(dateRange[newIndex].datestampSid), records count: \(records.count)")
//                            print("mockDB contents: \(mockDB.map { ($0.date.datestampSid, $0.weightAM.dataweight_kg, $0.weightPM.dataweight_kg, $0.itemsDict.map { ($1.key.headingDisplay, $1.value.datacount_count) }) })")
                        } //onChange
                        //Spacer to push content up if needed
                        Spacer()
                    }//VStack
                    
                   DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                        .padding(.bottom, 0) // Remove bottom padding
                        .background(
                             Color.white
                                .ignoresSafeArea(edges: .bottom)  )
                       // .safeAreaInset(edge: .bottom) { // Ensure button stays above tab bar
                          //  Color.clear // Placeholder to respect safe area
                            // Ensure button is on top
                      //  }
                      //  .zIndex(1)
                    
                       // .frame(maxWidth: .infinity) // Ensure it spans the width
                       // .background(Color.clear) // Avoid obstructing content behind
                } //ZStack
                .background(Color.white) // Ensure solid background for TabView  (if want a different color like gray, change it here)
               
                .sheet(isPresented: $isShowingSheet) {
                    DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
                        .presentationDetents([.medium])
                } //sheet
                .onAppear {
                    extendDateRangeIfNeeded(for: currentIndex)
                   // records = fetchSQLData()  duplicate data?
                    records = fetchSQLData()
                 //   print("TwentyOneTweaksTabView appeared, records count: \(records.count)")
                }
                .navigationTitle(Text("navtab.tweaks")) //!!Needs localization comment
                .navigationBarTitleDisplayMode(.inline)
                //
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.brandGreen, for: .navigationBar)
            }
            
            .onAppear {
                checkHealthAvail()
               // records = fetchSQLData() // Initial load
            }
        }
    
}

#Preview {
    TwentyOneTweaksTabView()
}
