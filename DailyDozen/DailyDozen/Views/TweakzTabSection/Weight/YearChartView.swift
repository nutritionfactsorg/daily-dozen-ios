//
//  YearChartView.swift
//  DailyDozen
//
// swiftlint:disable file_length
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length

import SwiftUI
import Charts

struct YearChartView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var selectedDay: Int?
    @State private var selectedPoint: WeightDataPoint?
    @State private var scrollPosition: Double = 0
    @State private var computedChartData: [WeightDataPoint] = []
    @State private var isChartReady = false
    @State private var updateTask: Task<Void, Never>?
    
    private var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    private var uniqueDataDays: Set<Int> {
        Set(computedChartData.map { daysSinceEarliestDate($0.date) })
    }
    
    private func findClosestDay(to day: Int) -> Int {
        guard !uniqueDataDays.isEmpty else { return day }
        return uniqueDataDays.min(by: { abs($0 - day) < abs($1 - day) }) ?? day
    }
    
    private func computeChartData(from trackers: [SqlDailyTracker], scrollPosition: Double) -> [WeightDataPoint] {
        let unitType = UnitType.fromUserDefaults()
        guard !trackers.isEmpty else { return [] }
        
        let earliestDate = trackers.map { $0.date }.min()!
        let scrollDay = Int(scrollPosition)
        let windowDays = 220   // adjust for responsiveness
        let startDay = max(1, scrollDay - windowDays)
        let endDay = scrollDay + windowDays
        
        let startDate = gregorianCalendar.date(byAdding: .day, value: startDay - 1, to: earliestDate)!
        let endDate = gregorianCalendar.date(byAdding: .day, value: endDay - 1, to: earliestDate)!
        
        let dataPoints = trackers
            .filter { $0.date >= startDate && $0.date <= endDate }
            .filter { ($0.weightAM?.dataweight_kg ?? 0) > 0 || ($0.weightPM?.dataweight_kg ?? 0) > 0 }
            .flatMap { tracker -> [WeightDataPoint] in
                var points: [WeightDataPoint] = []
                if let amWeight = tracker.weightAM?.dataweight_kg, amWeight > 0 {
                    let weight = unitType == .metric ? amWeight : tracker.weightAM!.lbs
                    points.append(WeightDataPoint(date: tracker.date, weight: weight, type: .am))
                }
                if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
                    let weight = unitType == .metric ? pmWeight : tracker.weightPM!.lbs
                    points.append(WeightDataPoint(date: tracker.date, weight: weight, type: .pm))
                }
                return points
            }
            .sorted { $0.date < $1.date }
        
        return dataPoints
    }
    
    private var unitString: String {
        UnitType.fromUserDefaults() == .metric ? "kg" : "lbs"
    }
    
    @MainActor
    private func updateChartData() {
        computedChartData = computeChartData(from: viewModel.trackers, scrollPosition: scrollPosition)
    }
    
    private func scrollToEnd() {
        if !computedChartData.isEmpty {
            let lastDay = xAxisDomain().upperBound
            withAnimation(.easeInOut) {
                scrollPosition = Double(lastDay)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                if !isChartReady {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                } else if computedChartData.isEmpty {
                    Text("historyRecordWeight_NoWeightAvailable")
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                } else {
                    chartView(geometry: geometry)
                        .frame(height: 310)
                    
                    legendView
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 350)
            .onAppear {
                Task { @MainActor in
                    updateChartData()
                    isChartReady = true
                    scrollToEnd()
                    try? await Task.sleep(for: .seconds(0.5))
                    updateChartData()
                }
            }
        }
    }
    
    private func chartView(geometry: GeometryProxy) -> some View {
        Chart {
            ForEach(computedChartData) { dataPoint in
                LineMark(
                    x: .value("Day", daysSinceEarliestDate(dataPoint.date)),
                    y: .value("Weight", dataPoint.weight),
                    series: .value("Series", dataPoint.type == .am ? "AM" : "PM")
                )
                .foregroundStyle(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .symbol(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .interpolationMethod(.catmullRom)
                .symbolSize(100)
            }
            
            if let day = selectedDay,
               let point = selectedPoint {
                RuleMark(x: .value("Day", day))
                    .foregroundStyle(.gray.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
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
                    position: point.weight > computeYDomain().upperBound * 0.8 ? .top : .bottom,
                    alignment: alignmentForPosition(selectedDay: day),
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
            let axisData = yearAndMonthMarks()
            AxisMarks(values: axisData.map { $0.day }) { value in
                if let day = value.as(Int.self),
                   let mark = axisData.first(where: { $0.day == day }) {
                    AxisValueLabel {
                        Text(mark.label)
                    }
                    AxisGridLine()
                    AxisTick()
                }
            }
        }
        .chartXScale(domain: xAxisDomain())
        .chartXVisibleDomain(length: geometry.size.width > 700 ? 220 : 180)
        .chartScrollPosition(x: $scrollPosition)
//        .onChange(of: scrollPosition) {
//            Task.detached {
//                try? await Task.sleep(for: .milliseconds(300))
//                await updateChartData()
//            }
//        }
        //TBDz is this any better?
       // This cancels pending updates during active scrolling, reducing unnecessary recomputations and UI refreshes.
        .onChange(of: scrollPosition) {
            updateTask?.cancel()
            updateTask = Task {
                try? await Task.sleep(for: .milliseconds(300))  // Adjust to 500 if needed for more debounce
                if Task.isCancelled { return }
                updateChartData()
            }
        }
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
        .chartYScale(domain: computeYDomain())
        .chartLegend(.hidden)
        .chartScrollableAxes(.horizontal)
        .chartPlotStyle { plot in
            plot
                //.padding(.horizontal, 30)  // Buffer for annotations (~half popover width + margin)
                .padding(.top, 20)
        }
        .padding(.horizontal, layoutDirection == .rightToLeft ? 30 : 20)
        .padding(.top, 0)
        .chartGesture { proxy in
                    SpatialTapGesture()
                        .onEnded { value in
                            let location = value.location

                            guard let day: Int = proxy.value(atX: location.x) else {
                                selectedDay = nil
                                selectedPoint = nil
                                return
                            }

                            let closestDay = findClosestDay(to: day)
                            let pointsOnDay = computedChartData.filter {
                                daysSinceEarliestDate($0.date) == closestDay
                            }

                            // Toggle deselect on re-tap
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

                            // Accurate Y-based AM/PM selection
                            if let tappedWeight: Double = proxy.value(atY: location.y) {
                                selectedPoint = pointsOnDay.min(by: {
                                    abs($0.weight - tappedWeight) < abs($1.weight - tappedWeight)
                                })
                            } else {
                                selectedPoint = pointsOnDay.first(where: { $0.type == .am }) ?? pointsOnDay.first
                            }

                            selectedDay = closestDay
                        }
                }
            .frame(height: 310)
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
        HStack(spacing: 24) {
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

    private func alignmentForPosition(selectedDay: Int) -> Alignment {
        let totalDays = xAxisDomain().upperBound
        let leftThreshold = Int(Double(totalDays) * 0.25)
        let rightThreshold = Int(Double(totalDays) * 0.75)

        if selectedDay < leftThreshold {
            return .trailing
        } else if selectedDay > rightThreshold {
            return .leading
        } else {
            return .center
        }
    }

    private func daysSinceEarliestDate(_ date: Date) -> Int {
        guard let earliestDate = viewModel.trackers.map({ $0.date }).min() else { return 0 }
        return gregorianCalendar.dateComponents([.day], from: earliestDate, to: date).day! + 1
    }

    private func yearAndMonthMarks() -> [(day: Int, label: String)] {
        guard !viewModel.trackers.isEmpty,
              let earliestDate = viewModel.trackers.map({ $0.date }).min(),
              let latestDate = viewModel.trackers.map({ $0.date }).max() else { return [] }

        let earliestYear = gregorianCalendar.component(.year, from: earliestDate)
        let latestYear = gregorianCalendar.component(.year, from: latestDate)

        var marks: [(day: Int, label: String)] = []
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"

        for year in earliestYear...latestYear {
            if let jan1 = gregorianCalendar.date(from: DateComponents(year: year, month: 1, day: 1)),
               let day = gregorianCalendar.dateComponents([.day], from: earliestDate, to: jan1).day {
                marks.append((day: day + 1, label: yearFormatter.string(from: jan1)))
            }

            for month in 1...12 {
                if let monthDate = gregorianCalendar.date(from: DateComponents(year: year, month: month, day: 1)),
                   monthDate <= latestDate,
                   let day = gregorianCalendar.dateComponents([.day], from: earliestDate, to: monthDate).day {
                    marks.append((day: day + 1, label: monthFormatter.string(from: monthDate)))
                }
            }
        }

        return marks.sorted { $0.day < $1.day }
    }

    private func xAxisDomain() -> ClosedRange<Int> {
        guard !viewModel.trackers.isEmpty,
              let earliestDate = viewModel.trackers.map({ $0.date }).min(),
              let latestDate = viewModel.trackers.map({ $0.date }).max() else {
            return 1...365
        }
        let dayCount = gregorianCalendar.dateComponents([.day], from: earliestDate, to: latestDate).day ?? 365
        return 1...(dayCount + 1)
    }

    private func computeYDomain() -> ClosedRange<Double> {
        guard !computedChartData.isEmpty else { return 0...100 }

        let weights = computedChartData.map { $0.weight }.sorted()
        let count = weights.count

        let lowerIndex = Int(Double(count) * 0.01)
        let upperIndex = Int(Double(count) * 0.99)

        let minWeight = weights[lowerIndex]
        let maxWeight = weights[upperIndex]

        let padding = (maxWeight - minWeight) * 0.1
        let lowerBound = max(0, minWeight - padding)
        let upperBound = maxWeight + padding

        return lowerBound...upperBound
    }
}
