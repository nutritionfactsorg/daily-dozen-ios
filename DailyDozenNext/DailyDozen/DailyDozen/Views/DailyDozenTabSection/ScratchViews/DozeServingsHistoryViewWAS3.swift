//
//  DozeServingsHistoryView.swift
//  DailyDozen
//
import SwiftUI
import Charts

//struct DozeServingsHistoryViewWAS3: View {
//    @State private var selectedTimeScale: TimeScale = .daily
//    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
//    private let processor: ServingsDataProcessor
//    private let calendar = Calendar.current
//    private let today = Calendar.current.startOfDay(for: Date())
//    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM yyyy"
//        return formatter
//    }
//    
//    init(trackers: [SqlDailyTracker]) {
//        self.processor = ServingsDataProcessor(trackers: trackers)
//    }
//    
//    var body: some View {
//        VStack {
//            Picker("Time Scale", selection: $selectedTimeScale) {
//                ForEach(TimeScale.allCases) { scale in
//                    Text(scale.rawValue).tag(scale)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding()
//            
//            if selectedTimeScale != .yearly {
//                HStack {
//                    Button(action: navigateBackward) {
//                        Image(systemName: "chevron.left")
//                    }
//                    .disabled(!canNavigateBackward)
//                    
//                    Spacer()
//                    Text(dateLabel)
//                    Spacer()
//                    
//                    Button(action: navigateForward) {
//                        Image(systemName: "chevron.right")
//                    }
//                    .disabled(!canNavigateForward)
//                }
//                .padding(.horizontal)
//            }
//            
//            GeometryReader { geometry in
//                ScrollView(.horizontal, showsIndicators: true) { // Changed to .horizontal only
//                    Group {
//                        switch selectedTimeScale {
//                        case .daily:
//                            dailyChart
//                                .frame(minWidth: geometry.size.width) // Fit screen for daily
//                        case .monthly:
//                            monthlyChart
//                                .frame(minWidth: 480) // Ensure full width for scrolling
//                        case .yearly:
//                            yearlyChart
//                                .frame(minWidth: CGFloat(processor.yearlyServings().count) * 40) // Match yearly scaling
//                        }
//                    }
//                    .padding(.vertical, 60)
//                    .padding(.horizontal, 20) // Added horizontal padding
//                    .frame(minHeight: 600)
//                    .border(Color.gray, width: 1) // Debug border
//                }
//            }
//        }
//    }
//    
//    // MARK: - Chart Config
//    
//    private struct ChartConfig {
//        let maxServings: Int
//        let yAxisUpperBound: Int
//        let chartHeight: CGFloat
//        
//        init(data: [ChartData], isYearly: Bool) {
//            self.maxServings = data.map { $0.totalServings }.max() ?? 0
//            self.yAxisUpperBound = min(isYearly ? 11_388 : 967, maxServings + Int(Double(maxServings) * 0.3))
//            self.chartHeight = max(300, min(600, CGFloat(maxServings) / (isYearly ? 15 : 2)))
//        }
//    }
//    
//    // MARK: - Annotation View
//    
//    private struct AnnotationView: View {
//        let servings: Int
//        let year: Int?
//        
//        var body: some View {
//            Text("\(servings)")
//                .font(.caption2.bold())
//                .foregroundColor(.black)
//                .padding(4)
//                .background(servings > 0 ? Color.white.opacity(0.9) : Color.red.opacity(0.9))
//                .clipShape(RoundedRectangle(cornerRadius: 4))
//                .border(Color.blue, width: 2)
//                .onAppear {
//                    print("PointMark Annotating: Year \(year ?? -1), Servings: \(servings)")
//                }
//        }
//    }
//    
//    // MARK: - Chart Views
//    
//    private var dailyChart: some View {
//        Chart {
//            ForEach(processor.dailyServings(forMonthOf: selectedDate)) { data in
//                BarMark(
//                    x: .value("Date", data.date!, unit: .day),
//                    y: .value("Servings", data.totalServings)
//                )
//                .foregroundStyle(data.date! == today ? .red : .brandGreen)
//            }
//        }
//        .chartXScale(domain: dailyXDomain)
//        .chartYScale(domain: 0...24)
//        .chartXAxis {
//            AxisMarks(values: .automatic) { _ in
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel(format: xAxisFormat)
//            }
//        }
//        .chartYAxis {
//            AxisMarks(values: .automatic) { _ in
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel()
//            }
//        }
//    }
//    
//    private var monthlyChart: some View {
//        let data = processor.monthlyServings(forYearOf: selectedDate)
//        let config = ChartConfig(data: data, isYearly: false)
//        return Chart(data) { item in
//            LineMark(
//                x: .value("Month", item.date!, unit: .month),
//                y: .value("Servings", item.totalServings)
//            )
//            .foregroundStyle(.brandGreen)
//            .interpolationMethod(.catmullRom)
//            .lineStyle(.init(lineWidth: 3))
//            .symbol(.circle)
//            .symbolSize(CGSize(width: 10, height: 10))
//            
//            PointMark(
//                x: .value("Month", item.date!, unit: .month),
//                y: .value("Servings", item.totalServings)
//            )
//            .foregroundStyle(.brandGreen)
//            .opacity(0)
//            .annotation(position: .top, alignment: .center, spacing: 6) {
//                servingsAnnotation(servings: item.totalServings)
//            }
//        }
//        .chartXScale(domain: monthlyXDomain)
//        .chartYScale(domain: 0...config.yAxisUpperBound)
//        .chartXAxis {
//            AxisMarks(values: .automatic) { value in
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel {
//                    if let date = value.as(Date.self) {
//                        Text(date, format: .dateTime.month(.abbreviated))
//                            .font(.caption2)
//                        //   .rotationEffect(.degrees(-60))
//                            .offset(y: 0)
//                    }
//                }
//            }
//        }
//        .chartYAxis {
//            AxisMarks(values: .automatic) {
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel()
//            }
//        }
//        .frame(minHeight: config.chartHeight + 30)
//        .padding(.vertical, 40)
//        .padding(.horizontal, 20) // Added horizontal padding
//        .background(Color.yellow.opacity(0.2))
//        .border(Color.red, width: 1) // Debug border
//        .onAppear {
//            print("MonthlyChart Data: \(data.map { "Month: \(calendar.component(.month, from: $0.date!)), Servings: \($0.totalServings)" })")
//            print("Y-Axis Domain: 0...\(config.yAxisUpperBound)")
//        }
//    }
//    
//    private var yearlyChart: some View {
//        let data = processor.yearlyServings()
//        return Group {
//            if data.isEmpty {
//                Text("No yearly data available")
//                    .foregroundColor(.gray)
//                    .frame(minWidth: 300, minHeight: 300)
//            } else {
//                yearlyChartContent(data: data)
//            }
//        }
//    }
//    
//    private func yearlyChartContent(data: [ChartData]) -> some View {
//        let config = ChartConfig(data: data, isYearly: true)
//        let domain = yearlyXDomain(data: data)
//        // Create Date objects for x-axis marks, matching chart x-values exactly
//        let years = data.compactMap { $0.year }.sorted().uniqued()
//        let yearDates = years.map { year in
//            let components = DateComponents(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0)
//            guard let date = calendar.date(from: components) else {
//                fatalError("Failed to create date for year \(year)")
//            }
//            return date
//        }
//
//        // Debug data
//        let debugYears = years
//        let debugYearDates = yearDates.map { calendar.component(.year, from: $0) }
//
//        return Chart(data) { item in
//            let xValue = calendar.date(from: DateComponents(year: item.year, month: 1, day: 1, hour: 0, minute: 0, second: 0)) ?? {
//                fatalError("Failed to create date for year \(item.year ?? -1)")
//            }()
//            LineMark(
//                x: .value("Year", xValue, unit: .year),
//                y: .value("Servings", item.totalServings)
//            )
//            .foregroundStyle(.brandGreen)
//            .interpolationMethod(.catmullRom)
//            .lineStyle(.init(lineWidth: 3))
//            .symbol(.circle)
//            .symbolSize(CGSize(width: 10, height: 10))
//            
//            PointMark(
//                x: .value("Year", xValue, unit: .year),
//                y: .value("Servings", item.totalServings)
//            )
//            .foregroundStyle(.brandGreen)
//            .opacity(0)
//            .annotation(position: .top, alignment: .center, spacing: 6) {
//                if item.totalServings > 0 {
//                    servingsAnnotation(servings: item.totalServings, year: item.year)
//                }
//            }
//        }
//        .chartScrollableAxes(.horizontal)
//        .chartScrollTargetBehavior(.valueAligned(matching: .init(year: 1)))
//        .chartScrollPosition(x: $yearlyScrollPosition)
//        .chartXScale(domain: domain)
//        .chartYScale(domain: 0...config.yAxisUpperBound)
//        .chartXVisibleDomain(length: Int(11 * 365 * 24 * 60 * 60)) // 11 years
//        .chartPlotStyle { plotArea in
//            plotArea
//                .padding(.bottom, 40)
//                .padding(.trailing, 100)
//        }
//        .chartXAxis {
//            AxisMarks(values: yearDates) { value in
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel(centered: true) {
//                    if let date = value.as(Date.self) {
//                        Text(String(calendar.component(.year, from: date)))
//                            .font(.system(size: 10))
//                            .offset(y: 20)
//                    }
//                }
//            }
//        }
//        .chartYAxis {
//            AxisMarks(values: .automatic) {
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel()
//            }
//        }
//        .frame(minHeight: config.chartHeight)
//        .padding(.vertical, 30)
//        .padding(.horizontal)
//        .task {
//            if let latestYear = years.max() {
//                let scrollDate = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31, hour: 0, minute: 0, second: 0)) ?? {
//                    fatalError("Failed to create scroll date for year \(latestYear)")
//                }()
//                yearlyScrollPosition = scrollDate
//                print("YearlyChart: Task set scroll position to \(latestYear), Scroll Date: \(yearlyScrollPosition)")
//            }
//        }
//        .onAppear {
//            if let latestYear = years.max() {
//                let scrollDate = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31, hour: 0, minute: 0, second: 0)) ?? {
//                    fatalError("Failed to create scroll date for year \(latestYear)")
//                }()
//                yearlyScrollPosition = scrollDate
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    yearlyScrollPosition = scrollDate
//                }
//                print("YearlyChart: OnAppear set scroll position to \(latestYear), Scroll Date: \(yearlyScrollPosition), Years: \(debugYears), YearDates: \(debugYearDates), Chart Width: \(max(300, CGFloat(data.count) * 150 + 40))")
//            }
//            print("YearlyChart Data: \(data.map { "Year: \($0.year ?? -1), Servings: \($0.totalServings)" })")
//        }
//    }
//
//    // MARK: - Scroll Position Logic
//      private func updateScrollPosition() {
//          switch selectedTimeScale {
//          case .daily:
//              let monthStart = calendar.startOfMonth(for: selectedDate)
//              let monthEnd = min(calendar.endOfMonth(for: selectedDate), today)
//              dailyScrollPosition = today >= monthStart && today <= monthEnd ? today : monthEnd
//          case .monthly:
//              let yearStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 1, day: 1))!
//              let yearEnd = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 12, day: 31))!
//              let currentMonthStart = calendar.startOfMonth(for: today)
//              monthlyScrollPosition = today >= yearStart && today <= yearEnd ? currentMonthStart : yearEnd
//          case .yearly:
//              let latestYear = processor.yearlyServings().compactMap { $0.year }.max() ?? calendar.component(.year, from: today)
//              yearlyScrollPosition = calendar.date(from: DateComponents(year: latestYear, month: 12, day: 31)) ?? today
//              print("YearlyChart: updateScrollPosition set to \(latestYear), Scroll Date: \(yearlyScrollPosition)")
//          }
//      }
//    // MARK: - Annotation Helper
//    
//    private func servingsAnnotation(servings: Int, year: Int? = nil) -> some View {
//        Text("\(servings)")
//            .font(.caption2.bold())
//            .foregroundColor(.black)
//            .padding(4)
//            .background(servings > 0 ? Color.white.opacity(0.9) : Color.red.opacity(0.7))
//            .clipShape(RoundedRectangle(cornerRadius: 4))
//            .border(Color.blue, width: 2)
//            .onAppear {
//                if let year = year {
//                    print("Yearly: Annotating year \(year), Servings: \(servings)")
//                }
//            }
//    }
//    
//    // MARK: - Navigation Logic
//    
//    private func navigateBackward() {
//        switch selectedTimeScale {
//        case .daily:
//            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
//        case .monthly:
//            selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate)!
//        default:
//            break
//        }
//    }
//    
//    private func navigateForward() {
//        switch selectedTimeScale {
//        case .daily:
//            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
//        case .monthly:
//            selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
//        default:
//            break
//        }
//    }
//    
//    private var canNavigateBackward: Bool {
//        switch selectedTimeScale {
//        case .daily, .monthly:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    private var canNavigateForward: Bool {
//        switch selectedTimeScale {
//        case .daily:
//            let nextMonth = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
//            return calendar.startOfMonth(for: nextMonth) <= today
//        case .monthly:
//            let nextYear = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
//            return calendar.component(.year, from: nextYear) <= calendar.component(.year, from: today)
//        default:
//            return false
//        }
//    }
//    
//    // MARK: - Computed Properties
//    
//    private var dateLabel: String {
//        switch selectedTimeScale {
//        case .daily:
//            return dateFormatter.string(from: selectedDate)
//        case .monthly:
//            return "\(calendar.component(.year, from: selectedDate))"
//        case .yearly:
//            return "All Years"
//        }
//    }
//    
//    private var xAxisFormat: Date.FormatStyle {
//        switch selectedTimeScale {
//        case .daily: return .dateTime.day()
//        case .monthly: return .dateTime.month(.abbreviated)
//        case .yearly: return .dateTime.year()
//        }
//    }
//    
//    private var dailyXDomain: ClosedRange<Date> {
//        let start = calendar.startOfMonth(for: selectedDate)
//        let end = min(calendar.endOfMonth(for: selectedDate), today)
//        return start...end
//    }
//    
//    private var monthlyXDomain: ClosedRange<Date> {
//        let start = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 1, day: 1)) ?? Date()
//        let end = calendar.date(from: DateComponents(year: calendar.component(.year, from: selectedDate), month: 12, day: 31)) ?? Date()
//        return start...end
//    }
//    
//    private func yearlyXDomain(data: [ChartData]) -> [String] {
//        let years = data.compactMap { $0.year.map { String($0) } }.sorted()
//        let result = years.isEmpty ? [String(calendar.component(.year, from: today))] : years
//        print("YearlyXDomain: Domain: \(result.joined(separator: ", "))")
//        return result
//    }
//}
//
//#Preview {
//    let sampleTrackers = [
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2015, month: 6, day: 1))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2015-06-01", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
//        SqlDailyTracker(
//            date: Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 19))!,
//            itemsDict: [
//                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
//                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2024-05-18", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
//            ],
//            weightAM: nil,
//            weightPM: nil
//        ),
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
//        )
//    ]
//    return DozeServingsHistoryView(trackers: sampleTrackers)
//}
//
//
