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

struct ServingsHistoryView: View {
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var selectedTimeScale: TimeScale = .daily
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var dailyScrollPosition: Date = Calendar.current.startOfDay(for: Date())
    @State private var monthlyScrollPosition: Date = Calendar.current.startOfMonth(for: Date())
    @State private var yearlyScrollPosition: Date = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()))) ?? Date()
    @StateObject private var processor: ServingsDataProcessor
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    @State private var isLoading = true
    private var servingsLegendText: String {
        switch processor.filterType {
        case .doze:
            return String(localized: "historyRecordDoze.legend", comment: "Legend label for doze servings")
        case .tweak:
            return String(localized: "historyRecordTweak.legend", comment: "Legend label for tweak servings")
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMM yyyy") // Abbreviated month, year (e.g., "May 2025", "Mai 2025")
        return formatter
    }()
    
    init(filterType: ChartFilterType) {
        self._processor = StateObject(wrappedValue: ServingsDataProcessor(filterType: filterType))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text("history_scale_label")
                        .font(.subheadline)
                        .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }
                        .offset(y: 2)
                        //.padding(.leading)
                    Picker("history_scale_label", selection: $selectedTimeScale) {
                        ForEach(TimeScale.allCases) { scale in
                            Text(scale.localizedName).tag(scale)
                            
                        }
                    }
                    .pickerStyle(.segmented)
                    .alignmentGuide(.firstTextBaseline) { d in d[.bottom] - 2 }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                
                if selectedTimeScale != .yearly {
                    HStack {
                        // Double chevron backward
                        Button(action: navigateToStart) {
                            Image(systemName: "chevron.left.2")
                                .foregroundStyle(canNavigateToStart ? .nfGreenBrand : .gray)
                        }
                        .disabled(!canNavigateToStart)
                        .padding()
                        // Single chevron backward
                        Button(action: navigateBackward) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(canNavigateBackward ? .nfGreenBrand : .gray)
                        }
                        .disabled(!canNavigateBackward)
                        
                        Spacer()
                        Text(dateLabel)
                        Spacer()
                        
                        // Single chevron forward
                        Button(action: navigateForward) {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(canNavigateForward ? .nfGreenBrand : .gray)
                        }
                        .disabled(!canNavigateForward)
                        .padding()
                        // Double chevron forward
                        Button(action: navigateToEnd) {
                            Image(systemName: "chevron.right.2")
                                .foregroundStyle(canNavigateToEnd ? .nfGreenBrand : .gray)
                        }
                        .disabled(!canNavigateToEnd)
                    }
                    .padding(.horizontal)
                }
                
                GeometryReader { geometry in
                    Group {
                        if isLoading {
                            ProgressView("loading_heading")
                                .progressViewStyle(CircularProgressViewStyle(tint: .nfGreenBrand))
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Group {
                                switch selectedTimeScale {
                                case .daily:
                                    dailyChart
                                        .frame(idealWidth: max(geometry.size.width, CGFloat(processor.dailyServings(forMonthOf: selectedDate).count) * 40 + 40))
                                case .monthly:
                                    monthlyChart
                                        .frame(idealWidth: max(geometry.size.width, CGFloat(processor.monthlyServings(forYearOf: selectedDate).count) * 60 + 40))
                                case .yearly:
                                    yearlyChart
                                        .frame(idealWidth: max(geometry.size.width, CGFloat(processor.yearlyServings().count) * 250 + 40))
                                }
                            }

                        }
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                    
                }
               // .frame(maxWidth: .infinity, maxHeight: .infinity) // makes ProgressView centered
                    .frame(maxHeight: .infinity)                .task {
                    await SqlDailyTrackerViewModel.shared.preloadAllDataForServingsIfNeeded()
                    // This method already checks if data is loaded — it won't double-fetch
                    await MainActor.run {
                        processor.trackers = SqlDailyTrackerViewModel.shared.trackers
                        processor.applyFilter()
                        isLoading = false
                    }
                }
            }
           
            .task(id: selectedDate) {
                updateScrollPosition()
            }
            
            .task(id: selectedTimeScale) {
                updateScrollPosition()
            }

            .whiteInlineGreenTitle("historyRecordDoze.heading")

            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 0) // base inset = tab bar height
                // Uncomment below for extra space above tab bar:
                // .frame(height: 20)
            }
        }//NavStack
        .id(viewModel.refreshID)
    }
    
    // MARK: - Chart Config
    private struct ChartConfig {
        let maxServings: Int
        let yAxisUpperBound: Int
        let chartHeight: CGFloat
        
        init(data: [ChartData], isYearly: Bool, filterType: ChartFilterType) {
            self.maxServings = data.map { $0.totalServings }.max() ?? 0
            let padding = Int(Double(maxServings) * 0.3) + 1   //(1 is padding)
            let dailyMax = filterType == .doze ? 24 : 37
//            if isYearly {
//                cap = filterType == .doze ? 8760 : 13505  // Rough yearly max: 24*365 or 37*365
//            } else {
//                cap = filterType == .doze ? 744 : 1147  // Rough monthly max: 24*31 or 37*31
//                // For daily, this won't apply directly
//            }
            let cap = isYearly ? (dailyMax * 366) : (dailyMax * 31)
            self.yAxisUpperBound = min(cap, maxServings + padding)
            self.chartHeight = max(300, min(600, CGFloat(maxServings) / (isYearly ? 15 : 2)))
        }
    }
    
    // MARK: - Chart Views
    private var dailyChart: some View {
        let allData = processor.dailyServings(forMonthOf: selectedDate)
        let filteredData = allData.filter { $0.totalServings > 0 }
        let maxY = processor.filterType == .doze ? 29 : 42  //(24+5 and 37+5 for padding)
        
        return VStack(alignment: .center, spacing: 0) {
            Chart(filteredData) { item in
                let date = item.date!
                BarMark(
                    x: .value("Date", date, unit: .day),
                    y: .value("Servings", item.totalServings),
                    width: 15
                )
                .foregroundStyle(by: .value("Series", servingsLegendText))  // This creates the legend entry
                .foregroundStyle(.nfGreenBrand)
                
                //.foregroundStyle(date == today ? .nfGreenBrand : .nfGreenBrand)
                .annotation(position: .top, alignment: .center, spacing: 4) {
                    if item.totalServings > 0 {
                        servingsAnnotation(servings: item.totalServings)
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartScrollTargetBehavior(.valueAligned(matching: .init()))
            .chartScrollPosition(x: $dailyScrollPosition)
            .chartScrollPosition(initialX: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today) ?? today)
            .chartXScale(domain: dailyXDomain)
            .chartXVisibleDomain(length: Int(15 * 24 * 60 * 60))
            .chartYScale(domain: 0...maxY)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { value in
                //AxisMarks(preset: .aligned, values: .stride(by: .day, count: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.day())
                               //.font(.caption2)
                               .dynamicTypeSize(.xSmall)
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
                plotArea.padding(.bottom, 70)
                //.border(.nfGreenBrand)
            }
            .chartForegroundStyleScale([servingsLegendText: .nfGreenBrand])
            .chartLegend(position: .bottom, alignment: .center, spacing: 20) {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(.nfGreenBrand)
                        .frame(width: 14, height: 14)  // Perfect square—tweak size if needed
                        //.clipShape(RoundedRectangle(cornerRadius: 2))  // Optional: slight rounding for softer look
                    
                    Text(servingsLegendText)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.systemBackground).opacity(0.9))  // Optional: subtle backdrop for contrast
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
        }
    }
    
    private var monthlyChart: some View {
        let data = processor.monthlyServings(forYearOf: selectedDate)
        let config = ChartConfig(data: data, isYearly: false, filterType: processor.filterType)
        
        return VStack(alignment: .center, spacing: 0) {
            Chart(data) { item in
                LineMark(
                    x: .value("Month", item.date!, unit: .month),
                    y: .value("Servings", item.totalServings)
                )
                //.foregroundStyle(.nfGreenBrand)
                .foregroundStyle(by: .value("Series", servingsLegendText))
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 3))
                .symbol(.circle)
                .symbolSize(CGSize(width: 10, height: 10))
                
                PointMark(
                    x: .value("Month", item.date!, unit: .month),
                    y: .value("Servings", item.totalServings)
                )
                .foregroundStyle(by: .value("Series", servingsLegendText))
                .opacity(0)
                .annotation(position: .top, alignment: .center, spacing: 6) {
                    if item.totalServings > 0 {
                        servingsAnnotation(servings: item.totalServings)
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartScrollTargetBehavior(.valueAligned(matching: .init()))
            //.chartScrollPosition(x: $monthlyScrollPosition)
            .chartScrollPosition(x: $monthlyScrollPosition)  // Keep if needed
            .chartScrollPosition(initialX: calendar.startOfMonth(for: selectedDate))
            .task(id: selectedTimeScale) {
                    if selectedTimeScale == .monthly {
                        let year = calendar.component(.year, from: today)
                        if let januaryThisYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) {
                            if !calendar.isDate(selectedDate, equalTo: januaryThisYear, toGranularity: .month) {
                                selectedDate = januaryThisYear
                            }
                        }
                    }
                }
                .task(id: selectedDate) {
                    let target = calendar.startOfMonth(for: selectedDate)
                    if monthlyScrollPosition != target {
                        monthlyScrollPosition = target
                    }
                }

            .chartXScale(domain: monthlyXDomain)
            .chartXVisibleDomain(length: Int(365 * 24 * 60 * 60))
            .chartYScale(domain: 0...config.yAxisUpperBound)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 6)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated))
                                //.font(.caption2)
                                .dynamicTypeSize(.xSmall)
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
            .chartPlotStyle { plotArea in
                plotArea.padding(.bottom, 70)  // Generous—covers legend + axis labels on small screens; tweak 50–80
            }
            .chartForegroundStyleScale([servingsLegendText: .nfGreenBrand])
            .chartLegend(position: .bottom, alignment: .center, spacing: 20) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.nfGreenBrand)
                        .frame(width: 14, height: 14)  // Circle swatch—matches your points
                    
                    Text(servingsLegendText)
                        .font(.system(size: 12))  // Fixed size—see fix #2 below
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.systemBackground).opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            //.frame(minHeight: config.chartHeight)
            .padding(.vertical, 20)
            .padding(.horizontal)
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
        let config = ChartConfig(data: data, isYearly: true, filterType: processor.filterType)
        let domain = yearlyXDomain(data: data)
        let years = data.compactMap { $0.year }.sorted().uniqued()
        let initialTarget = years.max().flatMap { latestYear in
                calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31))
            } ?? today
        
        return VStack(alignment: .center, spacing: 0) {
            Chart {
                ForEach(data) { item in
                    if let year = item.year {
                        let xValue = calendar.date(from: DateComponents(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0)) ?? today
                        LineMark(
                            x: .value("Year", xValue, unit: .year),
                            y: .value("Servings", item.totalServings)
                        )
                        .foregroundStyle(.nfGreenBrand)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 3))
                        .symbol(.circle)
                        .symbolSize(CGSize(width: 10, height: 10))
                        
                        PointMark(
                            x: .value("Year", xValue, unit: .year),
                            y: .value("Servings", item.totalServings)
                        )
                        .foregroundStyle(.nfGreenBrand)
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
            .chartScrollPosition(initialX: initialTarget)
            .chartXScale(domain: domain)
            .chartYScale(domain: 0...config.yAxisUpperBound)
            .chartXVisibleDomain(length: Int(8 * 365 * 24 * 60 * 60))
            .chartPlotStyle { plotArea in
                plotArea
                    .padding(.bottom, 70)
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
            //.frame(minHeight: config.chartHeight)
            .chartForegroundStyleScale([servingsLegendText: .nfGreenBrand])
            .chartLegend(position: .bottom, alignment: .center, spacing: 20) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.nfGreenBrand)
                        .frame(width: 14, height: 14)
                    
                    Text(servingsLegendText)
                        .font(.system(size: 12))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.systemBackground).opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
        }
        .task {
            if let latestYear = years.max() {
                let scrollDate = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31, hour: 23, minute: 59, second: 59)) ?? today
                yearlyScrollPosition = scrollDate
                print("YearlyChart: Task set scroll position to \(latestYear), Scroll Date: \(yearlyScrollPosition) at \(today)")
            }
        }
//        .onAppear {
//            if let latestYear = years.max() {
//                let scrollDate = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31, hour: 23, minute: 59, second: 59)) ?? today
//                yearlyScrollPosition = scrollDate
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    yearlyScrollPosition = scrollDate
//                }
//            }
//        }
    }
        
    // MARK: - Scroll Position Logic
    private func updateScrollPosition() {
        switch selectedTimeScale {
        case .daily:
            let monthStart = max(calendar.startOfMonth(for: selectedDate), calendar.startOfMonth(for: earliestDate))
            let monthEnd = min(calendar.endOfMonth(for: selectedDate), today)
            dailyScrollPosition = today >= monthStart && today <= monthEnd ? today : monthEnd
           // print("•DEBUG• Daily scroll set to: \(dailyScrollPosition)")
        case .monthly:
            let year = calendar.component(.year, from: selectedDate)
            let earliestYear = calendar.component(.year, from: earliestDate)
            let scrollMonth = year == earliestYear ? calendar.component(.month, from: earliestDate) : calendar.component(.month, from: today)
            let scrollDate = calendar.date(from: DateComponents(year: year, month: scrollMonth, day: 1)) ?? today
            monthlyScrollPosition = scrollDate
            print("•DEBUG• Monthly scroll set to year: \(year), month: \(scrollMonth), scrollDate: \(monthlyScrollPosition)")
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
            .foregroundColor(.black) // •TBDz•color• color check
            .padding(3)
            .background(servings > 0 ? Color.white.opacity(0.9) : Color.red.opacity(0.7)) // •TBDz•color• color check
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
            print("•DEBUG• Navigated backward to month: \(calendar.component(.month, from: selectedDate))-202\(calendar.component(.year, from: selectedDate))")
        case .monthly:
            let newYear = calendar.component(.year, from: selectedDate) - 1
            selectedDate = calendar.date(from: DateComponents(year: newYear, month: 12, day: 1))!
            let scrollMonth = newYear == calendar.component(.year, from: earliestDate) ? calendar.component(.month, from: earliestDate) : 12
            monthlyScrollPosition = calendar.date(from: DateComponents(year: newYear, month: scrollMonth, day: 1))!
            print("•DEBUG• Navigated backward to year: \(newYear), scrollDate: \(monthlyScrollPosition)")
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
        case .daily:
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
            return calendar.startOfMonth(for: prevMonth) >= calendar.startOfMonth(for: earliestDate)
        case .monthly:
            let earliestYear = calendar.component(.year, from: earliestDate)
            let currentYear = calendar.component(.year, from: selectedDate)
            print("•DEBUG• canNavigateBackward: currentYear=\(currentYear), earliestYear=\(earliestYear)")
            return currentYear > earliestYear
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
    
    private var canNavigateToStart: Bool {
        switch selectedTimeScale {
        case .daily:
            return calendar.startOfMonth(for: selectedDate) > calendar.startOfMonth(for: earliestDate)
        case .monthly:
            let earliestYear = calendar.component(.year, from: earliestDate)
            let currentYear = calendar.component(.year, from: selectedDate)
            print("•DEBUG• canNavigateToStart: currentYear=\(currentYear), earliestYear=\(earliestYear)")
            return currentYear > earliestYear
        default:
            return false
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
    
    private func navigateToStart() {
        switch selectedTimeScale {
        case .daily:
            selectedDate = earliestDate
            updateScrollPosition()
            print("•DEBUG• Navigated to start month: \(calendar.component(.month, from: selectedDate))-202\(calendar.component(.year, from: selectedDate))")
        case .monthly:
            let earliestYear = calendar.component(.year, from: earliestDate)
            let earliestMonth = calendar.component(.month, from: earliestDate)
            selectedDate = calendar.date(from: DateComponents(year: earliestYear, month: earliestMonth, day: 1))!
            monthlyScrollPosition = selectedDate
            print("•DEBUG• Navigated to start year: \(earliestYear), scrollDate: \(monthlyScrollPosition)")
        default:
            break
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
        let year = calendar.component(.year, from: selectedDate)
        let earliest = processor.earliestDate() ?? calendar.startOfDay(for: today)
        let earliestYear = calendar.component(.year, from: earliest)
        let startMonth = year == earliestYear ? calendar.component(.month, from: earliest) : 1
        let start = calendar.date(from: DateComponents(year: year, month: startMonth, day: 1)) ?? today
        let end = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) ?? today
        guard let endWithBuffer = calendar.date(byAdding: .day, value: 1, to: end) else {
            fatalError("Unable to compute end date with buffer")
        }
        print("•DEBUG• monthlyXDomain: start=\(start), end=\(endWithBuffer)")
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
