//
//  WeightEntryView.swift
//  DailyDozen
//
// 
//

import SwiftUI
//TBDz this page needs localization
struct WeightEntryView: View {
    @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentDate: Date
    @State private var dateRange: [Date] = []
    @State private var currentIndex: Int = 0
    @State private var isShowingSheet: Bool = false
    @State private var selectedDate: Date

    init(initialDate: Date) {
        self._currentDate = State(initialValue: initialDate.startOfDay)
        self._selectedDate = State(initialValue: initialDate.startOfDay)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        self._dateRange = State(initialValue: (-30...0).map { offset in
            calendar.date(byAdding: .day, value: offset, to: today)!
        })
        if let todayIndex = self.dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            self._currentIndex = State(initialValue: todayIndex)
        }
    }

    private var isToday: Bool {
        guard !dateRange.isEmpty, currentIndex >= 0, currentIndex < dateRange.count else {
            return false
        }
        return Calendar.current.isDate(dateRange[currentIndex], inSameDayAs: Date().startOfDay)
    }

    private func goToToday() {
        Task {
            await viewModel.savePendingWeights()
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            currentDate = today
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = todayIndex
            } else {
                dateRange.append(today)
                dateRange.sort(by: { $0 < $1 })
                currentIndex = dateRange.firstIndex(of: today)!
            }
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
                currentDate = dateRange[todayIndex]
            }
        }

        if index <= bufferDays {
            let earliestDate = dateRange.first!
            let newDates = (1...bufferDays).map { offset in
                calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
            }.reversed()
            dateRange.insert(contentsOf: newDates, at: 0)
            currentIndex += bufferDays
            print("Extended dateRange backward: earliest now \(dateRange.first!.datestampSid)")
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
                print("Extended dateRange forward: latest now \(dateRange.last!.datestampSid)")
            }
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = min(currentIndex, todayIndex)
            }
        }
    }

    var body: some View {
      //  NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    DozeHeaderView(isShowingSheet: $isShowingSheet, currentDate: dateRange.isEmpty ? Date() : dateRange[currentIndex])
                    TabView(selection: $currentIndex) {
                        ForEach(dateRange.indices, id: \.self) { index in
                            WeightEntryPage(date: dateRange[index], viewModel: viewModel)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                if !isToday {
                    DozeBackToTodayButtonView(isToday: isToday) {
                        goToToday()
                    }
                    .padding(.bottom, 0)
                    .background(Color.white)
                }
            }
            .navigationTitle("Weight")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        Task { await viewModel.savePendingWeights(); dismiss() }
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
                    .presentationDetents([.medium])
                    .onAppear { print("DatePickerSheetView presented") }
                    .onDisappear { print("DatePickerSheetView dismissed") }
            }
            .onAppear {
                if !dateRange.contains(where: { Calendar.current.isDate($0, inSameDayAs: currentDate) }) {
                    dateRange.append(currentDate)
                    dateRange.sort(by: { $0 < $1 })
                    if let index = dateRange.firstIndex(of: currentDate) {
                        currentIndex = index
                        extendDateRangeIfNeeded(for: index)
                    }
                }
            }
            .onDisappear {
                Task { await viewModel.savePendingWeights() }
            }
            .task {
                do {
                    try await HealthManager.shared.requestPermissions()
                } catch {
                    print("HealthKit permission error: \(error)")
                }
            }
       // } //Nav
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
