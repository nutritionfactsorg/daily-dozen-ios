//
//  WeightChartView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import Charts

//TBDz 20250915 Temp ForceUnwrap

// Extension to compute day of year
extension DateComponents {
    var dayOfYear: Int? {
        guard let year = year, let month = month, let day = day,
              let date = Calendar(identifier: .gregorian).date(from: self) else {
            return nil
        }
        var yearComponents = DateComponents()
        yearComponents.year = year
        guard let yearStart = Calendar(identifier: .gregorian).date(from: yearComponents) else {
            return nil
        }
        return Calendar(identifier: .gregorian).dateComponents([.day], from: yearStart, to: date).day! + 1
    }
}

// Enum for chart time periods
enum ChartPeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case month = "Month"
    case year = "Year"
    
    var id: String { rawValue }
}

// Data point for chart
struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let type: DataWeightType // AM or PM
}

struct WeightChartView: View {
    @State private var selectedPeriod: ChartPeriod = .day
    @State private var selectedMonth: Date = Date().startOfMonth
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var monthsWithData: [Date] = []
    @State private var yearsWithData: [Int] = []
    @State private var refreshID = UUID()
    @State private var isLoading: Bool = false
    @EnvironmentObject private var trackerViewModel: SqlDailyTrackerViewModel
    @StateObject private var servingsProcessor: ServingsDataProcessor
    @State private var navigationPath = NavigationPath()
    @State private var isEditWeightViewActive = false
    
    private var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar
    }
    
    private var displayCalendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        return calendar
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        return formatter
    }
    
    private var monthsInSelectedYear: [Date] {
        //monthsWithData.filter { $0.year == selectedYear }
       // monthsWithData
       // monthsWithData.filter { $0 <= Date().startOfMonth }
       // let gregYear = DateUtilities.gregorianCalendar.component(.year, from: selectedMonth)
       // return monthsWithData.filter { DateUtilities.gregorianCalendar.component(.year, from: $0) == gregYear }
        
        monthsWithData.filter { $0.year == selectedYear }
       
    }
    
    private func loadMonthsAndYears() async {
        print("🟢🟢🟢🟢I got to here first")
            guard !isLoading else { return }
            isLoading = true
        print("🟢🟢🟢🟢🟢I got to here")
            let trackers = await trackerViewModel.fetchAllTrackers()
            await servingsProcessor.updateTrackers()
            let dates = trackers.map { $0.date.datestampSid }
            await MainActor.run {
                monthsWithData = Array(Set(dates.compactMap { Date(datestampSid: $0)?.startOfMonth }))
                    .sorted()
                print("🟢 •Load• monthsWithData.count = \(monthsWithData.count), years=\(yearsWithData), contents=\(monthsWithData.map { $0.datestampSid })")
                yearsWithData = Array(Set(dates.compactMap { Date(datestampSid: $0)?.year }))
                    .sorted()
                if !monthsWithData.contains(selectedMonth), let latest = monthsWithData.last {
                    selectedMonth = latest
                    selectedYear = latest.year
                }
                isLoading = false
                print("🟢 •Load• Fetched \(trackers.count) trackers, \(dates.count) distinct dates: \(dates), \(monthsWithData.count) months, \(yearsWithData.count) years, selectedMonth: \(selectedMonth.datestampSid)")
            }
        }
    
    private func monthYearText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    init() {
            _servingsProcessor = StateObject(wrappedValue: ServingsDataProcessor())
        }
    
    var body: some View {
      // NavigationStack(path: $navigationPath) {
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 340)
                } else {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(ChartPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    if selectedPeriod == .day {
                        HStack {
                            //let canJumpYear = monthsInSelectedYear.count > 1
                            let canDoubleLeft = !monthsInSelectedYear.isEmpty &&
                                                    selectedMonth != monthsInSelectedYear.first  // Assumes .first is earliest
                            
                            Button(action: {
                                print("🟢🟢🟢 LEFT Double CLICKED: monthsInSelectedYear=\(monthsInSelectedYear.map { $0.datestampSid })")
                               
                                if let earliest = monthsInSelectedYear.first {
                                    selectedMonth = earliest
                                }
                                print("🟢🟢🟢 selectedMonth: \(selectedMonth)")
                            }, label: {
                                Image(systemName: "chevron.left.2")
                                   // .foregroundColor(monthsInSelectedYear.isEmpty ? .gray : .brandGreen)
                                   // .foregroundColor(monthsInSelectedYear.count <= 1 ? .gray : .brandGreen)
                                    .foregroundColor(canDoubleLeft ? .brandGreen : .gray)
                            })
                           // .disabled(monthsInSelectedYear.count <= 1)  // 🟢 CHANGE: was .isEmpty
                           // .disabled(monthsInSelectedYear.isEmpty)
                            .disabled(!canDoubleLeft)
                            let canSingleLeft = !monthsWithData.isEmpty &&
                                                    selectedMonth != monthsWithData.first  // Assumes .first is earliest ever
                            Button(action: {
                                if let currentIndex = monthsInSelectedYear.firstIndex(of: selectedMonth),
                                   currentIndex > 0 {
                                    selectedMonth = monthsInSelectedYear[currentIndex - 1]
                                } else if let previousYearMonth = monthsWithData
                                    .filter({ $0.year < selectedYear })
                                    .max() {
                                    selectedYear = previousYearMonth.year
                                    selectedMonth = monthsInSelectedYear.last ?? previousYearMonth
                                }
                            }, label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(canSingleLeft ? .brandGreen : .gray)
                            })
                            .disabled(!canSingleLeft)
                            
                            Text(monthYearText(for: selectedMonth))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                if let currentIndex = monthsInSelectedYear.firstIndex(of: selectedMonth),
                                   currentIndex < monthsInSelectedYear.count - 1 {
                                    selectedMonth = monthsInSelectedYear[currentIndex + 1]
                                } else if let nextYear = monthsWithData
                                    .filter({ $0.year > selectedYear })
                                    .min() {
                                    selectedYear = nextYear.year
                                    selectedMonth = monthsInSelectedYear.first ?? nextYear
                                }
                            }, label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(selectedMonth >= Date().startOfMonth || monthsWithData.isEmpty ? .gray : .brandGreen)
                            })
                            .disabled(selectedMonth >= Date().startOfMonth || monthsWithData.isEmpty)
                            
                            Button(action: {
                                if let latest = monthsInSelectedYear.last {
                                    selectedMonth = latest
                                }
                            }, label: {
                                Image(systemName: "chevron.right.2")
                                    .foregroundColor(monthsInSelectedYear.isEmpty || selectedMonth >= Date().startOfMonth ? .gray : .brandGreen)
                            })
                            .disabled(monthsInSelectedYear.count <= 1)  // 🟢 CHANGE: was .isEmpty || selectedMonth >= Date().startOfMonth)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Navigation for Month view (year-based)
                    if selectedPeriod == .month {
                        HStack {
                            Button(action: {
                                if let earliest = yearsWithData.first {
                                    selectedYear = earliest
                                }
                            }, label: {
                                Image(systemName: "chevron.left.2")
                                    .foregroundColor(yearsWithData.isEmpty ? .gray : .brandGreen)
                            })
                            // .disabled(yearsWithData.isEmpty)
                            .disabled(yearsWithData.count <= 1)
                            
                            Button(action: {
                                if let currentIndex = yearsWithData.firstIndex(of: selectedYear),
                                   currentIndex > 0 {
                                    selectedYear = yearsWithData[currentIndex - 1]
                                }
                            }, label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(yearsWithData.isEmpty ? .gray : .brandGreen)
                            })
                            .disabled(yearsWithData.isEmpty)
                            
                            Text(numberFormatter.string(from: NSNumber(value: selectedYear)) ?? "\(selectedYear)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                if let currentIndex = yearsWithData.firstIndex(of: selectedYear),
                                   currentIndex < yearsWithData.count - 1 {
                                    selectedYear = yearsWithData[currentIndex + 1]
                                }
                            }, label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(selectedYear >= Date().year || yearsWithData.isEmpty ? .gray : .brandGreen)
                            })
                            .disabled(selectedYear >= Date().year || yearsWithData.isEmpty)
                            
                            Button(action: {
                                if let latest = yearsWithData.last {
                                    selectedYear = latest
                                }
                            }, label: {
                                Image(systemName: "chevron.right.2")
                                    .foregroundColor(yearsWithData.isEmpty || selectedYear >= Date().year ? .gray : .brandGreen)
                            })
                            .disabled(yearsWithData.count <= 1 || selectedYear >= Date().year)
                        }
                        .padding(.horizontal)
                    }
                    
                    switch selectedPeriod {
                    case .day:
                        DayChartView(selectedMonth: selectedMonth)
                            .frame(maxWidth: .infinity, minHeight: 340)
                            .id(refreshID)
                    case .month:
                        MonthChartView(selectedYear: selectedYear)
                            .frame(maxWidth: .infinity, minHeight: 340)
                            .id(refreshID)
                    case .year:
                        YearChartView()
                            .frame(maxWidth: .infinity, minHeight: 340)
                            .id(refreshID)
                    }
                    
                Spacer()
                NavigationLink(destination: WeightEntryView(initialDate: selectedPeriod == .day ? selectedMonth.startOfDay : Date().startOfDay)) {
                    //NavigationLink(value: selectedPeriod == .day ? selectedMonth.startOfDay : Date().startOfDay) {
                    Text("Edit Data")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                    
//                                        .navigationDestination(isPresented: $isEditWeightViewActive) {
//                                            WeightEntryView(initialDate: selectedPeriod == .day ? selectedMonth.startOfDay : Date().startOfDay)
//                                        }
                                    .onTapGesture {
                                        print("🟢 •Nav• Edit Data tapped for \(selectedPeriod == .day ? selectedMonth.startOfDay.datestampSid : Date().startOfDay.datestampSid)")
                                    }
                }
            } //VStack
      //  }
//            .navigationDestination(for: Date.self) { date in  // ← ADD THIS LINE
//                   // WeightEntryView(initialDate: date)
//                WeightEntryView(initialDate: selectedPeriod == .day ? selectedMonth.startOfDay : Date().startOfDay)
//                }
//            .navigationDestination(isPresented: $isEditWeightViewActive) {
//                                                     WeightEntryView(initialDate: selectedPeriod == .day ? selectedMonth.startOfDay : Date().startOfDay)
//                                                  }
            .onAppear {
                Task {
                   // isLoading = true
                    await loadMonthsAndYears()
                    
                    if !monthsWithData.contains(selectedMonth), let latest = monthsWithData.last {
                        selectedMonth = latest
                        selectedYear = latest.year
                    }
                    isLoading = false
                    refreshID = UUID()
                    print("🟢 •Chart• WeightChartView appeared, refreshing chart for month: \(selectedMonth.datestampSid)")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
                Task {
                   // isLoading = true
                    await loadMonthsAndYears()
                    refreshID = UUID()
                    print("🟢 •Chart• DB updated via notification, refreshing chart")
                }
            } //onReceive
  //    } //Nav
    } //Body
}
