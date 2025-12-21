//
//  WeightChartView.swift
//  DailyDozen
//
//// swiftlint:disable type_body_length

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
    let type: DataWeightType // AM or PM
}

struct WeightChartView: View {
    private let viewModel = SqlDailyTrackerViewModel.shared
    
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
        VStack(spacing: 20) {
            Picker("Period", selection: $selectedPeriod) {
                ForEach(ChartPeriod.allCases) { period in
                    Text(period.localizedTitle).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if isLoadingMonths {
                ProgressView("loading_heading")
                    .padding()
            } else if monthsWithData.isEmpty {
                Text("historyRecordWeight_NoWeightYet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                // MARK: - FINAL Navigation Header
                if selectedPeriod == .day {
                    // DAY MODE — navigate by month
                    let sortedMonths = monthsWithData.sorted(by: >)
                    let currentMonthStart = selectedDate.startOfMonth
                    let currentIndex = sortedMonths.firstIndex(of: currentMonthStart) ?? 0

                    HStack {
                            // Jump to oldest
                            Button { selectedDate = sortedMonths.last!.startOfMonth } label: {
                                Image(systemName: "chevron.left.2")
                                    .foregroundColor(currentIndex < sortedMonths.count - 1 ? Color("nfGreenBrand") : .gray)
                            }

                            // One month back
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
                                .font(.title2)
                                .fontWeight(.semibold)

                            Spacer()

                            // One month forward
                            Button {
                                if currentIndex > 0 {
                                    selectedDate = sortedMonths[currentIndex - 1].startOfMonth
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                            }

                            // Jump to newest
                            Button { selectedDate = sortedMonths.first!.startOfMonth } label: {
                                Image(systemName: "chevron.right.2")
                                    .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                            }
                        }
                        .padding(.horizontal)

                } else if selectedPeriod == .month {
                    // MONTH MODE — show one full year, chevrons jump by YEAR
                    let years = yearsWithData.sorted(by: >)
                    let currentIndex = years.firstIndex(of: selectedYear) ?? 0

                    HStack {
                        Button {
                            let oldest = years.last!
                            selectedDate = Calendar.current.date(from: DateComponents(year: oldest, month: 1, day: 1))!
                        } label: {
                            Image(systemName: "chevron.left.2")
                                .foregroundColor(currentIndex < years.count - 1 ? Color("nfGreenBrand") : .gray)
                        }

                        Button {
                            if currentIndex < years.count - 1 {
                                let prev = years[currentIndex + 1]
                                selectedDate = Calendar.current.date(from: DateComponents(year: prev, month: 1, day: 1))!
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
                                selectedDate = Calendar.current.date(from: DateComponents(year: next, month: 1, day: 1))!
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                        }

                        Button {
                            let newest = years.first!
                            selectedDate = Calendar.current.date(from: DateComponents(year: newest, month: 1, day: 1))!
                        } label: {
                            Image(systemName: "chevron.right.2")
                                .foregroundColor(currentIndex > 0 ? Color("nfGreenBrand") : .gray)
                        }
                    }
                    .padding(.horizontal)

                } else {
                    // YEAR MODE — NO NAVIGATION BAR AT ALL
                    EmptyView()
                }
                
                // MARK: - Chart
                Group {
                    switch selectedPeriod {
                    case .day:    DayChartView(selectedMonth: selectedMonth.startOfMonth)
                    case .month:  MonthChartView(selectedYear: selectedYear)
                    case .year:   YearChartView()
                    }
                }
                .frame(minHeight: 340)
                
                Spacer()
                
                NavigationLink(destination: WeightEntryView(initialDate: selectedDate)) {
                    Text("weight_history_edit_data")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.nfGreenBrand)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .whiteInlineGreenTitle("historyRecordWeight.heading")
        .task {
            await SqlDailyTrackerViewModel.shared.preloadAllDataForYearChart()
            
            monthsWithData = await viewModel.availableWeightMonths
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
    
    //// MARK: - Reusable Navigation Rows
    //
    //struct MonthNavigationRow: View {
    //    let currentMonth: Date
    //    let monthsWithData: [Date]
    //    let onMove: (Date) -> Void
    //
    //    private var sortedMonths: [Date] { monthsWithData.sorted(by: >) }
    //    private var index: Int { sortedMonths.firstIndex(of: currentMonth) ?? 0 }
    //
    //    var body: some View {
    //        HStack {
    //            Button { onMove(sortedMonths.last!) } label: {
    //                Image(systemName: "chevron.left.2")
    //                    .foregroundColor(index < sortedMonths.count-1 ? Color("nfGreenBrand") : .gray)
    //            }
    //            Button { onMove(sortedMonths[index + 1]) } label: {
    //                Image(systemName: "chevron.left")
    //                    .foregroundColor(index < sortedMonths.count-1 ? Color("nfGreenBrand") : .gray)
    //            }
    //
    //            Text(currentMonth, format: .dateTime.year().month(.wide))
    //                .font(.title2)
    //                .fontWeight(.semibold)
    //                .frame(maxWidth: .infinity)
    //
    //            Button { onMove(sortedMonths[index - 1]) } label: {
    //                Image(systemName: "chevron.right")
    //                    .foregroundColor(index > 0 ? Color("nfGreenBrand") : .gray)
    //            }
    //            Button { onMove(sortedMonths.first!) } label: {
    //                Image(systemName: "chevron.right.2")
    //                    .foregroundColor(index > 0 ? Color("nfGreenBrand") : .gray)
    //            }
    //        }
    //        .padding(.horizontal)
    //    }
    //}
    
    // Safe array access extension (add once in your project)
    //extension Collection {
    //    subscript(safe index: Index) -> Element? {
    //        indices.contains(index) ? self[index] : nil
    //    }
    //}
    //struct YearNavigationRow: View {
    //    let currentYear: Int
    //    let yearsWithData: [Int]
    //    let onMove: (Int) -> Void
    //    
    //    private var canGoLeft: Bool { yearsWithData.first.map { $0 < currentYear } ?? false }
    //    private var canGoRight: Bool { yearsWithData.last.map { $0 > currentYear } ?? false }
    //    
    //    var body: some View {
    //        HStack {
    //            Button(action: { moveFarLeft() }) { Image(systemName: "chevron.left.2") }
    //                .disabled(!canGoLeft)
    //            
    //            Button(action: { moveLeft() }) { Image(systemName: "chevron.left") }
    //                .disabled(!canGoLeft)
    //            
    //            Text("\(currentYear)")
    //                .font(.headline)
    //                .frame(maxWidth: .infinity)
    //            
    //            Button(action: { moveRight() }) { Image(systemName: "chevron.right") }
    //                .disabled(!canGoRight)
    //            
    //            Button(action: { moveFarRight() }) { Image(systemName: "chevron.right.2") }
    //                .disabled(!canGoRight)
    //        }
    //        .foregroundColor(.nfGreenBrand)
    //        .padding(.horizontal)
    //    }
    //    
    //    private func moveLeft() {
    //        if let idx = yearsWithData.firstIndex(of: currentYear), idx > 0 {
    //            onMove(yearsWithData[idx - 1])
    //        }
    //    }
    //    
    //    private func moveRight() {
    //        if let idx = yearsWithData.firstIndex(of: currentYear), idx < yearsWithData.count - 1 {
    //            onMove(yearsWithData[idx + 1])
    //        }
    //    }
    //    
    //    private func moveFarLeft() { if let y = yearsWithData.first { onMove(y) } }
    //    private func moveFarRight() { if let y = yearsWithData.last { onMove(y) } }
    //}
    
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
