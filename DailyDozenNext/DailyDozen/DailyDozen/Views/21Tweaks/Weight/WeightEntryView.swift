//
//  WeightEntryView.swift
//  DailyDozen
//
// 
//

import SwiftUI
//TBDz this page needs localization
struct WeightEntryView: View {
    private let viewModel = SqlDailyTrackerViewModel.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentDate: Date
    @State private var selectedDate: Date
    @State private var dateRange: [Date] = []
    @State private var currentIndex = 0
    @State private var isShowingSheet = false
    private var currentDisplayDate: Date {
        dateRange.indices.contains(currentIndex) ? dateRange[currentIndex] : currentDate
    }
    
    init(initialDate: Date = Date()) {
        let startOfDay = Calendar.current.startOfDay(for: initialDate)
        _currentDate = State(initialValue: startOfDay)
        _selectedDate = State(initialValue: startOfDay)
    }
    
    private var isToday: Bool {
        dateRange.indices.contains(currentIndex) &&
        Calendar.current.isDate(dateRange[currentIndex], inSameDayAs: Date())
    }
    
    private func goToToday() {
        Task {
            await viewModel.savePendingWeights()
            viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex)
            currentDate = Calendar.current.startOfDay(for: Date())
        }
    }
    
    // Only extend backward when swiping into the past
    private func extendDateRangeIfNeeded(for index: Int) {
        guard !dateRange.isEmpty else { return }
        let buffer = 30
        if index <= buffer, let earliest = dateRange.first {
            let newEarliest = Calendar.current.date(byAdding: .day, value: -buffer, to: earliest)!
            viewModel.ensureDateIsInRange(newEarliest,
                                         dateRange: &dateRange,
                                         currentIndex: &currentIndex,
                                         thenSelectIt: false)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                DozeHeaderView(
                    isShowingSheet: $isShowingSheet,
                    currentDate: currentDisplayDate
                )
                
                TabView(selection: $currentIndex) {
                    ForEach(dateRange.indices, id: \.self) { index in
                        WeightEntryPage(date: dateRange[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentIndex) { _, newIndex in
                    currentDate = dateRange[newIndex]
                    extendDateRangeIfNeeded(for: newIndex)
                    
                    // Optional: preload nearby pages
                    Task {
                        let start = max(0, newIndex - 5)
                        let end = min(dateRange.count - 1, newIndex + 3)
                        for i in start...end {
                            await viewModel.loadTracker(forDate: dateRange[i], isSilent: true)
                        }
                    }
                }
            }
            
            if !isToday {
                DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                    .background(Color.white)
            }
        }
        
        .navigationBarBackButtonHidden(true)
        .navigationTitle("weightEntry.heading")
        .toolbarBackground(.nfGreenBrand, for: .navigationBar)
        // Add this line to force the background to stay visible:
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task {
                        await viewModel.savePendingWeights()
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.backward")  // Just the system chevron, no text
                        .font(.system(size: 17, weight: .semibold))  // Matches system style
                }
                .flipsForRightToLeftLayoutDirection(true)  // Auto-flips for RTL languages (e.g., Arabic)
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            DatePickerSheetView(selectedDate: $selectedDate,
                                dateRange: $dateRange,
                                currentIndex: $currentIndex)
                .presentationDetents([.medium])
        }
        .task {
            // This one line replaces all your old init + onAppear logic
            viewModel.ensureDateIsInRange(currentDate,
                                         dateRange: &dateRange,
                                         currentIndex: &currentIndex)
            
            // Preload a few recent days for smooth swiping
            let recent = dateRange.suffix(15) // today + last 14
            for date in recent {
                await viewModel.loadTracker(forDate: date, isSilent: true)
            }
        }
        .onDisappear {
            Task { await viewModel.savePendingWeights() }
        }
        .task {
            // Request HealthKit once (safe to call multiple times)
            try? await HealthManager.shared.requestPermissions()
        }
    }
}
struct WeightEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeightEntryView(initialDate: Date())
                .environmentObject(SqlDailyTrackerViewModel())
        }
    }
}
