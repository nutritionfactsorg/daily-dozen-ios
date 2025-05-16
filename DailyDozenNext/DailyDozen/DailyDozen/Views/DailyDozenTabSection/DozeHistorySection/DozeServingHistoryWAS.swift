//
//  DozeServingHistory.swift
//  DailyDozen
//
//
//

import SwiftUI
import Charts

struct DozeServingsHistoryViewWAS2: View {
    @State private var selectedTimeScale: TimeScale = .daily
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    let processor: ServingsDataProcessor
    private let dateFormatter = DateFormatter()
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date()) // April 23, 2025
    
    init(trackers: [SqlDailyTracker]) {
        self.processor = ServingsDataProcessor(trackers: trackers)
        dateFormatter.dateFormat = "MMM yyyy"
    }
    
    var body: some View {
        VStack {
            timeScalePicker
            navigationBar
            chartView
        }
    }
    
    // MARK: - Subviews
    
    private var timeScalePicker: some View {
        Picker("Time Scale", selection: $selectedTimeScale) {
            ForEach(TimeScale.allCases) { scale in
                Text(scale.rawValue).tag(scale)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    @ViewBuilder
    private var navigationBar: some View {
        if selectedTimeScale != .yearly {
            HStack {
                Button {
                    navigateBackward()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(!canNavigateBackward())
                
                Spacer()
                
                Text(dateLabel)
                
                Spacer()
                
                Button {
                    navigateForward()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!canNavigateForward())
            }
            .padding(.horizontal)
        }
    }
    
    private var chartView: some View {
        ScrollView(selectedTimeScale == .daily ? .horizontal : .vertical) {
            ScrollViewReader { proxy in
                if #available(iOS 17.0, *) {
                    chartContent
                        .frame(minWidth: selectedTimeScale == .daily ? 1000 : 300, minHeight: 300)
                        .applyChartXScale(domain: chartXDomain)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: xAxisFormat)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .padding()
                        .onChange(of: selectedDate) { _, newDate in
                            if selectedTimeScale == .daily {
                                scrollToToday(proxy: proxy, newDate: newDate)
                            }
                        }
                        .onChange(of: selectedTimeScale) { _, newScale in
                            if newScale == .daily {
                                scrollToToday(proxy: proxy, newDate: selectedDate)
                            }
                        }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    @ViewBuilder
    private var chartContent: some View {
        Chart {
            if selectedTimeScale == .daily {
                ForEach(processor.dailyServings(forMonthOf: selectedDate)) { data in
                    BarMark(
                        x: .value("Date", data.date!, unit: .day),
                        y: .value("Servings", data.totalServings)
                    )
                 //   .id(data.date) // Assign ID for scrolling
                }
            } else if selectedTimeScale == .monthly {
                ForEach(processor.monthlyServings(forYearOf: selectedDate)) { data in
                    LineMark(
                        x: .value("Month", data.date!, unit: .month),
                        y: .value("Servings", data.totalServings)
                    )
                }
            } else {
                ForEach(processor.yearlyServings()) { data in
                    LineMark(
                        x: .value("Year", String(data.year!)),
                        y: .value("Servings", data.totalServings)
                    )
                }
            }
        }
    }
    
    // MARK: - Navigation Logic
    
    private func navigateBackward() {
        if selectedTimeScale == .daily {
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
        } else if selectedTimeScale == .monthly {
            selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate)!
        }
    }
    
    private func navigateForward() {
        if selectedTimeScale == .daily {
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
        } else if selectedTimeScale == .monthly {
            selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
        }
    }
    
    private func canNavigateBackward() -> Bool {
        if selectedTimeScale == .daily {
            return true
        } else if selectedTimeScale == .monthly {
            return true
        }
        return false
    }
    
    private func canNavigateForward() -> Bool {
        if selectedTimeScale == .daily {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
            let startOfNextMonth = calendar.startOfMonth(for: nextMonth)
            return startOfNextMonth <= today
        } else if selectedTimeScale == .monthly {
            let nextYear = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
            let yearOfNextYear = calendar.component(.year, from: nextYear)
            let currentYear = calendar.component(.year, from: today)
            return yearOfNextYear <= currentYear
        }
        return false
    }
    
    // MARK: - Scroll Logic
    
    private func scrollToToday(proxy: ScrollViewProxy, newDate: Date) {
        if calendar.isDate(newDate, inSameMonthAs: today) {
            // Scroll to today if in the current month
            proxy.scrollTo(today, anchor: .center)
        } else {
            // Scroll to the start of the month for past months
            let startOfMonth = calendar.startOfMonth(for: newDate)
            proxy.scrollTo(startOfMonth, anchor: .leading)
        }
    }
    
    // MARK: - Computed Properties
    
    private var dateLabel: String {
        if selectedTimeScale == .daily {
            return dateFormatter.string(from: selectedDate)
        } else if selectedTimeScale == .monthly {
            return "\(calendar.component(.year, from: selectedDate))"
        } else {
            return "All Years"
        }
    }
    
    private var xAxisFormat: Date.FormatStyle {
        switch selectedTimeScale {
        case .daily:
            return .dateTime.day()
        case .monthly:
            return .dateTime.month(.abbreviated)
        case .yearly:
            return .dateTime.year()
        }
    }
    
    private var chartXDomain: ClosedRange<Date>? {
        if selectedTimeScale == .daily {
            let start = calendar.startOfMonth(for: selectedDate)
            let end = min(calendar.endOfMonth(for: selectedDate), today)
            return start...end
        }
        return nil
    }
}
