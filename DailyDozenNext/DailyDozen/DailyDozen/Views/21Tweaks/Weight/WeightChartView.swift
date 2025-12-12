//
//  WeightChartView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable type_body_length

import SwiftUI
import Charts

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
  //  @EnvironmentObject private var trackerViewModel: SqlDailyTrackerViewModel
    private let trackerViewModel = SqlDailyTrackerViewModel.shared
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
    
    private func gregorianYear(from displayYear: Int) -> Int {
        let date = displayCalendar.date(from: DateComponents(calendar: displayCalendar, year: displayYear, month: 1, day: 1)) ?? Date()
        return gregorianCalendar.component(.year, from: date)
    }
    
    // Convert Gregorian year (e.g., 2025) to display calendar year (e.g., Persian 1404)
    private func displayYear(from gregorianYear: Int) -> Int {
        let date = gregorianCalendar.date(from: DateComponents(calendar: gregorianCalendar, year: gregorianYear, month: 1, day: 1)) ?? Date()
        return displayCalendar.component(.year, from: date)
    }
    
    private var monthsInSelectedYear: [Date] {
        let gregorianSelectedYear = gregorianYear(from: selectedYear)
        return monthsWithData.filter { gregorianCalendar.component(.year, from: $0) == gregorianSelectedYear }
    }
    
    private func loadMonthsAndYears() async {
        guard !isLoading else { return }
        isLoading = true
        print("🟢 •Load• Fetching trackers")
        let fetchedTrackers = await trackerViewModel.fetchAllTrackers()
        await MainActor.run {
            //trackerViewModel.trackers = fetchedTrackers
            monthsWithData = Array(Set(fetchedTrackers.compactMap {
                gregorianCalendar.date(from: gregorianCalendar.dateComponents([.year, .month], from: $0.date))
            }))
//            monthsWithData = Array(Set(fetchedTrackers.map { gregorianCalendar.date(from: gregorianCalendar.dateComponents([.year, .month], from: $0.date))! }))
                .sorted()
            yearsWithData = Array(Set(fetchedTrackers.map { gregorianCalendar.component(.year, from: $0.date) }))
                .sorted()
            if !monthsWithData.contains(where: { gregorianCalendar.isDate($0, equalTo: selectedMonth, toGranularity: .month) }), let latest = monthsWithData.last {
                selectedMonth = latest
                selectedYear = displayYear(from: gregorianCalendar.component(.year, from: latest))
            }
            isLoading = false
            print("🟢 •Load• Fetched \(fetchedTrackers.count) trackers, \(monthsWithData.count) months, \(yearsWithData.count) years")
        }
    }
      
    private func monthYearText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
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
                        Button(action: {
                            print("🟢 •Nav• LEFT Double CLICKED: monthsWithData=\(monthsWithData.map { $0.datestampSid })")
                            if let earliest = monthsWithData.first {
                                selectedMonth = earliest
                                selectedYear = displayYear(from: gregorianCalendar.component(.year, from: earliest))
                            }
                        }, label: {
                            Image(systemName: "chevron.left.2")
                                .foregroundColor(monthsWithData.isEmpty || selectedMonth == monthsWithData.first ? .gray : .brandGreen)
                        })
                        .disabled(monthsWithData.isEmpty || selectedMonth == monthsWithData.first)
                        
                        Button(action: {
                            if let currentIndex = monthsInSelectedYear.firstIndex(where: { gregorianCalendar.isDate($0, equalTo: selectedMonth, toGranularity: .month) }),
                               currentIndex > 0 {
                                selectedMonth = monthsInSelectedYear[currentIndex - 1]
                            } else if let previousYearMonth = monthsWithData.filter({ gregorianCalendar.component(.year, from: $0) < gregorianYear(from: selectedYear) }).max() {
                                selectedYear = displayYear(from: gregorianCalendar.component(.year, from: previousYearMonth))
                                selectedMonth = monthsInSelectedYear.last ?? previousYearMonth
                            }
                            print("🟢 •Nav• Single LEFT clicked: selectedMonth=\(selectedMonth.datestampSid), selectedYear=\(selectedYear)")
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(monthsWithData.isEmpty || selectedMonth == monthsWithData.first ? .gray : .brandGreen)
                        })
                        .disabled(monthsWithData.isEmpty || selectedMonth == monthsWithData.first)
                        
                        Text(monthYearText(for: selectedMonth))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            if let currentIndex = monthsInSelectedYear.firstIndex(where: { gregorianCalendar.isDate($0, equalTo: selectedMonth, toGranularity: .month) }),
                               currentIndex < monthsInSelectedYear.count - 1 {
                                selectedMonth = monthsInSelectedYear[currentIndex + 1]
                            } else if let nextYearMonth = monthsWithData.filter({ gregorianCalendar.component(.year, from: $0) > gregorianYear(from: selectedYear) }).min() {
                                selectedYear = displayYear(from: gregorianCalendar.component(.year, from: nextYearMonth))
                                selectedMonth = monthsInSelectedYear.first ?? nextYearMonth
                            }
                            print("🟢 •Nav• Single RIGHT clicked: selectedMonth=\(selectedMonth.datestampSid), selectedYear=\(selectedYear)")
                        }, label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(monthsWithData.isEmpty || selectedMonth == monthsWithData.last ? .gray : .brandGreen)
                        })
                        .disabled(monthsWithData.isEmpty || selectedMonth == monthsWithData.last)
                        
                        Button(action: {
                            if let latest = monthsWithData.last {
                                selectedMonth = latest
                                selectedYear = displayYear(from: gregorianCalendar.component(.year, from: latest))
                            }
                            print("🟢 •Nav• RIGHT Double clicked: selectedMonth=\(selectedMonth.datestampSid), selectedYear=\(selectedYear)")
                        }, label: {
                            Image(systemName: "chevron.right.2")
                                .foregroundColor(monthsWithData.isEmpty || selectedMonth == monthsWithData.last ? .gray : .brandGreen)
                        })
                        .disabled(monthsWithData.isEmpty || selectedMonth == monthsWithData.last)
                    }
                    .padding(.horizontal)
                }
                
                if selectedPeriod == .month {
                    HStack {
                        Button(action: {
                            if let earliest = yearsWithData.first {
                                selectedYear = displayYear(from: earliest)
                            }
                            print("🟢 •Nav• LEFT Double clicked: selectedYear=\(selectedYear)")
                        }, label: {
                            Image(systemName: "chevron.left.2")
                                .foregroundColor(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.first ? .gray : .brandGreen)
                        })
                        .disabled(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.first)
                        
                        Button(action: {
                            if let currentIndex = yearsWithData.firstIndex(of: gregorianYear(from: selectedYear)),
                               currentIndex > 0 {
                                selectedYear = displayYear(from: yearsWithData[currentIndex - 1])
                            }
                            print("🟢 •Nav• Single LEFT clicked: selectedYear=\(selectedYear)")
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.first ? .gray : .brandGreen)
                        })
                        .disabled(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.first)
                        
                        Text(numberFormatter.string(from: NSNumber(value: selectedYear)) ?? "\(selectedYear)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            if let currentIndex = yearsWithData.firstIndex(of: gregorianYear(from: selectedYear)),
                               currentIndex < yearsWithData.count - 1 {
                                selectedYear = displayYear(from: yearsWithData[currentIndex + 1])
                            }
                            print("🟢 •Nav• Single RIGHT clicked: selectedYear=\(selectedYear)")
                        }, label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.last ? .gray : .brandGreen)
                        })
                        .disabled(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.last)
                        
                        Button(action: {
                            if let latest = yearsWithData.last {
                                selectedYear = displayYear(from: latest)
                            }
                            print("🟢 •Nav• RIGHT Double clicked: selectedYear=\(selectedYear)")
                        }, label: {
                            Image(systemName: "chevron.right.2")
                                .foregroundColor(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.last ? .gray : .brandGreen)
                        })
                        .disabled(yearsWithData.isEmpty || gregorianYear(from: selectedYear) == yearsWithData.last)
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
                
                .onTapGesture {
                    print("🟢 •Nav• Edit Data tapped for \(selectedPeriod == .day ? selectedMonth.startOfDay.datestampSid : Date().startOfDay.datestampSid)")
                }
            }
        } //VStack
        
        .onAppear {
            Task {
                // isLoading = true
                await loadMonthsAndYears()
                //TBDz if I need the code below Still need to heavy test the >> nav
                //                if !monthsWithData.contains(selectedMonth), let latest = monthsWithData.last {
                //                    selectedMonth = latest
                //                    selectedYear = latest.year
                //                }
                isLoading = false
                refreshID = UUID()
                print("🟢 •Chart• WeightChartView appeared, refreshing chart for month: \(selectedMonth.datestampSid)")
            }
        }
        
        .onChange(of: selectedPeriod) { _, newPeriod in
            if newPeriod == .day || newPeriod == .month {
                if let latestMonth = monthsWithData.last {
                    selectedMonth = latestMonth
                    selectedYear = displayYear(from: gregorianCalendar.component(.year, from: latestMonth))
                } else {
                    selectedMonth = Date().startOfMonth
                    selectedYear = displayCalendar.component(.year, from: Date())
                }
            }
            refreshID = UUID()
            print("🟢 •Chart• selectedPeriod changed to \(newPeriod), selectedMonth: \(selectedMonth.datestampSid), selectedYear: \(selectedYear)")
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
            Task {
                await loadMonthsAndYears()
                if selectedPeriod == .day || selectedPeriod == .month {
                    if let latestMonth = monthsWithData.last {
                        selectedMonth = latestMonth
                        selectedYear = displayYear(from: gregorianCalendar.component(.year, from: latestMonth))
                    }
                }
                refreshID = UUID()
                print("🟢 •Chart• DB updated via notification, refreshing chart")
            }
        } //onReceive
        //    } //Nav
    } //Body
}
