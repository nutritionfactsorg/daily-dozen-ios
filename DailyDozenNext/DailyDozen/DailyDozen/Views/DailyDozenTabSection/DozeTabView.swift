//
//  DozeTabView.swift
//  DailyDozen
//

import SwiftUI

struct DozeTabView: View {
    
    private let viewModel = SqlDailyTrackerViewModel.shared
    var streakCount = 3000 // Placeholder
    @State private var isShowingSheet = false
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
    @State private var isLoadingDate = false // Prevent rapid loadTracker calls
    @State private var scrollCoordinator = ScrollPositionCoordinator()
    @State private var isDataReady = false  // 👈 NEW: Gatekeeper
    @State private var preloadTask: Task<Void, Never>?  // 👈 NEW: Guard re-run
    
    private var currentDisplayDate: Date {
        // Safest possible date to show in header
        if dateRange.indices.contains(currentIndex) {
            return dateRange[currentIndex]
        } else {
            return Calendar.current.startOfDay(for: Date()) // fallback = today
        }
    }
    
    let direction: Direction = .leftToRight
    
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
//        if index <= bufferDays {
//            let earliestDate = dateRange.first!
//            let newDates = (1...bufferDays).map { offset in
//                calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
//            }.reversed()
//            dateRange.insert(contentsOf: newDates, at: 0)
//            currentIndex += bufferDays
//        }
//        
//        if index >= dateRange.count - bufferDays - 1 {
//            let latestDate = dateRange.last!
//            if latestDate < today {
//                let daysToToday = calendar.dateComponents([.day], from: latestDate, to: today).day!
//                let daysToAdd = min(bufferDays, max(daysToToday, 0))
//                let newDates = (1...daysToAdd).map { offset in
//                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
//                }
//                dateRange.append(contentsOf: newDates)
//            }
//            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
//                currentIndex = min(currentIndex, todayIndex)
//            }
//        }
//    }
    private func extendDateRangeIfNeeded(for index: Int) {
        if dateRange.isEmpty {
            viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex)
            return
        }
        
        let buffer = 30
        if index <= buffer, let earliest = dateRange.first {
            let newEarliest = Calendar.current.date(byAdding: .day, value: -buffer, to: earliest)!
            viewModel.ensureDateIsInRange(newEarliest, dateRange: &dateRange, currentIndex: &currentIndex, thenSelectIt: false)
        }
    }
    
//    private var isToday: Bool {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        guard !dateRange.isEmpty, currentIndex >= 0, currentIndex < dateRange.count else {
//            return false
//        }
//        return calendar.isDate(dateRange[currentIndex], inSameDayAs: today)
//    }
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
        
        print("🟢 •Doze• READY (\(preloadEnd - preloadStart + 1) days preloaded)")
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
                            
                            TabView(selection: $currentIndex) {
                                ForEach(dateRange.indices, id: \.self) { index in
                                    DozeTabPageView(coordinator: scrollCoordinator, date: dateRange[index])  // ← Pass
                                        .tag(index)
                                        .environmentObject(viewModel)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(minHeight: 300, maxHeight: .infinity)
                            .onChange(of: currentIndex) { oldValue, newValue in
                                if newValue >= dateRange.count - 1 && newValue > oldValue {
                                    // Trying to swipe right past today → snap back
                                    withAnimation {
                                        currentIndex = dateRange.count - 1
                                    }
                                } else {
                                    // normal swipe handling
                                    selectedDate = dateRange[newValue]
                                    extendDateRangeIfNeeded(for: newValue)
                                    // ... preload task
                                }
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
                        //                DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                        //                    .padding(.bottom, 0)
                        //                    .background(Color.white.ignoresSafeArea(edges: .bottom))
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
            // .navigationTitle(Text("navtab.doze"))
            
            .task {
                viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex)
                // preload today + last 14 days
                for date in dateRange.suffix(15) {
                    await viewModel.loadTracker(forDate: date, isSilent: true)
                }
                isDataReady = true
            }
        } //NavStack
    }
}

#Preview {
    DozeTabView()
        .environmentObject(SqlDailyTrackerViewModel())
}
