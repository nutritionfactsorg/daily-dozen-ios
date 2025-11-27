//
//  WeightChartView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import Charts

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
    @State private var refreshID = UUID()
    
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
    
    private var monthsWithData: [Date] {
        let validTrackers = mockDB.filter { $0.weightAM.dataweight_kg > 0 || $0.weightPM.dataweight_kg > 0 }
        let months = Set(validTrackers.map { $0.date.startOfMonth })
        return months.sorted()
    }
    
    private var yearsWithData: [Int] {
        let validTrackers = mockDB.filter { $0.weightAM.dataweight_kg > 0 || $0.weightPM.dataweight_kg > 0 }
        let years = Set(validTrackers.map { $0.date.year })
        return years.sorted()
    }
    
    private var monthsInSelectedYear: [Date] {
        monthsWithData.filter { $0.year == selectedYear }
    }
    
    var body: some View {
        VStack {
            // Period toggle
            Picker("Period", selection: $selectedPeriod) {
                ForEach(ChartPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .frame(maxWidth: .infinity)
            
            // Navigation for Day view (month-based)
            if selectedPeriod == .day {
                HStack {
                    Button(action: {
                        if let earliest = monthsInSelectedYear.first {
                            selectedMonth = earliest
                        }
                    }, label: {
                        Image(systemName: "chevron.left.2")
                            .foregroundColor(monthsInSelectedYear.isEmpty ? .gray : .brandGreen)
                    })
                    .disabled(monthsInSelectedYear.isEmpty)
                    
                    Button(action: {
                        if let currentIndex = monthsInSelectedYear.firstIndex(of: selectedMonth),
                           currentIndex > 0 {
                            selectedMonth = monthsInSelectedYear[currentIndex - 1]
                        } else if let previousYear = monthsWithData
                            .filter({ $0.year < selectedYear })
                            .max() {
                            selectedYear = previousYear.year
                            selectedMonth = monthsInSelectedYear.last ?? previousYear
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(monthsWithData.isEmpty ? .gray : .brandGreen)
                    })
                    .disabled(monthsWithData.isEmpty)
                    
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
                    .disabled(monthsInSelectedYear.isEmpty || selectedMonth >= Date().startOfMonth)
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
                    .disabled(yearsWithData.isEmpty)
                    
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
                    .disabled(yearsWithData.isEmpty || selectedYear >= Date().year)
                }
                .padding(.horizontal)
            }
            
            // Chart
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
            
            NavigationLink(value: selectedPeriod == .day ? selectedMonth.startOfDay : Date().startOfDay) {
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
        .navigationTitle("Weight Charts")
        .onAppear {
            if !monthsWithData.contains(selectedMonth), let latest = monthsWithData.last {
                selectedMonth = latest
                selectedYear = latest.year
            }
            print("🟢 •Chart• WeightChartView appeared, refreshing chart for month: \(selectedMonth.datestampSid)")
            refreshID = UUID()
        }
        .onReceive(WeightEntryViewModel.mockDBTrigger) { _ in
            print("🟢 •Chart• mockDB updated via notification, refreshing chart")
            refreshID = UUID()
        }
    }
    
    private func monthYearText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    WeightChartView()
}
