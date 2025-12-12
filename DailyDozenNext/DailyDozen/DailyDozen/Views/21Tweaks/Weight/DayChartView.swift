//
//  DayChartView.swift
//  DailyDozen
//
//
import SwiftUI
import Charts

struct DayChartView: View {
    let selectedMonth: Date
    @Environment(\.layoutDirection) private var layoutDirection
    private let viewModel = SqlDailyTrackerViewModel.shared
   // @EnvironmentObject private var viewModel: SqlDailyTrackerViewModel
    @State private var weightData: [WeightDataPoint] = []
    @State private var isLoading: Bool = false
    
    private var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar
    }
    
    private var displayCalendar: Calendar {
        var calendar = Calendar.current // Supports Persian if locale is fa_IR
        calendar.locale = Locale.current
        return calendar
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    private var dayNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    private var displayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = displayCalendar
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = displayCalendar
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 250)
            } else if weightData.isEmpty {
                Text("No weight data for this month")  //TBDz not localized but should be here
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, minHeight: 250)
            } else {
                VStack(spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        Chart(weightData) { dataPoint in
                            LineMark(
                                x: .value("Day", gregorianCalendar.component(.day, from: dataPoint.date)),
                                y: .value("Weight", dataPoint.weight),
                                series: .value("Series", dataPoint.type == .am ? "AM" : "PM")
                            )
                            .foregroundStyle(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                            .symbol(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                            .symbol {
                                Circle()
                                    .fill(dataPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"))
                                    .stroke(dataPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"), lineWidth: 2)
                                    .frame(width: 8, height: 8)
                            }
                            .interpolationMethod(.catmullRom)
                        }
                        .chartForegroundStyleScale([
                            "AM": Color("yellowSunglowColor"),
                            "PM": Color("redFlamePeaColor")
                        ])
                        .chartXAxis {
                            AxisMarks(values: dataDays(weightData)) { value in
                                if let day = value.as(Int.self) {
                                    AxisValueLabel {
                                        Text(dayNumberFormatter.string(from: NSNumber(value: day)) ?? "\(day)")
                                    }
                                    AxisGridLine()
                                    AxisTick()
                                }
                            }
                        }
                        .chartXScale(domain: xAxisDomain(for: weightData))
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                if let weight = value.as(Double.self) {
                                    AxisValueLabel {
                                        Text(numberFormatter.string(from: NSNumber(value: weight)) ?? String(format: "%.1f", weight))
                                            .font(layoutDirection == .rightToLeft ? .caption2 : .caption)
                                            .padding(layoutDirection == .rightToLeft ? .trailing : .leading, 20)
                                    }
                                    AxisGridLine()
                                    AxisTick()
                                }
                            }
                        }
                        .chartYScale(domain: computeYDomain(for: weightData))
                        .chartLegend(.hidden)
                        .padding(.horizontal, layoutDirection == .rightToLeft ? 20 : 10)
                        .padding(.top)
                        .frame(minWidth: max(350, CGFloat(xAxisDomain(for: weightData).count) * 20), minHeight: 250)
                    }
                    .frame(height: 250)
                    // Legend
                    HStack {
                        Circle()
                            .fill(Color("yellowSunglowColor"))
                            .frame(width: 12, height: 12)
                        Text("AM")
                            .font(.caption)
                        Spacer()
                        Circle()
                            .fill(Color("redFlamePeaColor"))
                            .frame(width: 12, height: 12)
                        Text("PM")
                            .font(.caption)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            Task { @MainActor in
                isLoading = true
                weightData = await computeWeightData()
                isLoading = false
                print("🟢 •DayChart• onAppear: Initialized weightData with \(weightData.count) points for \(selectedMonth.datestampSid)")
            }
        }
        .onChange(of: selectedMonth) { _, _ in
            Task { @MainActor in
                isLoading = true
                weightData = await computeWeightData()
                isLoading = false
                print("🟢 •DayChart• onChange: Updated weightData with \(weightData.count) points for \(selectedMonth.datestampSid)")
            }
        }
        .onChange(of: viewModel.trackers) { _, _ in
            Task { @MainActor in
                isLoading = true
                weightData = await computeWeightData()
                isLoading = false
                print("🟢 •DayChart• onChange: Updated weightData with \(weightData.count) points for \(selectedMonth.datestampSid) after trackers update")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
            Task { @MainActor in
                isLoading = true
                weightData = await computeWeightData()
                isLoading = false
                print("🟢 •DayChart• onReceive: Refreshed weightData with \(weightData.count) points for \(selectedMonth.datestampSid) after DB update")
            }
        }
    }
    
    private func computeWeightData() async -> [WeightDataPoint] {
        let unitType = UnitType.fromUserDefaults()
        let monthStart = gregorianCalendar.date(from: gregorianCalendar.dateComponents([.year, .month], from: selectedMonth))!
        let monthEnd = gregorianCalendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        var dataPoints: [WeightDataPoint] = []
        for tracker in viewModel.trackers where tracker.date >= monthStart && tracker.date < monthEnd {
            if let amWeight = tracker.weightAM?.dataweight_kg, amWeight > 0 {
                let weight = unitType == .metric ? amWeight : await UnitsUtility.regionalWeight(fromKg: amWeight, toUnits: .imperial, toDecimalDigits: 1).flatMap { Double($0) } ?? (amWeight * 2.20462)
                dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .am))
                print("🟢 •DayChart• Added AM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
            }
            if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
                let weight = unitType == .metric ? pmWeight : await UnitsUtility.regionalWeight(fromKg: pmWeight, toUnits: .imperial, toDecimalDigits: 1).flatMap { Double($0) } ?? (pmWeight * 2.20462)
                dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .pm))
                print("🟢 •DayChart• Added PM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
            }
        }
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    private func computeYDomain(for dataPoints: [WeightDataPoint]) -> ClosedRange<Double> {
        guard !dataPoints.isEmpty else { return 0...100 }
        let weights = dataPoints.map { $0.weight }
        let minWeight = weights.min() ?? 0
        let maxWeight = weights.max() ?? 100
        let padding = (maxWeight - minWeight) * 0.1
        let lowerBound = max(0, minWeight - padding)
        let upperBound = maxWeight + padding
        return lowerBound...upperBound
    }
    
    private func dataDays(_ dataPoints: [WeightDataPoint]) -> [Int] {
        let monthDayCount = displayCalendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30
        return stride(from: 5, through: monthDayCount, by: 5).map { $0 }
    }
    
    private func xAxisDomain(for dataPoints: [WeightDataPoint]) -> ClosedRange<Int> {
        let monthDayCount = displayCalendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30
        return 1...monthDayCount
    }
}
