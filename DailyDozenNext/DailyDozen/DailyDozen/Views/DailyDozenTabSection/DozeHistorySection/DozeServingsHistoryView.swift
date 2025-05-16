//
//  DozeServingsHistoryView.swift
//  DailyDozen
//
//  Created by mc on 4/24/25.
//

import SwiftUI
import Charts

struct DozeServingsHistoryView: View {
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
        GeometryReader { geometry in
            ScrollView(selectedTimeScale == .daily ? .horizontal : .vertical) {
                ScrollViewReader { proxy in
                    chartContent
                        .id("chartContent")
                        .frame(minWidth: selectedTimeScale == .daily ? max(geometry.size.width, 600) : 300, minHeight: 300)
                        .applyChartXScale(domain: chartXDomain)
                        .chartXScaleIfDaily(timeScale: selectedTimeScale, domain: chartXDomain, selectedDate: selectedDate)
                                            
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
                        .onChange(of: selectedDate) { newDate in
                            if selectedTimeScale == .daily {
                                scrollToToday(proxy: proxy, newDate: newDate, chartWidth: max(geometry.size.width, 600))
                            }
                        }
                        .onChange(of: selectedTimeScale) { newScale in
                            if newScale == .daily {
                                scrollToToday(proxy: proxy, newDate: selectedDate, chartWidth: max(geometry.size.width, 600))
                            }
                        }
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
                    .foregroundStyle(data.date! == today ? .red : .blue) // Highlight today
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
    
    private func scrollToToday(proxy: ScrollViewProxy, newDate: Date, chartWidth: CGFloat) {
        guard selectedTimeScale == .daily else { return }
        
        let startOfMonth = calendar.startOfMonth(for: newDate)
        let endOfMonth = min(calendar.endOfMonth(for: newDate), today)
        let totalDays = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day! + 1
        
        // Calculate the target date to scroll to
        let targetDate: Date
        let anchor: UnitPoint
        if calendar.isDate(newDate, inSameMonthAs: today) {
            targetDate = today // Scroll to today if in the current month
            anchor = .center
        } else {
            targetDate = startOfMonth // Scroll to the start for past months
            anchor = .leading
        }
        
        // Calculate the proportional offset (0 to 1) of the target date in the month
        let daysFromStart = calendar.dateComponents([.day], from: startOfMonth, to: targetDate).day!
        let scrollFraction = Double(daysFromStart) / Double(totalDays)
        
        // Adjust for chart padding (approximate)
        let adjustedChartWidth = chartWidth - 40 // Subtract padding (approximate 20 points on each side)
        let scrollOffset = scrollFraction * Double(adjustedChartWidth)
        
        // Ensure scroll happens after layout
        DispatchQueue.main.async {
            proxy.scrollTo("chartContent", anchor: UnitPoint(x: scrollFraction, y: 0))
            print("Scrolling to fraction: \(scrollFraction), offset: \(scrollOffset), chartWidth: \(chartWidth)")
        }
    }
    
    // MARK: - Helper Functions
    
    private func numberOfDaysInMonth(for date: Date) -> Int {
        let startOfMonth = calendar.startOfMonth(for: date)
        let endOfMonth = min(calendar.endOfMonth(for: date), today)
        return calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day! + 1
    }
    
    // MARK: - Chart Modifiers
    
    @ViewBuilder
    private func chartXScaleIfDaily() -> some View {
        if selectedTimeScale == .daily, let domain = chartXDomain {
            self.chartXScale(domain: domain, range: 0...(20 * Double(numberOfDaysInMonth(for: selectedDate))))
        } else {
            self
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

#Preview {
    DozeServingsHistoryView(trackers: [b])
}
//TBDz move to extensions
extension View {
    @ViewBuilder
    func chartXScaleIfDaily(timeScale: TimeScale, domain: ClosedRange<Date>?, selectedDate: Date) -> some View {
        if timeScale == .daily, let domain = domain {
            let calendar = Calendar.current
            let startOfMonth = calendar.startOfMonth(for: selectedDate)
            let endOfMonth = min(calendar.endOfMonth(for: selectedDate), calendar.startOfDay(for: Date()))
            let totalDays = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day! + 1
            self.chartXScale(domain: domain, range: 0...(20 * Double(totalDays)))
        } else {
            self
        }
    }
}
