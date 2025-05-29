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
                ScrollView(selectedTimeScale == .daily ? .horizontal : .vertical) {
                    Group {
                        switch selectedTimeScale {
                        case .daily: dailyChart
                        case .monthly: monthlyChart
                        case .yearly: yearlyChart
                        }
                    }
                    .frame(minWidth: selectedTimeScale == .daily ? max(geometry.size.width, 600) : 300, minHeight: 300)
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Chart Views
    
    private var dailyChart: some View {
        Chart {
            ForEach(processor.dailyServings(forMonthOf: selectedDate)) { data in
                BarMark(
                    x: .value("Date", data.date!, unit: .day),
                    y: .value("Servings", data.totalServings)
                )
                .foregroundStyle(data.date! == today ? .red : .brandGreen)
            }
        }
        .chartXScale(domain: dailyXDomain)
        .chartYScale(domain: 0...24)
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
    }
    
    private var monthlyChart: some View {
        Chart {
            ForEach(processor.monthlyServings(forYearOf: selectedDate)) { data in
                LineMark(
                    x: .value("Month", data.date!, unit: .month),
                    y: .value("Servings", data.totalServings)
                )
                .foregroundStyle(.brandGreen)
                .annotation(position: .top, alignment: .center, spacing: 4) {
                    servingsAnnotation(servings: data.totalServings)
                }
            }
        }
        .chartXScale(domain: monthlyXDomain)
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
    }
    
    private var yearlyChart: some View {
        let data = processor.yearlyServings()
        return Group {
            if data.isEmpty {
                Text("No yearly data available")
                    .foregroundColor(.gray)
                    .frame(minWidth: 300, minHeight: 300)
            } else {
                Chart {
                    ForEach(data) { item in
                        LineMark(
                            x: .value("Year", String(item.year!)),
                            y: .value("Servings", item.totalServings)
                        )
                        .annotation(position: .top, alignment: .center, spacing: 8) {
                            servingsAnnotation(servings: item.totalServings, year: item.year!)
                        }
                    }
                }
                .chartXScale(domain: yearlyXDomain(data: data))
                .chartXAxis {
                    AxisMarks(values: data.map { String($0.year!) }) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .background(Color.yellow.opacity(0.2))
            }
        }
    }
    
    // MARK: - Annotation Helper
    
    private func servingsAnnotation(servings: Int, year: Int? = nil) -> some View {
        Text("\(servings)")
            .font(.caption)
            .foregroundColor(.black)
            .padding(2)
            .background(servings > 0 ? Color.white.opacity(0.7) : Color.red.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onAppear {
                if let year = year {
                    print("Yearly: Annotating year \(year), Servings: \(servings)")
                }
            }
    }
    
    // MARK: - Navigation Logic
    
    private func navigateBackward() {
        switch selectedTimeScale {
        case .daily:
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
        case .monthly:
            selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate)!
        default:
            break
        }
    }
    
    private func navigateForward() {
        switch selectedTimeScale {
        case .daily:
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
        case .monthly:
            selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
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
        case .daily:
            return .dateTime.day()
        case .monthly:
            return .dateTime.month(.abbreviated)
        case .yearly:
            return .dateTime.year()
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
    
    private func yearlyXDomain(data: [ChartData]) -> ClosedRange<String> {
        let years = data.map { $0.year! }
        guard let minYear = years.min(), let maxYear = years.max() else {
            let currentYear = calendar.component(.year, from: today)
            print("YearlyXDomain: No data, using fallback: \(currentYear)...\(currentYear)")
            return "\(currentYear)"..."\(currentYear)"
        }
        print("YearlyXDomain: Domain: \(minYear)...\(maxYear)")
        return "\(minYear)"..."\(maxYear)"
    }
}

#Preview {
    let sampleTrackers = [
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 19, hour: 17, minute: 54, second: 50))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2024-05-19", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2024-05-19", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
                // Add more DataCountType keys with count: 0 if needed
            ],
            weightAM: nil,
            weightPM: nil
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 14, hour: 17, minute: 54, second: 50))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-04-14", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 9, hour: 17, minute: 54, second: 50))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-09", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        ),
        SqlDailyTracker(
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 17, minute: 54, second: 50))!,
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 1, datacount_count: 2, datacount_streak: 1)!,
                DataCountType.dozeBerries: SqlDataCountRecord(datacount_date_psid: "2025-05-12", datacount_kind_pfnid: 2, datacount_count: 1, datacount_streak: 1)!
            ],
            weightAM: nil,
            weightPM: nil
        )
    ]
    return DozeServingsHistoryView(trackers: sampleTrackers)
}
