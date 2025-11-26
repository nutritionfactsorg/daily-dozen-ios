//
//  DozeServingsHistoryView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import Charts

//::!!NYIz: localization
struct DozeServingsHistoryViewWAS: View {
    let trackers: [SqlDailyTracker] = returnSQLDataArray()
    @State private var selectedTimeScale: TimeScale = .daily
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date()) // Default to today
    let processor: ServingsDataProcessor
    private let dateFormatter = DateFormatter()
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    @State private var scrollPosition: Date // For daily chart scroll position
    
    init(trackers: [SqlDailyTracker]) {
        self.processor = ServingsDataProcessor(trackers: trackers)
        dateFormatter.dateFormat = "MMM yyyy"
        _scrollPosition = State(initialValue: Calendar.current.startOfDay(for: Date()))
    }
    
    var body: some View {
        VStack {
            // Time scale picker
            Picker("Time Scale", selection: $selectedTimeScale) {
                ForEach(TimeScale.allCases) { scale in
                    Text(scale.rawValue).tag(scale)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Navigation arrows
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
            
            // Chart
            ScrollView(selectedTimeScale == .daily ? .horizontal : .vertical) {
                if #available(iOS 17.0, *) {
                    Chart {
                        if selectedTimeScale == .daily {
                            ForEach(processor.dailyServings(forMonthOf: selectedDate)) { data in
                                BarMark(
                                    x: .value("Date", data.date!, unit: .day),
                                    y: .value("Servings", data.totalServings)
                                )
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
                                    x: .value("Year", String(data.year!)), // Use year as a categorical string
                                    y: .value("Servings", data.totalServings)
                                )
                                .foregroundStyle(.brandGreen)
                                .symbol(.circle)
                            }
                        }
                    }
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
                    .chartScrollPosition(x: $scrollPosition) // Always pass $scrollPosition
                    .padding()
                    //                .onChange(of: selectedDate) { _, newDate in
                    //                    if selectedTimeScale == .daily {
                    //                        if calendar.isDate(newDate, inSameMonthAs: today) {
                    //                            scrollPosition = today
                    //                        } else {
                    //                            scrollPosition = calendar.startOfMonth(for: newDate)
                    //                        }
                    //                    } else {
                    //                        // Set to a default date that won't affect monthly/yearly charts
                    //                        scrollPosition = calendar.startOfDay(for: Date.distantPast)
                    //                    }
                    //                }
                    .onChange(of: selectedTimeScale) { _, newScale in
                        if newScale == .daily {
                            if calendar.isDate(selectedDate, inSameMonthAs: today) {
                                scrollPosition = today
                            } else {
                                scrollPosition = calendar.startOfMonth(for: selectedDate)
                            }
                        } else {
                            // Set to a default date that won't affect monthly/yearly charts
                            scrollPosition = calendar.startOfDay(for: Date.distantPast)
                        }
                    }
                } else {
                    // Fallback on earlier versions
                } //onChange
                }
        }
    }
    
    private func navigateBackward() {
        if selectedTimeScale == .daily {
            selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
        } else if selectedTimeScale == .monthly {
            selectedDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate)!
        }
    }
    
    private func navigateForward() {
        if selectedTimeScale == .daily {
            selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
        } else if selectedTimeScale == .monthly {
            selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate)!
        }
    }
    
    private func canNavigateBackward() -> Bool {
        if selectedTimeScale == .daily {
            // Allow navigating to past months
            return true
        } else if selectedTimeScale == .monthly {
            // Allow navigating to past years
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
    
    private var dateLabel: String {
        if selectedTimeScale == .daily {
            return dateFormatter.string(from: selectedDate)
        } else if selectedTimeScale == .monthly {
            return "\(Calendar.current.component(.year, from: selectedDate))"
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
    DozeServingsHistoryViewWAS(trackers: [b])
}
