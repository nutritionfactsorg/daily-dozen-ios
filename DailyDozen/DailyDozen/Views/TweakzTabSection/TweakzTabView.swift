//
//  TweakzTabView.swift
//
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import HealthKit

//TBDz needs star calculation

struct TweakzTabView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showHealthKitError = false // Controls whether the alert is shown
    @State private var healthKitErrorMessage = "" // Stores the error message for the alert
    @State private var isShowingSheet = false
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var isDataReady = false  // Optional: show loader
    @State private var isInitialized = false
    
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
    
    // let direction: Direction = .leftToRight // :v4: handled by system localization
    
    private func checkHealthAvail() async {
        if HKHealthStore.isHealthDataAvailable() {
            print("•DEBUG• Yes, HealthKit is Available")
            Task {
                if await HealthManager.shared.isAuthorized() {
                    print("•DEBUG•HK• Already authorized, skipping permission request")
                    return
                }
                do {
                    try await HealthManager.shared.requestPermissions()
                    print("•DEBUG•HK• HealthKit permissions requested")
                } catch {
                    print("•ERROR•HK• HealthKit permission error: \(error.localizedDescription)")
                    showHealthKitError = true
                    healthKitErrorMessage = error.localizedDescription
                }
            }
        } else {
            print("•DEBUG•HK• There is a problem accessing HealthKit")
            showHealthKitError = true
            healthKitErrorMessage = "HealthKit is not available on this device"
        }
    }
    
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
    
    private var isToday: Bool {
        dateRange.indices.contains(currentIndex) &&
        Calendar.current.isDate(dateRange[currentIndex], inSameDayAs: Date())
    }
    
    private func goToToday() {
        viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex, thenSelectIt: true)
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
                            .frame(maxWidth: .infinity)  // Centers horizontally if in a VStack
                            .padding(.horizontal)        // Optional safe margins
                        
                        TabView(selection: $currentIndex) {
                            ForEach(dateRange.indices, id: \.self) { index in
                                TweakzPageView(date: dateRange[index], coordinator: scrollCoordinator)
                                    .tag(index)
                                    .environmentObject(viewModel)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(minHeight: 300, maxHeight: .infinity)
                        .onChange(of: currentIndex) { _, newIndex in
                            selectedDate = dateRange[newIndex]
                            Task {@MainActor in
                                extendDateRangeIfNeeded(for: newIndex)
                            }
                            
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
            .onChange(of: selectedDate) { oldValue, newValue in
                print("•INFO•VIEW• TweakzTabView selectedDate \(oldValue) → \(newValue) ensureDateIsInRange")
                viewModel.ensureDateIsInRange(
                    newValue,
                    dateRange: &dateRange,
                    currentIndex: &currentIndex,
                    thenSelectIt: true
                )
            }
            .whiteInlineGreenTitle("navtab.tweaks")
            
            .onAppear {
                if !isInitialized {
                    selectedDate = Calendar.current.startOfDay(for: Date())
                    
                    Task {
                        viewModel.ensureDateIsInRange(Date(),
                                                      dateRange: &dateRange,
                                                      currentIndex: &currentIndex, thenSelectIt: true)
                        
                        // Preload today + last 20 days for instant feel
                        let preloadCount = min(20, dateRange.count)
                        for date in dateRange.suffix(preloadCount) {
                            await viewModel.loadTracker(forDate: date, isSilent: true)
                        }
                        
                        isDataReady = true
                        print("21Tweaks READY – \(dateRange.count) days loaded")
                    }
                    
                    isInitialized = true
                }
            }
                        
            //.onReceive(NotificationCenter.default.publisher(for: .sqlDBUpdated)) { _ in
            //    Task {
            //        await viewModel.loadTracker(forDate: selectedDate)
            //    }
            //} // •HACK•CHECK• may not be needed. verify if migration needs
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
    TweakzTabView()
}
