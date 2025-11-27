//
//  WeightEntryView.swift
//  DailyDozen
//
// 
//

struct PendingWeight {
    var amWeight: String
    var pmWeight: String
    var amTime: Date
    var pmTime: Date
}

import SwiftUI
//TBDz this page needs localization
struct WeightEntryView: View {
    @StateObject private var viewModel: WeightEntryViewModel
    @State private var currentDate: Date
    @Environment(\.dismiss) private var dismiss
    //@State private var pendingWeights: [String: PendingWeight] = [:]
    @State private var dateRange: [Date] = [] // Dynamic date range
    @State private var currentIndex: Int = 0 // Track current index
    @State private var isShowingSheet = false
    @State private var selectedDate = Date()
    
    init(initialDate: Date, viewModel: WeightEntryViewModel = WeightEntryViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._currentDate = State(initialValue: initialDate.startOfDay)
        // Initialize dateRange with 30 days before today up to today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        self._dateRange = State(initialValue: (-30...0).map { offset in
            calendar.date(byAdding: .day, value: offset, to: today)!
        })
        // Set initial index to today
        if let todayIndex = self.dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            self._currentIndex = State(initialValue: todayIndex)
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
   
    private func goToToday() async {
        print("Today button tapped")
        await viewModel.savePendingWeights()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // currentDate = Date().startOfDay
        currentDate = today
        if let todayIndex = dateRange.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: Date().startOfDay) }) {
            currentIndex = todayIndex
        } else {
            dateRange.append(today)
            dateRange.sort(by: { $0 < $1 })
            currentIndex = dateRange.firstIndex(of: today)!
        }
    }
    
    private func extendDateRangeIfNeeded(for index: Int) {
        let calendar = Calendar.current
        let bufferDays = 30
        let today = calendar.startOfDay(for: Date())
        
        // If dateRange is empty, initialize it
        if dateRange.isEmpty {
            dateRange = (-bufferDays...0).map { offset in
                calendar.date(byAdding: .day, value: offset, to: today)!
            }
            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                currentIndex = todayIndex
                currentDate = dateRange[todayIndex]
            }
        }
        
        // Extend backward if approaching the start
        if index <= bufferDays {
            let earliestDate = dateRange.first!
            let newDates = (1...bufferDays).map { offset in
                calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
            }.reversed()
            dateRange.insert(contentsOf: newDates, at: 0)
            currentIndex += bufferDays
            print("Extended dateRange backward: earliest now \(dateRange.first!.datestampSid)")
        }
        
        // Extend forward only up to today
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
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // ZStack(alignment: .bottom) { // Use ZStack to layer content
                    //   VStack {
                    DozeHeaderView(isShowingSheet: $isShowingSheet,
                                   currentDate: dateRange.isEmpty ? Date() : dateRange[currentIndex]
                    )
                    .zIndex(1)
                    
                    //DozeHeaderView(isShowingSheet: $isShowingSheet, currentDate: $currentDate)
                    // Weight input fields (from your previous code)
                    
                    TabView(selection: $currentDate) {
                        ForEach(dateRange, id: \.self) { date in
                            WeightEntryPage(date: date, viewModel: viewModel)
                                .tag(date)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onChange(of: currentDate) { _, newDate in
                        Task { @MainActor  in
                            print("Date changed to: \(newDate.datestampSid)")
                            if let index = dateRange.firstIndex(of: newDate) {
                                extendDateRangeIfNeeded(for: index)
                                currentIndex = index
                            }
                            await viewModel.savePendingWeights()
                            if newDate > Date().startOfDay {
                                currentDate = Date().startOfDay
                                if let todayIndex = dateRange.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: Date().startOfDay) }) {
                                    currentIndex = todayIndex
                                }
                            }
                        }
                    }
                }
                if !isToday {
                    DozeBackToTodayButtonView(isToday: isToday) {
                        Task { await goToToday() }
                    }
                     .padding(.bottom, 0) // 🟢 Changed: Added padding for spacing
                    .background(Color.white)  //.systemBackground if want darkmode
                    // .ignoresSafeArea(edges: .bottom)
                }
            } //ZStack
            .navigationTitle("Weight")
            .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        Task { // Wrap async call in Task
                            await viewModel.savePendingWeights()
                            dismiss() }
                    }
                }
            } //toolbar
            .sheet(isPresented: $isShowingSheet) {
                DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
                    .presentationDetents([.medium])
                    .onAppear {
                        print("DatePickerSheetView presented")
                    }
                    .onDisappear {
                        print("DatePickerSheetView dismissed")
                    }
            } //sheet
            .onAppear {
                // Ensure currentDate is in dateRange
                if !dateRange.contains(where: { Calendar.current.isDate($0, inSameDayAs: currentDate) }) {
                    dateRange.append(currentDate)
                    dateRange.sort(by: { $0 > $1 }) // Keep descending order
                    if let index = dateRange.firstIndex(of: currentDate) {
                        currentIndex = index
                        extendDateRangeIfNeeded(for: index)
                    }
                }
                //print("WeightEntryView appeared with dateRange: \(dateRange.map { $0.datestampSid })")
            }
            .onDisappear {
                Task { await viewModel.savePendingWeights() }
            }
        }
        
        .task {
            do {
                try await HealthManager.shared.requestPermissions()
            } catch {
                print("HealthKit permission error: \(error)")
                // Show alert to user
            }
        } //Task
        
    }
}

// Preview
struct WeightEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeightEntryView(initialDate: Date())
        }
    }
}
