//
//  MonthChartView.swift
//  DailyDozen
//
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length

import SwiftUI
import Charts

/// Month Chart View (shows all weights for a year)
/// The AM/PM tiebreaker logic is preserved by selecting the closest point based on weight when multiple points exist for the same day.   defaults to AM if multiple points exist
struct MonthChartView: View {
    let selectedYear: Int
    @Environment(\.layoutDirection) private var layoutDirection
    //@EnvironmentObject private var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var selectedDay: Int? // Tracks the selected day (x-value)
    @State private var weightData: [WeightDataPoint] = []
    @State private var selectedPoint: WeightDataPoint?

    private var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar
    }

    private var displayCalendar: Calendar {
        var calendar = Calendar.current
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
    
    @MainActor
    private func loadYearData(for year: Int) async {
        // ALL data is already preloaded by WeightChartView — just use it
        weightData = computeWeightData()  // already filters by selectedYear
        print("MonthChartView• Used preloaded data for \(year): \(weightData.count) points")
    }
    
    private var unitString: String {
        UnitType.fromUserDefaults() == .metric ? "kg" : "lbs"
    }
    
    private var uniqueDataDays: Set<Int> {
        Set(weightData.map { daysSinceYearStart($0.date) })
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
        
        let totalDays = xAxisDomain(for: weightData).upperBound
        let leftThreshold = Int(Double(totalDays) * 0.15)
        let rightThreshold = Int(Double(totalDays) * 0.85)
//        if day < 10 { return .center }  // Add at the top of the function
//        if day > 360 { return .center }
        if day < leftThreshold {
            return .leading
        } else if day > rightThreshold {
            return .trailing
        } else {
            return .center
        }
    }

    var body: some View {
        GeometryReader { geometry in
           // let weightData = fetchWeightData()

            VStack(spacing: 12) {
                if weightData.isEmpty {
                    Text("historyRecordWeight_NoWeightYear")
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                } else {
                    chartView(weightData: weightData, geometry: geometry)
                        .frame(height: 310)

                    legendView
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 340)

            .task(id: selectedYear) {
                await loadYearData(for: selectedYear)
            }
            .task(id: viewModel.trackers.count) {
                await loadYearData(for: selectedYear)
            }
        }
    }

    private func chartView(weightData: [WeightDataPoint], geometry: GeometryProxy) -> some View {
        Chart {
            ForEach(weightData) { dataPoint in
                LineMark(
                    x: .value("Day", daysSinceYearStart(dataPoint.date)),
                    y: .value("Weight", dataPoint.weight),
                    series: .value("Series", dataPoint.type == .am ? "AM" : "PM")
                )
                .foregroundStyle(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .symbol(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .symbolSize(100)
                .interpolationMethod(.catmullRom)
            }

            if let day = selectedDay, let point = selectedPoint {
                RuleMark(x: .value("Day", day))
                    .foregroundStyle(.gray.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
                    .offset(yStart: -20) // Prevents tooltip cutoff at top
                    .zIndex(-1)

                PointMark(
                    x: .value("Day", day),
                    y: .value("Weight", point.weight)
                )
                .foregroundStyle(point.type == .am ? Color("nfYellowSunglow") : Color("nfRedFlamePea"))
                .symbolSize(150) // Large highlight
                .symbol(by: .value("Series", point.type == .am ? "AM" : "PM")) // Reuses the global symbol scale
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
            let monthData = monthStarts(weightData)
            let filteredMonthData = monthData.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
            AxisMarks(values: filteredMonthData.map { $0.day }) { value in
                if let day = value.as(Int.self),
                   let month = monthData.first(where: { $0.day == day }) {
                    AxisValueLabel {
                        Text(month.label)
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
        .chartScrollableAxes(.horizontal)
        .chartPlotStyle { plot in
            plot
                //.padding(.horizontal, 30)  // Buffer for annotations (~half popover width + margin)
                .padding(.top, 20)
        }
        .chartGesture { proxy in
            SpatialTapGesture()
                .onEnded { value in
                    let location = value.location
                    
                    guard let tappedDay: Int = proxy.value(atX: location.x) else {
                        selectedDay = nil
                        selectedPoint = nil
                        return
                    }
                    
                    let closestDay = findClosestDay(to: tappedDay)
                    let pointsOnDay = weightData.filter { daysSinceYearStart($0.date) == closestDay }
                    
                    // Deselect on re-tap
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
                    
                    // Y-based selection
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
    }

    private func valueSelectionPopover(for point: WeightDataPoint) -> some View {
        VStack(spacing: 4) {
            Text(point.date.dateStringLocalized(for: .short))
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Group {
                    if point.type == .am {
                        // Morning → Yellow circle, stroked
                        Circle()
                            .stroke(Color("nfYellowSunglow"), lineWidth: 2)
                            .frame(width: 10, height: 10)
                    } else {
                        // Evening → Red rectangle, stroked
                        Rectangle()
                            .stroke(Color("nfRedFlamePea"), lineWidth: 2)
                            .frame(width: 10, height: 10)
                    }
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

    private var legendView: some View {
        HStack(spacing: 24) {  // Adjust this value to your liking: 16, 20, 24, 32, etc.
            HStack(spacing: 8) {
                Circle()
                    .stroke(Color("nfYellowSunglow"), lineWidth: 2)
                    .frame(width: 12, height: 12)
                
                Text("historyRecordWeight.legendMorning")
                    .font(.caption)
            }
            
            HStack(spacing: 8) {
                Rectangle()
                    .stroke(Color("nfRedFlamePea"), lineWidth: 2)
                    .frame(width: 12, height: 12)
                
                Text("historyRecordWeight.legendEvening")
                    .font(.caption)
            }
        }
    }

    private func computeWeightData() -> [WeightDataPoint] {
            let unitType = UnitType.fromUserDefaults()
            var dataPoints: [WeightDataPoint] = []
            
            for tracker in viewModel.trackers where tracker.date.year == selectedYear {
                if let amWeight = tracker.weightAM?.dataweight_kg, amWeight > 0 {
                    let weight = unitType == .metric ? amWeight : tracker.weightAM?.lbs ?? amWeight
                    dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .am))
                    //print("•INFO•Month Chart• Added AM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
                }
                if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
                    let weight = unitType == .metric ? pmWeight : tracker.weightPM?.lbs ?? pmWeight
                    dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .pm))
                    //print("•INFO•Month Chart• Added PM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
                }
            }
            
            //print("•INFO•Chart• Created \(dataPoints.count) data points for \(selectedYear): \(dataPoints.map { "\($0.date.datestampSid), \($0.weight), \($0.type)" })")
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
        
       // print("Y-domain for \(selectedYear): \(lowerBound)...\(upperBound), weights: \(weights)")
        return lowerBound...upperBound
    }

    private func monthStarts(_ dataPoints: [WeightDataPoint]) -> [(day: Int, label: String)] {
        var monthStartDays: [(day: Int, label: String)] = []
        let calendar = displayCalendar
        let yearStart = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1)) ?? Date()
        let monthCount = calendar.range(of: .month, in: .year, for: yearStart)?.count ?? 12
        
        for month in 1...monthCount {
            if let date = calendar.date(from: DateComponents(year: selectedYear, month: month, day: 1)),
               let day = gregorianCalendar.dateComponents([.day], from: yearStart, to: date).day.map({ $0 + 1 }) {
                let formatter = DateFormatter()
                formatter.calendar = calendar
                formatter.locale = calendar.locale
                formatter.dateFormat = "MMM"
                let label = formatter.string(from: date)
                monthStartDays.append((day: day, label: label))
            }
        }
        
        //print("Month starts for \(selectedYear): \(monthStartDays.map { "day: \($0.day), label: \($0.label)" })")
        return monthStartDays
    }

    private func xAxisDomain(for dataPoints: [WeightDataPoint]) -> ClosedRange<Int> {
        let yearStart = gregorianCalendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1)) ?? Date()
        let yearEnd = gregorianCalendar.date(from: DateComponents(year: selectedYear + 1, month: 1, day: 1)) ?? yearStart.addingTimeInterval(365 * 24 * 60 * 60)
        let dayCount = gregorianCalendar.dateComponents([.day], from: yearStart, to: yearEnd).day ?? 365
        //print("X-domain for \(selectedYear): 1...\(dayCount)")
        return 1...dayCount
    }

    private func daysSinceYearStart(_ date: Date) -> Int {
        let yearStart = gregorianCalendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1)) ?? Date()
        let dayCount = gregorianCalendar.dateComponents([.day], from: yearStart, to: date).day! + 1
//        print("Days since year start for \(date.dateStringLocalized(for: .short)): \(dayCount)")
        return dayCount
    }

//    private func findClosestDataPoint(for selectedDay: Int, in dataPoints: [WeightDataPoint]) -> WeightDataPoint? {
//        // Filter points for the selected day
//        let pointsOnDay = dataPoints.filter { daysSinceYearStart($0.date) == selectedDay }
//        
//        guard !pointsOnDay.isEmpty else {
//           // print("No points found for day \(selectedDay)")
//            return nil
//        }
//        
//        // If multiple points (AM/PM), select one (e.g., AM by default or closest to average weight)
//        let selectedPoint = pointsOnDay.count > 1 ? pointsOnDay.first { $0.type == .am } ?? pointsOnDay.first! : pointsOnDay.first!
//        
//        print("Selected point for day \(selectedDay): \(selectedPoint.date.dateStringLocalized(for: .short)), \(selectedPoint.weight), \(selectedPoint.type == .am ? "AM" : "PM")")
//        return selectedPoint
//    }
}
//TBDz not sure still used
// Extension for flipping x in RTL if needed
extension CGFloat {
    func flipped(in width: CGFloat) -> CGFloat {
        width - self
    }
}

// TBDz not localized
extension WeightDataPoint {
    var timeOfDayString: String {
        switch type {
        case .am: return "AM"
        case .pm: return "PM"
        }
    }
}
