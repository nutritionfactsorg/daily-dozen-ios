//
//  DayChartView.swift
//  DailyDozen
//
// swiftlint:disable type_body_length

import SwiftUI
import Charts

struct DayChartView: View {
    let selectedMonth: Date
    @Environment(\.layoutDirection) private var layoutDirection
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var weightData: [WeightDataPoint] = []
    @State private var isLoading: Bool = false
    @State private var selectedDay: Int?
    @State private var selectedPoint: WeightDataPoint?
    
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
    
    private var unitString: String {
        UnitType.fromUserDefaults() == .metric ? "kg" : "lbs"
    }

    private var uniqueDataDays: Set<Int> {
        Set(weightData.map { gregorianCalendar.component(.day, from: $0.date) })
    }

    private func findClosestDay(to day: Int) -> Int {
        guard !uniqueDataDays.isEmpty else { return day }
        return uniqueDataDays.min(by: { abs($0 - day) < abs($1 - day) }) ?? day
    }

    private func annotationPosition(for point: WeightDataPoint) -> AnnotationPosition {
        let domain = computeYDomain(for: weightData)
        return point.weight > domain.upperBound * 0.8 ? .top : .bottom
    }

    private func annotationAlignment(for day: Int?) -> Alignment {
        guard let day = day else { return .center }
        let totalDays = displayCalendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 31
        
        let leftThreshold = Int(Double(totalDays) * 0.25)   // ~8 days
        let rightThreshold = Int(Double(totalDays) * 0.75)  // ~23–24 days
        
        if day < leftThreshold {
            return .leading     // Day 1–7: popover extends right → safe on left edge
        } else if day > rightThreshold {
            return .trailing    // Last week: popover extends left → safe on right edge
        } else {
            return .center
        }
    }
    
    private var dayWeightChart: some View {
        Chart {
            ForEach(weightData) { dataPoint in
                LineMark(
                    x: .value("Day", gregorianCalendar.component(.day, from: dataPoint.date)),
                    y: .value("Weight", dataPoint.weight),
                    series: .value("Series", dataPoint.type == .am ? "AM" : "PM")
                )
                .foregroundStyle(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .symbol(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .symbolSize(80)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                 }
                // Your selected RuleMark + PointMark block (unchanged)
                if let day = selectedDay, let point = selectedPoint {
                    RuleMark(x: .value("Day", day))
                        .foregroundStyle(.gray.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        .offset(yStart: -20)
                        .zIndex(-1)
                    
                    PointMark(
                        x: .value("Day", day),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(point.type == .am ? Color("nfYellowSunglow") : Color("nfRedFlamePea"))
                    .symbolSize(100)
                    .symbol(by: .value("Series", point.type == .am ? "AM" : "PM"))
                    .annotation(
                        position: annotationPosition(for: point),
                        alignment: annotationAlignment(for: day),
                        spacing: 10,
                        overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                    ) {
                        valueSelectionPopover(for: point)
                    }
               
            }
        }
        .chartForegroundStyleScale([
            "AM": Color("nfYellowSunglow"),
            "PM": Color("nfRedFlamePea")
        ])
        .chartSymbolScale([
            "AM": .circle,
            "PM": .square
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
        .chartXVisibleDomain(length: displayCalendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 31)
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
        .chartScrollableAxes(.horizontal)
        .chartPlotStyle { plot in
            plot
               // .padding(.leading, 40)
               // .padding(.trailing, 40)
                .padding(.top, 20)
        }
        .chartGesture { proxy in
            SpatialTapGesture()
                .onEnded { value in
                    // Your full gesture code (unchanged)
                    let location = value.location
                    
                    guard let tappedDayDouble: Double = proxy.value(atX: location.x) else {
                                selectedDay = nil
                                selectedPoint = nil
                                return
                            }
                    
                    let tappedDay = Int(tappedDayDouble.rounded())
                    
                    let closestDay = findClosestDay(to: tappedDay)
                    
                    print("•INFO•DayChart• Tapped at x=\(location.x), proxy returned domain value: \(tappedDayDouble)")
                    print("•INFO•DayChart• Rounded to day: \(Int(tappedDayDouble.rounded()))")
                    print("•INFO•DayChart• Closest real day: \(closestDay)")
                    
                    print("•INFO•DayChart• Tap location.x: \(location.x), view width: \(proxy.plotSize.width)")
                    print("•INFO•DayChart• Raw domain value: \(tappedDayDouble)")
                    
                    let pointsOnDay = weightData.filter {
                        gregorianCalendar.component(.day, from: $0.date) == closestDay
                    }
                    
                    if selectedDay == closestDay {
                        selectedDay = nil
                        selectedPoint = nil
                        return
                    }
                    
                    guard !pointsOnDay.isEmpty else {
                        selectedDay = nil
                        selectedPoint = nil
                        return
                    }
                    
                    if let tappedWeight: Double = proxy.value(atY: location.y),
                       let closestPoint = pointsOnDay.min(by: { abs($0.weight - tappedWeight) < abs($1.weight - tappedWeight) }) {
                        selectedPoint = closestPoint
                    } else {
                        selectedPoint = pointsOnDay.first(where: { $0.type == .am }) ?? pointsOnDay.first
                    }
                    
                    selectedDay = closestDay
                }
        }
        .padding(.horizontal, layoutDirection == .rightToLeft ? 20 : 10)
        .padding(.top)
        //.frame(maxWidth: .infinity, height: 310)
        //.background(Color.clear)
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 310)
            } else if weightData.isEmpty {
                Text("historyRecordWeight_NoWeightYet")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, minHeight: 310)
            } else {
                VStack(spacing: 12) {
                    dayWeightChart
                        .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal)
                }
            }
        }
            .task(id: selectedMonth) {
                await loadWeightData()
            }
       
            .task(id: viewModel.trackers.count) {
                await loadWeightData()
                print("DayChart• Refreshed from trackers update: \(weightData.count) points")
            
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
                print("•INFO•DayChart• Added AM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
            }
            if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
                let weight = unitType == .metric ? pmWeight : await UnitsUtility.regionalWeight(fromKg: pmWeight, toUnits: .imperial, toDecimalDigits: 1).flatMap { Double($0) } ?? (pmWeight * 2.20462)
                dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .pm))
                print("•INFO•DayChart• Added PM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
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
        let monthDayCount = displayCalendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 31
        return 1...(monthDayCount + 2)
    }
    
    @MainActor
    private func loadWeightData() async {
        isLoading = true
        // Must be on MainActor
        weightData = await computeWeightData()
        isLoading = false     // Must be on MainActor
        print("DayChart• Loaded \(weightData.count) points for \(selectedMonth.datestampSid)")
    }
    
    private func valueSelectionPopover(for point: WeightDataPoint) -> some View {
        VStack(spacing: 4) {
            Text(point.date.dateStringLocalized(for: .short))
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                if point.type == .am {
                    Circle()
                        .stroke(Color("nfYellowSunglow"), lineWidth: 2)
                        .frame(width: 10, height: 10)
                } else {
                    Rectangle()
                        .stroke(Color("nfRedFlamePea"), lineWidth: 2)
                        .frame(width: 10, height: 10)
                }
                
                Text("\(point.weight, specifier: "%.1f") \(unitString)")
                    .font(.headline)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.85))
        .foregroundColor(.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: 140)
        .fixedSize(horizontal: true, vertical: true)
    }
}
