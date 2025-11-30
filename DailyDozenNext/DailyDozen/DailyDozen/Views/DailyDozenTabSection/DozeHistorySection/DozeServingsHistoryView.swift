//
//  DozeServingsHistoryView.swift
//  DailyDozen
//
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import SwiftUI
import Charts

// Extension to ensure unique years
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

struct DozeServingsHistoryView: View {
    @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
   
   // @State private var trackers: [SqlDailyTracker] = []   //TBDz Temporary for refactoring
    @State private var selectedTimeScale: TimeScale = .daily
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var dailyScrollPosition: Date = Calendar.current.startOfDay(for: Date())
    @State private var monthlyScrollPosition: Date = Calendar.current.startOfMonth(for: Date())
    @State private var yearlyScrollPosition: Date = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()))) ?? Date()
    @State private var processor: ServingsDataProcessor
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM yyyy"
//        return formatter
//    }
//    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMM yyyy") // Abbreviated month, year (e.g., "May 2025", "Mai 2025")
        return formatter
    }()
    
    init() {
       // self.processor = ServingsDataProcessor(trackers: []) //Initialize with empty array; updated in onAppear
      
                _processor = State(initialValue: ServingsDataProcessor(trackers: []))
            
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("history_scale_label")
                    .padding()
                    Picker("history_scale_label", selection: $selectedTimeScale) {
                        ForEach(TimeScale.allCases) { scale in
                            Text(scale.localizedName).tag(scale)
                            
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
                if selectedTimeScale != .yearly {
                    HStack {
                        // Double chevron backward
                        Button(action: navigateToStart) {
                            Image(systemName: "chevron.left.2")
                                .foregroundStyle(canNavigateToStart ? .brandGreen : .gray)
                        }
                        .disabled(!canNavigateToStart)
                        .padding()
                        // Single chevron backward
                        Button(action: navigateBackward) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(canNavigateBackward ? .brandGreen : .gray)
                        }
                        .disabled(!canNavigateBackward)
                        
                        Spacer()
                        Text(dateLabel)
                        Spacer()
                        
                        // Single chevron forward
                        Button(action: navigateForward) {
                           Image(systemName: "chevron.right")
                                .foregroundStyle(canNavigateForward ? .brandGreen : .gray)
                        }
                        .disabled(!canNavigateForward)
                        .padding()
                        // Double chevron forward
                        Button(action: navigateToEnd) {
                            Image(systemName: "chevron.right.2")
                                .foregroundStyle(canNavigateToEnd ? .brandGreen : .gray)
                        }
                        .disabled(!canNavigateToEnd)
                    }
                    .padding(.horizontal)
                }
                
                GeometryReader { geometry in
                    Group {
                        switch selectedTimeScale {
                        case .daily:
                            dailyChart
                            //                            .frame(minWidth: max(geometry.size.width, CGFloat(processor.dailyServings(forMonthOf: selectedDate).filter { $0.totalServings > 0 }.count) * 20))
                            //.frame(idealWidth: max(geometry.size.width, CGFloat(processor.dailyServings(forMonthOf: selectedDate).filter { $0.totalServings > 0 }.count) * 20))
                                .frame(idealWidth: max(geometry.size.width, CGFloat(processor.dailyServings(forMonthOf: selectedDate).count) * 40 + 40))
                        case .monthly:
                            monthlyChart
                            //  .frame(minWidth: max(geometry.size.width, 480))
                                .frame(idealWidth: max(geometry.size.width, CGFloat(processor.monthlyServings(forYearOf: selectedDate).count) * 60 + 40))
                        case .yearly:
                            yearlyChart
                                .frame(idealWidth: max(geometry.size.width, CGFloat(processor.yearlyServings().count) * 100 + 40)) // Increased buffer  (adjust the 100  as needed)
                        }
                    }
                    .padding(.vertical, 60)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 600)
                }
            } //MainVStack
            .onChange(of: selectedTimeScale) { _, _ in
                updateScrollPosition()
            }
            .onAppear {
                Task { @MainActor in
                   // trackers = await viewModel.fetchTrackers()
                    // Fetch trackers for a broad date range (e.g., all years)
                   // let earliestDate = Date.distantPast // TBDz this needs changing
                   // trackers = await viewModel.fetchTrackers(forMonth: earliestDate)
                    //processor.updateTrackers(trackers) // Update processor with fetched trackers
                    await viewModel.fetchAllTrackers()
                    processor.updateTrackers(viewModel.trackers)
                    updateScrollPosition()
                }
            }
            .navigationTitle("historyRecordDoze.heading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.brandGreen, for: .navigationBar)
            .toolbarColorScheme(.dark)
        }//NavStack
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
        let allData = processor.dailyServings(forMonthOf: selectedDate)
        let filteredData = allData.filter { $0.totalServings > 0 }

        return VStack(alignment: .center, spacing: 0) {
            Chart(filteredData) { item in
                let date = item.date!
                BarMark(
                    x: .value("Date", date, unit: .day),
                    y: .value("Servings", item.totalServings),
                    width: 10
                )
                .foregroundStyle(date == today ? .red : .brandGreen)
                .annotation(position: .top, alignment: .center, spacing: 4) {
                    if item.totalServings > 0 {
                        servingsAnnotation(servings: item.totalServings)
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartScrollTargetBehavior(.valueAligned(matching: .init()))
            .chartScrollPosition(x: $dailyScrollPosition)
            .chartXScale(domain: dailyXDomain)
            .chartXVisibleDomain(length: Int(15 * 24 * 60 * 60))
            .chartYScale(domain: 0...24)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day, count: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.day())
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                 //   .background(.mint.opacity(0.03))
                    .border(.brandGreen) //TBDz pick color and add to other views
            }

            legendView // Place legend below chart
        }
        .onAppear {
            let scrollDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today) ?? today
            dailyScrollPosition = scrollDate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dailyScrollPosition = scrollDate
            }
            print("DailyChart Filtered Data: \(filteredData.map { "Date: \(String(describing: $0.date)), Day: \(calendar.component(.day, from: $0.date!)), Servings: \($0.totalServings)" })")
            let startDate = calendar.startOfMonth(for: selectedDate)
            let endDate = calendar.endOfMonth(for: selectedDate)
            var currentDate = startDate
            while currentDate <= endDate {
               // print("Expected Daily AxisMark: \(calendar.component(.day, from: currentDate))")
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
    }
    
    private var monthlyChart: some View {
        let data = processor.monthlyServings(forYearOf: selectedDate)
        let config = ChartConfig(data: data, isYearly: false)

        return VStack(alignment: .center, spacing: 0) {
            Chart(data) { item in
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
            .chartXVisibleDomain(length: Int(365 * 24 * 60 * 60))
            .chartYScale(domain: 0...config.yAxisUpperBound)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .month, count: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated))
                                .font(.caption2)
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
            .padding(.horizontal)

            legendView // Place legend below chart
        }
        .onAppear {
            logit.debug("MonthlyChart Data: \(data.map { "Month: \(calendar.component(.month, from: $0.date!)), Servings: \($0.totalServings)" })")
            logit.debug("Y-Axis Domain: 0...\(config.yAxisUpperBound)")
            let startDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 1, day: 1)) ?? selectedDate
            let endDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 12, day: 31)) ?? selectedDate
            var currentDate = startDate
            while currentDate <= endDate {
//                print("Expected Monthly AxisMark: \(calendar.component(.month, from: currentDate))")
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
            }
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
        let domain = yearlyXDomain(data: data)
        let years = data.compactMap { $0.year }.sorted().uniqued()

        return VStack(alignment: .center, spacing: 0) {
            Chart {
                ForEach(data) { item in
                    if let year = item.year {
                        let xValue = calendar.date(from: DateComponents(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0)) ?? today
                        LineMark(
                            x: .value("Year", xValue, unit: .year),
                            y: .value("Servings", item.totalServings)
                        )
                        .foregroundStyle(.brandGreen)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 3))
                        .symbol(.circle)
                        .symbolSize(CGSize(width: 10, height: 10))
                        
                        PointMark(
                            x: .value("Year", xValue, unit: .year),
                            y: .value("Servings", item.totalServings)
                        )
                        .foregroundStyle(.brandGreen)
                        .opacity(0)
                        .annotation(position: .top, alignment: .center, spacing: 6) {
                            if item.totalServings > 0 {
                                servingsAnnotation(servings: item.totalServings, year: year)
                            }
                        }
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartScrollTargetBehavior(.valueAligned(matching: .init(year: 1)))
            .chartScrollPosition(x: $yearlyScrollPosition)
            .chartXScale(domain: domain)
            .chartYScale(domain: 0...config.yAxisUpperBound)
            .chartXVisibleDomain(length: Int(11 * 365 * 24 * 60 * 60))
            .chartPlotStyle { plotArea in
                plotArea
                    .padding(.bottom, 40)
                    .padding(.trailing, 100)
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .year)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let date = value.as(Date.self) {
                            let year = calendar.component(.year, from: date)
                            if years.contains(year) {
                                Text(String(year))
                                    .font(.system(size: 10))
                                    .offset(y: 8)
                            }
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
            .padding(.horizontal)

            legendView // Place legend below chart
        }
        .task {
            if let latestYear = years.max() {
                let scrollDate = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31, hour: 23, minute: 59, second: 59)) ?? today
                yearlyScrollPosition = scrollDate
                print("YearlyChart: Task set scroll position to \(latestYear), Scroll Date: \(yearlyScrollPosition) at \(today)")
            }
        }
        .onAppear {
            if let latestYear = years.max() {
                let scrollDate = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31, hour: 23, minute: 59, second: 59)) ?? today
                yearlyScrollPosition = scrollDate
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    yearlyScrollPosition = scrollDate
                }
            }
        }
    }
    
  private var legendView: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(.brandGreen)
                .frame(width: 12, height: 12)
            Text(String(localized: "historyRecordDoze.legend", comment: "Legend label for servings"))
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .padding(.top, 8)
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
               yearlyScrollPosition = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31)) ?? today
               print("YearlyChart: updateScrollPosition set to \(latestYear), Scroll Date: \(yearlyScrollPosition)")
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
       }
    // MARK: - Navigation Logic
    
    private var earliestDate: Date {
        guard let earliest = processor.earliestDate() else { return today }
        return calendar.startOfMonth(for: earliest)
    }
    private var latestDate: Date {
        guard let latest = processor.latestDate() else { return today }
        return calendar.startOfMonth(for: min(latest, today))
    }
    
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
    
    private func navigateToStart() {
        switch selectedTimeScale {
        case .daily:
            selectedDate = earliestDate
            updateScrollPosition()
        case .monthly:
            selectedDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: earliestDate), month: 1, day: 1))!
            updateScrollPosition()
        default:
            break
        }
    }

    private func navigateToEnd() {
        switch selectedTimeScale {
        case .daily:
            selectedDate = latestDate
            updateScrollPosition()
        case .monthly:
            selectedDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: latestDate), month: 1, day: 1))!
            updateScrollPosition()
        default:
            break
        }
    }
    
    private var canNavigateToStart: Bool {
        switch selectedTimeScale {
        case .daily:
            return calendar.startOfMonth(for: selectedDate) > earliestDate
        case .monthly:
            return calendar.component(.year, from: selectedDate) > calendar.component(.year, from: earliestDate)
        default:
            return false
        }
    }

    private var canNavigateToEnd: Bool {
        switch selectedTimeScale {
        case .daily:
            return calendar.startOfMonth(for: selectedDate) < latestDate
        case .monthly:
            return calendar.component(.year, from: selectedDate) < calendar.component(.year, from: latestDate)
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
    
    private var monthlyXDomain: ClosedRange<Date> {
        let start = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 1, day: 1)) ?? Date()
        let end = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 12, day: 31)) ?? Date()
        guard let endWithBuffer = calendar.date(byAdding: .day, value: 1, to: end) else {
            fatalError("Unable to compute end date with buffer")
        }
        return start...endWithBuffer
    }

    private var dailyXDomain: ClosedRange<Date> {
        let start = calendar.startOfMonth(for: selectedDate)
        let end = calendar.endOfMonth(for: selectedDate)
       // let end = min(calendar.endOfMonth(for: selectedDate), today)
        guard let endWithBuffer = calendar.date(byAdding: .day, value: 1, to: end) else {
            fatalError("Unable to compute end date with buffer")
        }
        
        return start...endWithBuffer
    }   //TBDz need to determine why a buffer is needed.  
    
    private func yearlyXDomain(data: [ChartData]) -> ClosedRange<Date> {
        let startYear = data.compactMap { $0.year }.min() ?? calendar.component(.year, from: today)
        let endYear = (data.compactMap { $0.year }.max() ?? calendar.component(.year, from: today)) + 1 // Extend to next year
       // print("YearlyXDomain: \(startYear) to \(endYear)")
        let startDate = calendar.date(from: DateComponents(year: startYear, month: 1, day: 1, hour: 0, minute: 0, second: 0)) ?? today
        let endDate = calendar.date(from: DateComponents(year: endYear, month: 1, day: 1, hour: 0, minute: 0, second: 0)) ?? today
        return startDate...endDate
    }
}

//#Preview {
//    let sampleTrackers = [
//        // Existing 2015 entry
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2015, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2016
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2016, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2016-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2016-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2017
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2017, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2017-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2017-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2018
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2018-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2018-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2019
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2019, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2019-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2019-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2020
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2020-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2020-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2021
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2021, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2021-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2021-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2022
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2022, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2022-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2022-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Add 2023
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2023-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2023-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Existing 2024 entry
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 19))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        // Existing 2025 entries
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 14))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 9))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 29))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-29", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-29", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!,
//                DataCountType.dozeBeverages: SqlDataCountRecord(datacount_date_psid: "2025-05-29", datacount_kind_pfnid: 11, datacount_count: 2, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        )
//    ]
//    return DozeServingsHistoryView(trackers: sampleTrackers)
//     .environment(\.locale, .init(identifier: "de"))
//}
