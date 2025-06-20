//
//  DozeServingsHistoryView.swift
//  DailyDozen
//

import SwiftUI
import Charts
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length

struct DozeServingsHistoryView: View {
    @State private var selectedTimeScale: TimeScale = .daily
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var dailyScrollPosition: Date = Calendar.current.startOfDay(for: Date())
    @State private var monthlyScrollPosition: Date = Calendar.current.startOfMonth(for: Date())
    @State private var yearlyScrollPosition: Date = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()))) ?? Date()
    private let processor: ServingsDataProcessor
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
    
    init(trackers: [SqlDailyTracker]) {
        self.processor = ServingsDataProcessor(trackers: trackers)
    }
    
    var body: some View {
        VStack {
            Picker("Time Scale", selection: $selectedTimeScale) {
                ForEach(TimeScale.allCases) { scale in
                    Text(scale.rawValue).tag(scale)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTimeScale != .yearly {
                HStack {
                    Button(action: navigateBackward) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!canNavigateBackward)
                    
                    Spacer()
                    Text(dateLabel)
                    Spacer()
                    
                    Button(action: navigateForward) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!canNavigateForward)
                }
                .padding(.horizontal)
            }
            
            GeometryReader { geometry in
                Group {
                    switch selectedTimeScale {
                    case .daily:
                        dailyChart
                            .frame(minWidth: max(geometry.size.width, CGFloat(processor.dailyServings(forMonthOf: selectedDate).filter { $0.totalServings > 0 }.count) * 20))
                    case .monthly:
                        monthlyChart
                            .frame(minWidth: max(geometry.size.width, 480))
                    case .yearly:
                        yearlyChart
                            .frame(minWidth: max(geometry.size.width, CGFloat(processor.yearlyServings().count) * 40))
                    }
                }
                .padding(.vertical, 60)
                .padding(.horizontal, 20)
                .frame(minHeight: 600)
            }
        }
        .onChange(of: selectedTimeScale) { _, _ in
            updateScrollPosition()
        }
        .onAppear {
            updateScrollPosition()
        }
    }
    
    // MARK: - Chart Config
    private struct ChartConfig {
        let maxServings: Int
        let yAxisUpperBound: Int
        let chartHeight: CGFloat
        
        init(data: [ChartData], isYearly: Bool) {
            self.maxServings = data.map { $0.totalServings }.max() ?? 0
            self.yAxisUpperBound = min(isYearly ? 11_388 : 967, maxServings + Int(Double(maxServings) * 0.3))
            self.chartHeight = max(300, min(600, CGFloat(maxServings) / (isYearly ? 15 : 2)))
        }
    }
    
    // MARK: - Chart Views
    private var dailyChart: some View {
        let data = processor.dailyServings(forMonthOf: selectedDate).filter { $0.totalServings > 0 }
        return Chart(data) { item in
            BarMark(
                x: .value("Date", item.date!, unit: .day),
                y: .value("Servings", item.totalServings),
                width: 15
            )
            .foregroundStyle(item.date! == today ? .red : .brandGreen)
            .annotation(position: .top, alignment: .center, spacing: 4) {
                servingsAnnotation(servings: item.totalServings)
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartScrollTargetBehavior(.valueAligned(matching: .init()))
        .chartScrollPosition(x: $dailyScrollPosition)
        .chartXScale(domain: dailyXDomain)
        .chartYScale(domain: 0...24)
        .chartXAxis {
            AxisMarks(values: data.map { $0.date! }) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: xAxisFormat, centered: false)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            print("DailyChart Data: \(data.map { "Day: \(calendar.component(.day, from: $0.date!)), Servings: \($0.totalServings)" })")
            print("Y-Axis Domain: 0...24")
        }
    }
    
    private var monthlyChart: some View {
        let data = processor.monthlyServings(forYearOf: selectedDate)
        let config = ChartConfig(data: data, isYearly: false)
        return Chart(data) { item in
            LineMark(
                x: .value("Month", item.date!, unit: .month),
                y: .value("Servings", item.totalServings)
            )
            .foregroundStyle(.brandGreen)
            .interpolationMethod(.catmullRom)
            .lineStyle(.init(lineWidth: 3))
            .symbol(.circle)
            .symbolSize(CGSize(width: 10, height: 10))
            
            PointMark(
                x: .value("Month", item.date!, unit: .month),
                y: .value("Servings", item.totalServings)
            )
            .foregroundStyle(.brandGreen)
            .opacity(0)
            .annotation(position: .top, alignment: .center, spacing: 6) {
                if item.totalServings > 0 {
                    servingsAnnotation(servings: item.totalServings)
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartScrollTargetBehavior(.valueAligned(matching: .init()))
        .chartScrollPosition(x: $monthlyScrollPosition)
        .chartXScale(domain: monthlyXDomain)
        .chartYScale(domain: 0...config.yAxisUpperBound)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.abbreviated))
                            .font(.caption2)
                            .offset(y: 8)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(minHeight: config.chartHeight + 30)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .onAppear {
            print("MonthlyChart Data: \(data.map { "Month: \(calendar.component(.month, from: $0.date!)), Servings: \($0.totalServings)" })")
            print("Y-Axis Domain: 0...\(config.yAxisUpperBound)")
        }
    }
    
    private var yearlyChart: some View {
        let data = processor.yearlyServings()
        return Group {
            if data.isEmpty {
                Text("No yearly data available")
                    .foregroundColor(.gray)
                    .frame(minWidth: 300, minHeight: 300)
            } else {
                yearlyChartContent(data: data)
            }
        }
    }
    
    private func yearlyChartContent(data: [ChartData]) -> some View {
        let config = ChartConfig(data: data, isYearly: true)
        return Chart(data) { item in
            LineMark(
                x: .value("Year", calendar.date(from: DateComponents(year: item.year)) ?? today, unit: .year),
                y: .value("Servings", item.totalServings)
            )
            .foregroundStyle(.brandGreen)
            .interpolationMethod(.catmullRom)
            .lineStyle(.init(lineWidth: 3))
            .symbol(.circle)
            .symbolSize(CGSize(width: 10, height: 10))
            
            PointMark(
                x: .value("Year", calendar.date(from: DateComponents(year: item.year)) ?? today, unit: .year),
                y: .value("Servings", item.totalServings)
            )
            .foregroundStyle(.brandGreen)
            .opacity(0)
            .annotation(position: .top, alignment: .center, spacing: 6) {
                if item.totalServings > 0 {
                    servingsAnnotation(servings: item.totalServings, year: item.year)
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartScrollTargetBehavior(.valueAligned(matching: .init(year: 1)))
        .chartScrollPosition(x: $yearlyScrollPosition)
        .chartXScale(domain: yearlyXDomain(data: data))
        .chartYScale(domain: 0...config.yAxisUpperBound)
        .chartPlotStyle { plotArea in
            plotArea.padding(.bottom, 40)
        }
        .chartXAxis {
            AxisMarks(values: yearlyXDomain(data: data).toArray(using: calendar)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(String(calendar.component(.year, from: date)))
                            .font(.caption2)
                            .rotationEffect(.degrees(-60))
                            .offset(y: 3)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(minHeight: config.chartHeight)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .clipped(antialiased: false)
        .onAppear {
            // Force scroll to latest year on chart appearance
            let latestYear = processor.yearlyServings().compactMap { $0.year }.max() ?? calendar.component(.year, from: today)
            yearlyScrollPosition = calendar.date(from: DateComponents(year: latestYear)) ?? today
        }
    }
    
    // MARK: - Scroll Position Logic
    private func updateScrollPosition() {
        switch selectedTimeScale {
        case .daily:
            let monthStart = calendar.startOfMonth(for: selectedDate)
            let monthEnd = min(calendar.endOfMonth(for: selectedDate), today)
            dailyScrollPosition = today >= monthStart && today <= monthEnd ? today : monthEnd
        case .monthly:
            let yearStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 1, day: 1))!
            let yearEnd = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 12, day: 31))!
            let currentMonthStart = calendar.startOfMonth(for: today)
            monthlyScrollPosition = today >= yearStart && today <= yearEnd ? currentMonthStart : yearEnd
        case .yearly:
            let latestYear = processor.yearlyServings().compactMap { $0.year }.max() ?? calendar.component(.year, from: today)
            yearlyScrollPosition = calendar.date(from: DateComponents(year: latestYear)) ?? today
        }
    }
    
    // MARK: - Annotation Helper
    private func servingsAnnotation(servings: Int, year: Int? = nil) -> some View {
        Text("\(servings)")
            .font(.system(size: 10).bold())
            .foregroundColor(.black)
            .padding(3)
            .background(servings > 0 ? Color.white.opacity(0.9) : Color.red.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onAppear {
                if let year = year {
                    print("Yearly: Annotating year \(year), Servings: \(servings)")
                } else {
                    print("Annotating Servings: \(servings)")
                }
            }
    }
    
    // MARK: - Navigation Logic
    private func navigateBackward() {
        switch selectedTimeScale {
        case .daily:
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
            updateScrollPosition()
        case .monthly:
            selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate)!
            updateScrollPosition()
        default:
            break
        }
    }
    
    private func navigateForward() {
        switch selectedTimeScale {
        case .daily:
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
            updateScrollPosition()
        case .monthly:
            selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
            updateScrollPosition()
        default:
            break
        }
    }
    
    private var canNavigateBackward: Bool {
        switch selectedTimeScale {
        case .daily, .monthly:
            return true
        default:
            return false
        }
    }
    
    private var canNavigateForward: Bool {
        switch selectedTimeScale {
        case .daily:
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
            return calendar.startOfMonth(for: nextMonth) <= today
        case .monthly:
            let nextYear = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
            return calendar.component(.year, from: nextYear) <= calendar.component(.year, from: today)
        default:
            return false
        }
    }
    
    // MARK: - Computed Properties
    private var dateLabel: String {
        switch selectedTimeScale {
        case .daily:
            return dateFormatter.string(from: selectedDate)
        case .monthly:
            return "\(calendar.component(.year, from: selectedDate))"
        case .yearly:
            return "All Years"
        }
    }
    
    private var xAxisFormat: Date.FormatStyle {
        switch selectedTimeScale {
        case .daily: return .dateTime.day()
        case .monthly: return .dateTime.month(.abbreviated)
        case .yearly: return .dateTime.year()
        }
    }
    
    private var dailyXDomain: ClosedRange<Date> {
        let start = calendar.startOfMonth(for: selectedDate)
        let end = min(calendar.endOfMonth(for: selectedDate), today)
        return start...end
    }
    
    private var monthlyXDomain: ClosedRange<Date> {
        let start = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 1, day: 1)) ?? Date()
        let end = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 12, day: 31)) ?? Date()
        return start...end
    }
    
    private func yearlyXDomain(data: [ChartData]) -> ClosedRange<Date> {
        let years = data.compactMap { $0.year }.sorted()
        let startYear = years.first ?? calendar.component(.year, from: today)
        let endYear = years.last ?? calendar.component(.year, from: today)
        let start = calendar.date(from: DateComponents(year: startYear)) ?? today
        let end = calendar.date(from: DateComponents(year: endYear)) ?? today
        return start...end
    }
}

// Helper to generate axis mark values
extension ClosedRange where Bound == Date {
    func toArray(using calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var current = lowerBound
        while current <= upperBound {
            dates.append(current)
            current = calendar.date(byAdding: .year, value: 1, to: current) ?? current
        }
        return dates
    }
}
#Preview {
    let sampleTrackers = [
        // Existing 2015 entry
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2015, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2016
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2016, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2016-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2016-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2017
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2017, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2017-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2017-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2018
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2018-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2018-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2019
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2019, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2019-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2019-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2020
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2020-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2020-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2021
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2021, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2021-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2021-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2022
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2022, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2022-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2022-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Add 2023
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2023-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2023-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Existing 2024 entry
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 19))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        // Existing 2025 entries
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 14))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 9))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 15))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-15", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-15", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        )
    ]
    return DozeServingsHistoryView(trackers: sampleTrackers)
}
