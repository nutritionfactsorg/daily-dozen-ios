//
//  TwentyOneTweaksTabView.swift
//
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import HealthKit

//TBDz needs star calculation

struct TwentyOneTweaksTabView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showHealthKitError = false // Controls whether the alert is shown
    @State private var healthKitErrorMessage = "" // Stores the error message for the alert
    //var streakCount = 0 // NYI Calulation on how to calculate streek -- just a placeholder for now
    //@State private var records: [SqlDailyTracker] = fetchSQLData()
    @State private var isShowingSheet = false
   // @State private var selectedRecord: SqlDailyTracker?
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
    @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    @State private var isLoadingDate = false
   // @State private var tabSelection: Int = 30
    
    let direction: Direction = .leftToRight
    
    private func checkHealthAvail() async {
            if HKHealthStore.isHealthDataAvailable() {
                await logit.debug("Yes, HealthKit is Available")
                Task {
                    if await HealthManager.shared.isAuthorized() {
                        await logit.debug("•HK• Already authorized, skipping permission request")
                        return
                    }
                    do {
                        try await HealthManager.shared.requestPermissions()
                        await logit.debug("•HK• HealthKit permissions granted")
                    } catch {
                        await logit.error("•HK• HealthKit permission error: \(error.localizedDescription)")
                        showHealthKitError = true
                        healthKitErrorMessage = error.localizedDescription
                    }
                }
            } else {
                await logit.debug("There is a problem accessing HealthKit")
                showHealthKitError = true
                healthKitErrorMessage = "HealthKit is not available on this device"
            }
    }
    
//    private func recordForDate(_ date: Date) -> SqlDailyTracker? {
//        records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
//    }
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
      //  print("🔴 today is \(today)")
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
                                
                                TwentyOnePageView(date: dateRange[index])
                                    .tag(index)
                                    .environmentObject(viewModel)
                      
                            }
                                //  }
                            
                        } //TabView
                        //.tabViewStyle(.page)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(minHeight: 300, maxHeight: .infinity)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onChange(of: currentIndex) { _, newIndex in
                            Task {
                                await viewModel.loadTracker(forDate: selectedDate)
                                    // Optional: Preload adjacent for smoother swipes
                                    if newIndex > 0 { await viewModel.loadTracker(forDate: dateRange[newIndex - 1]) }
                                    if newIndex < dateRange.count - 1 { await viewModel.loadTracker(forDate: dateRange[newIndex + 1]) }
                            }
//                            guard !isLoadingDate else {return}
//                            isLoadingDate = true
//                            selectedDate = dateRange[newIndex]
//                            extendDateRangeIfNeeded(for: newIndex)
//                            Task { @MainActor in
//                                guard !isLoadingDate else { return }
//                                isLoadingDate = true
//                                selectedDate = dateRange[newIndex]
//                                
//                                extendDateRangeIfNeeded(for: newIndex)
//                                
//                                Task { @MainActor in
//                                    await viewModel.loadTracker(forDate: selectedDate)
//                                    isLoadingDate = false
//                                }
//                            }
                        } //onChange
//                            // Refresh records from mockDB
////                            Task { @MainActor in
////                                   //await viewModel.loadTracker(forDate: dateRange[newIndex])
////                               // await viewModel.loadTracker(forDate: dateRange[newIndex].startOfDay)
////                                await viewModel.loadTracker(forDate: selectedDate)
////                                isLoadingDate = false
////                                 }
//                          //  mockDBUpdateTrigger += 1 // Trigger child views to sync
////                            print("Updated records for index \(newIndex), date: \(dateRange[newIndex].datestampSid), records count: \(records.count)")
////                            print("mockDB contents: \(mockDB.map { ($0.date.datestampSid, $0.weightAM.dataweight_kg, $0.weightPM.dataweight_kg, $0.itemsDict.map { ($1.key.headingDisplay, $1.value.datacount_count) }) })")
//                        } //onChange
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
//                .onAppear {
//                    extendDateRangeIfNeeded(for: currentIndex)
//                   // records = fetchSQLData()  duplicate data?
//                    Task { @MainActor in
//                          await viewModel.loadTracker(forDate: selectedDate)
//                          }
//                 //   print("TwentyOneTweaksTabView appeared, records count: \(records.count)")
//                }
                .onAppear {
                    extendDateRangeIfNeeded(for: currentIndex)
                    Task {
                        
                        //                      @MainActor in
                        //                        await viewModel.loadTracker(forDate: selectedDate)
                        for index in max(0, currentIndex - 5)...min(dateRange.count - 1, currentIndex + 5) {
                            await viewModel.loadTracker(forDate: dateRange[index])
                            
                        }
                    }
                    
                }
            
//            onAppear {
//                if dateRange.isEmpty {
//                    extendDateRangeIfNeeded(for: tabSelection)
//                    selectedDate = dateRange[tabSelection]
//                    Task { @MainActor in
//                        await viewModel.loadTracker(forDate: selectedDate.startOfDay)
//                        print("🟢 •Tab• Initialized dateRange, selected index \(tabSelection), date \(selectedDate.datestampSid)")
//                    }
//                }
//            }
//            .onChange(of: tabSelection) { _, newIndex in
//                            guard !isLoadingDate else { return }
//                            isLoadingDate = true
//                            selectedDate = dateRange[newIndex]
//                            Task { @MainActor in
//                                await viewModel.loadTracker(forDate: selectedDate.startOfDay)
//                                extendDateRangeIfNeeded(for: newIndex)
//                                print("🟢 •Tab• Switched to index \(newIndex), date \(selectedDate.datestampSid)")
//                                isLoadingDate = false
//                            }
//                        }
                .navigationTitle(Text("navtab.tweaks")) //!!Needs localization comment
                .navigationBarTitleDisplayMode(.inline)
                //
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.brandGreen, for: .navigationBar)
                .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
                                Task {
                                    @MainActor in
                                   // await viewModel.loadTracker(forDate: dateRange[currentIndex])
                                    await viewModel.loadTracker(forDate: selectedDate)
                                }
                            }
          } //Nav
            
        .task {
            await checkHealthAvail()
                }
        //TBDZ not sure this is needed
        .alert("HealthKit Error", isPresented: $showHealthKitError) {
                    Button("OK") { }
                } message: {
                    Text(healthKitErrorMessage)
                }
        }
    
}

#Preview {
    TwentyOneTweaksTabView()
}
