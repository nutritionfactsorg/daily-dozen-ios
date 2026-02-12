//
//  WeightChartView.swift
//  DailyDozen
//
// swiftlint:disable type_body_length

import SwiftUI
import Charts

//TBDz Needs Localization

// Enum for chart time periods
enum ChartPeriod: String, CaseIterable, Identifiable {
//    case day = "Day"
//    case month = "Month"
//    case year = "Year"
    case day, month, year
    
    var id: String { rawValue }
   
    var localizedTitle: LocalizedStringKey {
            Self.titles[self] ?? LocalizedStringKey(rawValue)
        }
        
    nonisolated(unsafe) private static let titles: [ChartPeriod: LocalizedStringKey] = [
            .day: "history_scale_choice_day",
            .month: "history_scale_choice_month",
            .year: "history_scale_choice_year"
        ]
}

// Data point for chart
struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let weightType: DataWeightType // AM or PM
}

struct WeightChartView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var viewModel = SqlDailyTrackerViewModel.shared
    @State private var selectedPeriod: ChartPeriod = .day
    @State private var selectedDate: Date = Date()
    @State private var monthsWithData: [Date] = []
    @State private var isLoadingMonths = true
    private var selectedMonth: Date { selectedDate.startOfMonth }
    private var selectedYear: Int { Calendar.current.component(.year, from: selectedDate) }
    private var yearsWithData: [Int] {
        Array(Set(monthsWithData.map { Calendar.current.component(.year, from: $0) })).sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(ChartPeriod.allCases) { period in
                        Text(period.localizedTitle).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if isLoadingMonths {
                    ProgressView("loading_heading")
                        .progressViewStyle(CircularProgressViewStyle(tint: .nfGreenBrand))
                        .scaleEffect(1.5)
                        .padding()
                } else if monthsWithData.isEmpty {
                    Text("historyRecordWeight_NoWeightYet")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    // MARK: - Navigation Header
                    if selectedPeriod != .year {
                        // Common calculations — available to both normal and accessibility layouts
                        let calendar = Calendar.current
                        
                        if selectedPeriod == .day {
                            let sortedMonths = monthsWithData.sorted(by: >)
                            let currentMonthStart = selectedDate.startOfMonth
                            let currentIndex = sortedMonths.firstIndex(of: currentMonthStart) ?? 0
                            
                            if dynamicTypeSize.isAccessibilitySize {
                                // Vertical layout for Day mode (Accessibility)
                                VStack(spacing: 8) {
                                    Text(selectedDate, format: .dateTime.year().month(.wide))
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .dynamicTypeSize(.large ... .xxLarge)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)                 // Unlimited lines if extremely long locale
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 24) {
                                        Button { selectedDate = sortedMonths.last!.startOfMonth } label: {
                                            Image(systemName: "chevron.left.2")
                                                .font(.headline)         // Smaller in Accessibility
                                                .foregroundStyle(currentIndex < sortedMonths.count - 1 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                        
                                        Button {
                                            if currentIndex < sortedMonths.count - 1 {
                                                selectedDate = sortedMonths[currentIndex + 1].startOfMonth
                                            }
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.headline)
                                                .foregroundStyle(currentIndex < sortedMonths.count - 1 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            if currentIndex > 0 {
                                                selectedDate = sortedMonths[currentIndex - 1].startOfMonth
                                            }
                                        } label: {
                                            Image(systemName: "chevron.right")
                                                .font(.headline)
                                                .foregroundStyle(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                        
                                        Button { selectedDate = sortedMonths.first!.startOfMonth } label: {
                                            Image(systemName: "chevron.right.2")
                                                .font(.headline)
                                                .foregroundStyle(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                
                            } else {
                                HStack {
                                    Button { selectedDate = sortedMonths.last!.startOfMonth } label: {
                                        Image(systemName: "chevron.left.2")
                                            .foregroundColor(currentIndex < sortedMonths.count - 1 ? Color("nfGreenBrand") : .gray)
                                    }
                                    
                                    Button {
                                        if currentIndex < sortedMonths.count - 1 {
                                            selectedDate = sortedMonths[currentIndex + 1].startOfMonth
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(currentIndex < sortedMonths.count - 1 ? Color("nfGreenBrand") : .gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(selectedDate, format: .dateTime.year().month(.wide))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Button {
                                        if currentIndex > 0 {
                                            selectedDate = sortedMonths[currentIndex - 1].startOfMonth
                                        }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                    }
                                    
                                    Button { selectedDate = sortedMonths.first!.startOfMonth } label: {
                                        Image(systemName: "chevron.right.2")
                                            .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                        } else { // .month
                            let years = yearsWithData.sorted(by: >)
                            let currentIndex = years.firstIndex(of: selectedYear) ?? 0
                            
                            if dynamicTypeSize.isAccessibilitySize {
                                // Vertical layout for Month mode (Accessibility)
                                VStack(spacing: 8) {
                                    Text(selectedYear, format: .number.grouping(.never))
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .dynamicTypeSize(.large ... .xxLarge)
                                        .monospacedDigit()
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 24) {
                                        Button {
                                            let oldest = years.last!
                                            selectedDate = calendar.date(from: DateComponents(year: oldest, month: 1, day: 1))!
                                        } label: {
                                            Image(systemName: "chevron.left.2")
                                                .font(.headline)
                                                .foregroundStyle(currentIndex < years.count - 1 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                        
                                        Button {
                                            if currentIndex < years.count - 1 {
                                                let prev = years[currentIndex + 1]
                                                selectedDate = calendar.date(from: DateComponents(year: prev, month: 1, day: 1))!
                                            }
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.headline)
                                                .foregroundStyle(currentIndex < years.count - 1 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            if currentIndex > 0 {
                                                let next = years[currentIndex - 1]
                                                selectedDate = calendar.date(from: DateComponents(year: next, month: 1, day: 1))!
                                            }
                                        } label: {
                                            Image(systemName: "chevron.right")
                                                .font(.headline)
                                                .foregroundStyle(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                        
                                        Button {
                                            let newest = years.first!
                                            selectedDate = calendar.date(from: DateComponents(year: newest, month: 1, day: 1))!
                                        } label: {
                                            Image(systemName: "chevron.right.2")
                                                .font(.headline) 
                                                .foregroundStyle(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                                .dynamicTypeSize(.xSmall ... .accessibility2)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                
                            } else {
                                HStack {
                                    Button {
                                        let oldest = years.last!
                                        selectedDate = calendar.date(from: DateComponents(year: oldest, month: 1, day: 1))!
                                    } label: {
                                        Image(systemName: "chevron.left.2")
                                            .foregroundColor(currentIndex < years.count - 1 ? Color("nfGreenBrand") : .gray)
                                    }
                                    
                                    Button {
                                        if currentIndex < years.count - 1 {
                                            let prev = years[currentIndex + 1]
                                            selectedDate = calendar.date(from: DateComponents(year: prev, month: 1, day: 1))!
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(currentIndex < years.count - 1 ? Color("nfGreenBrand") : .gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(selectedYear, format: .number.grouping(.never))
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .monospacedDigit()
                                    
                                    Spacer()
                                    
                                    Button {
                                        if currentIndex > 0 {
                                            let next = years[currentIndex - 1]
                                            selectedDate = calendar.date(from: DateComponents(year: next, month: 1, day: 1))!
                                        }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                    }
                                    
                                    Button {
                                        let newest = years.first!
                                        selectedDate = calendar.date(from: DateComponents(year: newest, month: 1, day: 1))!
                                    } label: {
                                        Image(systemName: "chevron.right.2")
                                            .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        EmptyView()  // Year mode — no navigation
                    }
                    // MARK: - Chart
                    Group {
                        switch selectedPeriod {
                        case .day:    DayChartView(selectedMonth: selectedMonth.startOfMonth)
                        case .month:  MonthChartView(selectedYear: selectedYear)
                        case .year:   YearChartView()
                        }
                    }
                   .frame(minHeight: 310)
                    
                   Spacer()
                    
                   .padding(20)
                    
                    //NavigationLink(destination: WeightEntryView(initialDate: selectedDate)) {
                    NavigationLink(destination: WeightEntryView(initialDate: Date())) {
                        Text("weight_history_edit_data")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.nfGreenBrand)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 30)  // Extra space for tab bar
                    }
                }
                // .padding(.top, 10) •MAYBE•
            }
        } //Scroll
        .whiteInlineGreenTitle("historyRecordWeight.heading")
        .task {
            let viewModel = SqlDailyTrackerViewModel.shared
            await viewModel.preloadAllDataForYearChart()
            
            monthsWithData = viewModel.availableWeightMonths
            isLoadingMonths = false
            
            if let newest = monthsWithData.first {
                selectedDate = newest
            }
        }
//        .task {
//            monthsWithData = await viewModel.availableWeightMonths
//            isLoadingMonths = false
//            if let newest = monthsWithData.first {
//                selectedDate = newest
//            }
//        }
//        .onChange(of: selectedDate) {
//            Task {
//                if selectedPeriod != .year {
//                    await viewModel.loadTrackersForMonth(selectedDate, silent: true)
//                }
//            }
//        }
    }
    
    private func monthYearText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = .current
        return formatter.string(from: date)
    }
}

// Helper extension
extension Array where Element == Date {
    func closest(to date: Date) -> Date? {
        self.min(by: { abs($0.timeIntervalSince(date)) < abs($1.timeIntervalSince(date)) })
    }
}
