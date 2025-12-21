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
    @State private var isShowingSheet = false
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var isDataReady = false  // Optional: show loader if you want
  
    @State private var scrollCoordinator = ScrollPositionCoordinator()
    @State private var isExtending = false  // flag to guard reentrancy
    private var currentDisplayDate: Date {
        // Safest possible date to show in header
        if dateRange.indices.contains(currentIndex) {
            return dateRange[currentIndex]
        } else {
            return Calendar.current.startOfDay(for: Date()) // fallback = today
        }
    }
    
    let direction: Direction = .leftToRight
   
    private func checkHealthAvail() async {
        if HKHealthStore.isHealthDataAvailable() {
            print(":DEBUG: Yes, HealthKit is Available")
            Task {
                if await HealthManager.shared.isAuthorized() {
                    print(":DEBUG: •HK• Already authorized, skipping permission request")
                    return
                }
                do {
                    try await HealthManager.shared.requestPermissions()
                    print(":DEBUG: •HK• HealthKit permissions granted")
                } catch {
                    print(":ERROR: •HK• HealthKit permission error: \(error.localizedDescription)")
                    showHealthKitError = true
                    healthKitErrorMessage = error.localizedDescription
                }
            }
        } else {
            print(":DEBUG: There is a problem accessing HealthKit")
            showHealthKitError = true
            healthKitErrorMessage = "HealthKit is not available on this device"
        }
    }
    
//    private func extendDateRangeIfNeeded(for index: Int) {
//        let calendar = Calendar.current
//        let bufferDays = 30
//        let today = calendar.startOfDay(for: Date())
//        
//        if dateRange.isEmpty {
//            dateRange = (-bufferDays...0).map { offset in
//                calendar.date(byAdding: .day, value: offset, to: today)!
//            }
//            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
//                currentIndex = todayIndex
//                selectedDate = dateRange[todayIndex]
//            }
//        }
//        
//        var newDatesAdded = false
//        var newDates: [Date] = []
//        
//        if index <= bufferDays {
//            let earliestDate = dateRange.first!
//            newDates = (1...bufferDays).map { offset in
//                calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
//            }.reversed()
//            dateRange.insert(contentsOf: newDates, at: 0)
//            currentIndex += bufferDays
//            newDatesAdded = true
//        }
//        
//        if index >= dateRange.count - bufferDays - 1 {
//            let latestDate = dateRange.last!
//            if latestDate < today {
//                let daysToToday = calendar.dateComponents([.day], from: latestDate, to: today).day!
//                let daysToAdd = min(bufferDays, max(daysToToday, 0))
//                newDates = (1...daysToAdd).map { offset in
//                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
//                }
//                dateRange.append(contentsOf: newDates)
//                newDatesAdded = true
//            }
//            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
//                currentIndex = min(currentIndex, todayIndex)
//            }
//        }
//        
//        if newDatesAdded {
//            Task {
//                for date in newDates {
//                    await viewModel.loadTracker(forDate: date)
//                }
//            }
//        }
//    }
    
    // MARK: - extend on swipe (only backward)
    private func extendDateRangeIfNeeded(for index: Int) {
        guard !dateRange.isEmpty else { return }
        
        let buffer = 30
        if index <= buffer, let earliest = dateRange.first {
            let newEarliest = Calendar.current.date(byAdding: .day, value: -buffer, to: earliest)!
            viewModel.ensureDateIsInRange(newEarliest,
                                          dateRange: &dateRange,
                                          currentIndex: &currentIndex,
                                          thenSelectIt: false)  // ← crucial: don't move selection
        }
    }
    
//    private var isToday: Bool {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        guard !dateRange.isEmpty, currentIndex >= 0, currentIndex < dateRange.count else {
//            return false // Default to false if dateRange isn’t ready
//        }
//        return calendar.isDate(dateRange[currentIndex], inSameDayAs: today)
//    }
    private var isToday: Bool {
        dateRange.indices.contains(currentIndex) &&
        Calendar.current.isDate(dateRange[currentIndex], inSameDayAs: Date())
    }
    
//    private func goToToday() {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
//            currentIndex = todayIndex
//            selectedDate = dateRange[todayIndex]
//        }
//    }
    private func goToToday() {
            viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex)
            selectedDate = Calendar.current.startOfDay(for: Date())
        }
    
    // MARK: - Body
        var body: some View {
            NavigationStack(path: $navigationPath) {
                ZStack {
                    if !isDataReady {
                        ProgressView("loading_heading")
                            .progressViewStyle(CircularProgressViewStyle(tint: .nfGreenBrand))
                            .scaleEffect(1.5)
                    } else {
                        VStack {
                            DozeHeaderView(isShowingSheet: $isShowingSheet,
                                           currentDate: currentDisplayDate)
                            
                            TabView(selection: $currentIndex) {
                                ForEach(dateRange.indices, id: \.self) { index in
                                    TwentyOnePageView(date: dateRange[index], coordinator: scrollCoordinator)
                                        .tag(index)
                                        .environmentObject(viewModel)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(minHeight: 300, maxHeight: .infinity)
                            .onChange(of: currentIndex) { _, newIndex in
                                selectedDate = dateRange[newIndex]
                                extendDateRangeIfNeeded(for: newIndex)
                                
                                Task {
                                    // Preload current + nearby pages
                                    let start = max(0, newIndex - 8)
                                    let end = min(dateRange.count - 1, newIndex + 5)
                                    for i in start...end {
                                        await viewModel.loadTracker(forDate: dateRange[i], isSilent: true)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            if !isToday {
                                DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                                    .background(Color.white)
                            }
                        }
                    }
                }
            .background(Color.white)
            
            .sheet(isPresented: $isShowingSheet) {
                DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
                    .presentationDetents([.medium])
            }
            .whiteInlineGreenTitle("navtab.tweaks")

            .task {
                            // Initial load — replaces your old .onAppear
                            viewModel.ensureDateIsInRange(Date(),
                                                         dateRange: &dateRange,
                                                         currentIndex: &currentIndex)
                            selectedDate = Calendar.current.startOfDay(for: Date())
                            
                            // Preload today + last 20 days for instant feel
                            let preloadCount = min(20, dateRange.count)
                            for date in dateRange.suffix(preloadCount) {
                                await viewModel.loadTracker(forDate: date, isSilent: true)
                            }
                            
                            isDataReady = true
                            print("21Tweaks READY – \(dateRange.count) days loaded")
                        }
//            .onAppear {
//                print("•••21Tweaks appeared•••")
//                extendDateRangeIfNeeded(for: currentIndex)
////                Task {
////                    for index in max(0, currentIndex - 5)...min(dateRange.count - 1, currentIndex + 5) {
////                        await viewModel.loadTracker(forDate: dateRange[index])
////                    }
////                }
//                Task {
//                    let preloadStart = max(0, currentIndex - 15)  // Wider backward preload
//                    let preloadEnd = min(dateRange.count - 1, currentIndex + 5)
//                    for index in preloadStart...preloadEnd {
//                        await viewModel.loadTracker(forDate: dateRange[index])
//                    }
//                }
//            }
            
            .onReceive(NotificationCenter.default.publisher(for: .sqlDBUpdated)) { _ in
                
                Task {
                    await viewModel.loadTracker(forDate: selectedDate)
                }
            }
        }
        .task {
            await checkHealthAvail()
        }
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
