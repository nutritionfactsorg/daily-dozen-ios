//
//  WeightEntryView.swift
//  DailyDozen
//
//  Copyright © 2025-2026 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
 
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
            viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex, thenSelectIt: true)
            //currentDate = Calendar.current.startOfDay(for: Date())
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
                    Task {
                        currentDate = dateRange[newIndex]
                        extendDateRangeIfNeeded(for: newIndex)
                    }
                    
                    Task {
                        let start = max(0, newIndex - 5)
                        let end = min(dateRange.count - 1, newIndex + 3)
                        for i in start...end {
                            await viewModel.loadTracker(forDate: dateRange[i], isSilent: true)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isToday {
                    DozeBackToTodayButtonView(isToday: isToday, action: goToToday)
                        .background(Color.white)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        //.padding(.vertical, 20)
                }
                //else {
                //    Color.clear.frame(height: 0)  // Ensures no extra space when hidden
                //}
            }
            .animation(.easeInOut(duration: 0.25), value: isToday)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("weightEntry.heading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.nfGreenBrand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task {
                            await viewModel.savePendingWeights()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .flipsForRightToLeftLayoutDirection(true)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("weightEntry.heading")
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .tracking(-0.4)
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                DatePickerSheetView(selectedDate: $selectedDate,
                                    dateRange: $dateRange,
                                    currentIndex: $currentIndex)
                    .presentationDetents([.medium])
            }
            .onChange(of: selectedDate) { _, newValue in
                viewModel.ensureDateIsInRange(
                    newValue,
                    dateRange: &dateRange,
                    currentIndex: &currentIndex,
                    thenSelectIt: true
                )
            }
            .task {
                viewModel.ensureDateIsInRange(
                    currentDate,
                    dateRange: &dateRange,
                    currentIndex: &currentIndex,
                    thenSelectIt: true
                )
                
                let recent = dateRange.suffix(15)
                for date in recent {
                    await viewModel.loadTracker(forDate: date, isSilent: true)
                }
            }
            .onDisappear {
                Task { await viewModel.savePendingWeights() }
            }
            .task {
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
