//
//  DozeTabView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var isShowingSheet = false
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
    @State private var isLoadingDate = false // Prevent rapid loadTracker calls
    @State private var scrollCoordinator = ScrollPositionCoordinator()
    @State private var isDataReady = false  // Gatekeeper
    @State private var preloadTask: Task<Void, Never>?  // Guard re-run
    
    private var currentDisplayDate: Date {
        if dateRange.indices.contains(currentIndex) {
            return dateRange[currentIndex]
        } else {
            return Calendar.current.startOfDay(for: Date()) // fallback = today
        }
    }
    
    let direction: Direction = .leftToRight
    
    private func extendDateRangeIfNeeded(for index: Int) {
        if dateRange.isEmpty {
            viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex, thenSelectIt: true)
            return
        }
        
        let buffer = 30
        if index <= buffer, let earliest = dateRange.first {
            let newEarliest = Calendar.current.date(byAdding: .day, value: -buffer, to: earliest)!
            viewModel.ensureDateIsInRange(newEarliest, dateRange: &dateRange, currentIndex: &currentIndex, thenSelectIt: false)
        }
    }
    
    private var isToday: Bool {
        dateRange.indices.contains(currentIndex) &&
        Calendar.current.isDate(dateRange[currentIndex], inSameDayAs: Date())
    }
    
    private func goToToday() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            currentIndex = todayIndex
            selectedDate = dateRange[todayIndex]
        }
    }
    
    private func preloadAllData() async {
        extendDateRangeIfNeeded(for: currentIndex)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) ?? 0
        let preloadStart = max(0, startIndex - 30)
        let preloadEnd = min(dateRange.count - 1, startIndex + 30)
        
        // : Sequential = DB speed**
        for index in preloadStart...preloadEnd {
            await viewModel.loadTracker(forDate: dateRange[index], isSilent: true)
        }
        
        print("•INFO•Doze• READY (\(preloadEnd - preloadStart + 1) days preloaded)")
    }
    
    private func preloadSomeData() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        dateRange = (-10...0).map { calendar.date(byAdding: .day, value: $0, to: today)! }
        if let todayIdx = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            currentIndex = todayIdx
            selectedDate = dateRange[todayIdx]
        }
        
        // Preload only visible + nearby pages, not everything
        await viewModel.loadTracker(forDate: today, isSilent: true)
        let nearby = dateRange.indices.filter { abs($0 - currentIndex) <= 3 }
        for i in nearby {
            await viewModel.loadTracker(forDate: dateRange[i], isSilent: true)
        }
    }
    
    private func ensureCurrentTodayInRangeAndPreloadIfNew() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if today is already in the range
        let alreadyPresent = dateRange.contains { calendar.isDate($0, inSameDayAs: today) }
        
        // Ensure it's in the range (your viewModel likely appends it if missing)
        viewModel.ensureDateIsInRange(
            today,
            dateRange: &dateRange,
            currentIndex: &currentIndex,
            thenSelectIt: false  // Don't auto-jump yet
        )
        
        // Only preload if it was newly added
        if !alreadyPresent, let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            Task {
                await viewModel.loadTracker(forDate: dateRange[todayIndex], isSilent: true)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if !isDataReady {
                    ZStack {
                        Color.white.ignoresSafeArea()
                        ProgressView("loading_heading")
                            .progressViewStyle(CircularProgressViewStyle(tint: .nfGreenBrand))
                            .scaleEffect(1.5)
                    } //ZStack
                } else {
                    ZStack {
                        VStack {
                            DozeHeaderView(isShowingSheet: $isShowingSheet,
                                           currentDate: currentDisplayDate)
                                .frame(maxWidth: .infinity)  // Centers horizontally if in a VStack
                                .padding(.horizontal)        // Optional safe margins
                            
                            TabView(selection: $currentIndex) {
                                ForEach(dateRange.indices, id: \.self) { index in
                                    DozePageView(coordinator: scrollCoordinator, date: dateRange[index])  // ← Pass
                                        .tag(index)
                                        .environmentObject(viewModel)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(minHeight: 300, maxHeight: .infinity)
                            .onChange(of: currentIndex) { _, newValue in
                               // let _ = Self._printChanges()  // Prints changed properties
                                print("•INFO•DozeTab•  \(currentIndex)")
                                let maxIndex = dateRange.count - 1
                                // Only block if trying to go BEYOND today
                                if newValue > maxIndex {
                                    // This happens on attempted future swipe OR overshoot
                                    withAnimation {
                                        currentIndex = maxIndex
                                    }
                                    
                                    print("•INFO•DozeTab• Blocked future access, snapped to \(maxIndex)")
                                    return  // Critical: prevent rest of logic
                                }
                                selectedDate = dateRange[newValue]
                                Task {@MainActor in
                                    extendDateRangeIfNeeded(for: newValue)
                                }
                                
                            print("•INFO•DozeTab• Updated to \(selectedDate.formatted()) at index \(newValue)")
                            } //onChange
                            //  }  //Else
                            Spacer()
                        }
                        .background(Color.white)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            if !isToday {
                                DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                                    .background(Color.white)  // Match background to avoid transparency
                            }
                        }   //safeArea
                        //DozeBackToTodayButtonView(isToday: isToday, action: goToToday) // •REVIEW•
                        //    .padding(.bottom, 0)
                        //    .background(Color.white.ignoresSafeArea(edges: .bottom))
                    } //ZStack
                } //else
            } //Group
            //NavStack
            
            .background(Color.white)
            .sheet(isPresented: $isShowingSheet) {
                DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
                    .presentationDetents([.medium])
            }
            .whiteInlineGreenTitle(LocalizedStringKey("navtab.doze"))
            //.whiteInlineGreenTitle(Text("navtab.doze"))
            //.navigationTitle(Text("navtab.doze"))
            
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    ensureCurrentTodayInRangeAndPreloadIfNew()
                    
                    // Optional: auto-jump if user was on the old "today"
                    let calendar = Calendar.current
                    let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
                    if dateRange.indices.contains(currentIndex),
                       calendar.isDate(dateRange[currentIndex], inSameDayAs: yesterday) {
                        goToToday()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                ensureCurrentTodayInRangeAndPreloadIfNew()
            }
            
            .task {
                viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex, thenSelectIt: true)
                // preload today + last 14 days
                for date in dateRange.suffix(15) {
                    await viewModel.loadTracker(forDate: date, isSilent: true)
                }
                isDataReady = true
            }
            .onChange(of: selectedDate) {_, newValue in
                print("•INFO• selectedDate changed → ensuring range")
                viewModel.ensureDateIsInRange(
                    newValue,
                    dateRange: &dateRange,
                    currentIndex: &currentIndex,
                    thenSelectIt: true
                )
            }
        } //NavStack
    }
}

#Preview {
    DozeTabView()
        .environmentObject(SqlDailyTrackerViewModel())
}
