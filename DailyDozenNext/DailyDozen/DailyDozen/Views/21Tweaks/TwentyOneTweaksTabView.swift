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
  
    @State private var scrollCoordinator = ScrollPositionCoordinator()
    @State private var isExtending = false  // flag to guard reentrancy
    
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
    
    private func extendDateRangeIfNeeded(for index: Int) {
        let calendar = Calendar.current
        let bufferDays = 30
        let today = calendar.startOfDay(for: Date())
        
        if dateRange.isEmpty {
            dateRange = (-bufferDays...0).map { offset in
                calendar.date(byAdding: .day, value: offset, to: today)!
            }
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = todayIndex
                selectedDate = dateRange[todayIndex]
            }
        }
        
        var newDatesAdded = false
        var newDates: [Date] = []
        
        if index <= bufferDays {
            let earliestDate = dateRange.first!
            newDates = (1...bufferDays).map { offset in
                calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
            }.reversed()
            dateRange.insert(contentsOf: newDates, at: 0)
            currentIndex += bufferDays
            newDatesAdded = true
        }
        
        if index >= dateRange.count - bufferDays - 1 {
            let latestDate = dateRange.last!
            if latestDate < today {
                let daysToToday = calendar.dateComponents([.day], from: latestDate, to: today).day!
                let daysToAdd = min(bufferDays, max(daysToToday, 0))
                newDates = (1...daysToAdd).map { offset in
                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
                }
                dateRange.append(contentsOf: newDates)
                newDatesAdded = true
            }
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = min(currentIndex, todayIndex)
            }
        }
        
        if newDatesAdded {
            Task {
                for date in newDates {
                    await viewModel.loadTracker(forDate: date)
                }
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
            ZStack {
                VStack {
                    DozeHeaderView(isShowingSheet: $isShowingSheet,
                                   currentDate: dateRange.isEmpty ? Date() : dateRange[currentIndex]
                    )
                    
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
                        guard !isExtending else { return }
                        
                        let newDate = dateRange[newIndex]
                        selectedDate = newDate
                        
                        isExtending = true
                        extendDateRangeIfNeeded(for: newIndex)
                        isExtending = false
                        
                        Task {
                            await viewModel.loadTracker(forDate: newDate)
                            // Preload ±3 adjacent (adjust to ±5 if needed for deeper swipes)
                            let preloadRange = 3
                            for i in 1...preloadRange {
                                if currentIndex >= i {
                                    await viewModel.loadTracker(forDate: dateRange[currentIndex - i])
                                }
                                if currentIndex < dateRange.count - i {
                                    await viewModel.loadTracker(forDate: dateRange[currentIndex + i])
                                }
                            }
                        }
                    } //onChange
                    
                    Spacer()
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if !isToday {
                        DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                            .background(Color.white)  // Match background to avoid transparency
                    }
                } //safearea
            }
            .background(Color.white)
            
            .sheet(isPresented: $isShowingSheet) {
                DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
                    .presentationDetents([.medium])
            }
            .onAppear {
                print("•••21Tweaks appeared•••")
                extendDateRangeIfNeeded(for: currentIndex)
//                Task {
//                    for index in max(0, currentIndex - 5)...min(dateRange.count - 1, currentIndex + 5) {
//                        await viewModel.loadTracker(forDate: dateRange[index])
//                    }
//                }
                Task {
                    let preloadStart = max(0, currentIndex - 15)  // Wider backward preload
                    let preloadEnd = min(dateRange.count - 1, currentIndex + 5)
                    for index in preloadStart...preloadEnd {
                        await viewModel.loadTracker(forDate: dateRange[index])
                    }
                }
            }
            .navigationTitle(Text("navtab.tweaks")) //!!Needs localization comment
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
            .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
                
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
