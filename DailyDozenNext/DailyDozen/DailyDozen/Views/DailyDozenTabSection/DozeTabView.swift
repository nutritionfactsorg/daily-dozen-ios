//
//  DozeTabView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeTabView: View {
   // @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    var streakCount = 3000 // Placeholder
    @State private var isShowingSheet = false
    @State private var selectedDate = Date()
    @State private var currentIndex = 0
    @State private var dateRange: [Date] = []
    @State private var isLoadingDate = false // Prevent rapid loadTracker calls
    // @State private var sharedScrollOffset: CGFloat = 0
    @State private var scrollCoordinator = ScrollPositionCoordinator()
    
    @State private var isDataReady = false  // 👈 NEW: Gatekeeper
    @State private var preloadTask: Task<Void, Never>?  // 👈 NEW: Guard re-run
    
    let direction: Direction = .leftToRight
    
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
            if latestDate < today {
                let daysToToday = calendar.dateComponents([.day], from: latestDate, to: today).day!
                let daysToAdd = min(bufferDays, max(daysToToday, 0))
                let newDates = (1...daysToAdd).map { offset in
                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
                }
                dateRange.append(contentsOf: newDates)
            }
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = min(currentIndex, todayIndex)
            }
        }
    }
    
    private var isToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard !dateRange.isEmpty, currentIndex >= 0, currentIndex < dateRange.count else {
            return false
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
    
    var body: some View {
        NavigationStack {
            Group {
                if !isDataReady {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .brandGreen))
                            .scaleEffect(1.5)
                    } //ZStack
                } else {
                    ZStack {
                        VStack {
                            DozeHeaderView(isShowingSheet: $isShowingSheet, currentDate: dateRange.isEmpty ? Date() : dateRange[currentIndex])
                            //                        if viewModel.isLoading {
                            //                            ProgressView()
                            //                        } else if let error = viewModel.error {
                            //                            Text(error)
                            //                                .foregroundColor(.red)
                            //                        } else {
                            TabView(selection: $currentIndex) {
                                ForEach(dateRange.indices, id: \.self) { index in
                                    DozeTabPageView(coordinator: scrollCoordinator, date: dateRange[index])  // ← Pass
                                        .tag(index)
                                        .environmentObject(viewModel)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(minHeight: 300, maxHeight: .infinity)
                            .onChange(of: currentIndex) { _, newIndex in
                                let newDate = dateRange[newIndex]
                                selectedDate = newDate
                                extendDateRangeIfNeeded(for: newIndex)
                                // print("Swiped to index \(newIndex), date \(selectedDate), current shared offset: \(sharedScrollOffset)")
                                Task {
                                    let preloadStart = max(0, currentIndex - 15)  // Wider backward preload
                                    let preloadEnd = min(dateRange.count - 1, currentIndex + 5)
                                    for index in preloadStart...preloadEnd {
                                        await viewModel.loadTracker(forDate: dateRange[index])
                                    }
                                }
                                // isLoadingDate = false
                                
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
                
                //            .onAppear {
                //                extendDateRangeIfNeeded(for: currentIndex)
                //                Task {
                //                    for index in max(0, currentIndex - 5)...min(dateRange.count - 1, currentIndex + 5) {
                //                        await viewModel.loadTracker(forDate: dateRange[index])
                //                    }
                //                }
                //            }
                
//                .onAppear {
//                    print("🟢 •Doze• Launching...")
//                    
//                    guard preloadTask == nil else { return }  // No re-run**
//                    
//                    preloadTask = Task {
//                        await preloadAllData()
//                        await MainActor.run { isDataReady = true }
//                        print("🟢 •Doze• **READY** (preloaded \(dateRange.count) days)")
//                    }
//                }
                .navigationTitle(Text("navtab.doze"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.brandGreen, for: .navigationBar)
                .task {
                            print("🟢 •Doze• Launching...")
                            await preloadAllData()
                            isDataReady = true
                            print("🟢 •Doze• **READY** (preloaded \(dateRange.count) days)")
                        }
           } //NavStack
        }
    }

#Preview {
    DozeTabView()
        .environmentObject(SqlDailyTrackerViewModel())
}

// Wrapper to initialize state for preview
//#Preview {
//    struct PreviewWrapper: View {
//        @State private var records: [SqlDailyTracker] = []
//        @State private var dateRange: [Date] = (-30...0).map { offset in
//            Calendar.current.date(byAdding: .day, value: offset, to: Date())!
//        }
//        @State private var currentIndex = 0 // Start 30 days ago to show button
//        
//        var body: some View {
//            DozeTabView()
//            // .environment(\.records, $records)
//            // Inject initial state to avoid relying solely on onAppear
//            // .environmentObject(DozeTabViewModel(dateRange: dateRange, currentIndex: currentIndex))
//        }
//    }
//    
//    return PreviewWrapper()
//}

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
