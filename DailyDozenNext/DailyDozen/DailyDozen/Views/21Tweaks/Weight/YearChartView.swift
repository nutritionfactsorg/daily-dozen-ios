//
//  YearChartView.swift
//  DailyDozen
//
//swiftlint:disable type_body_length
// swiftlint:disable function_body_length

import SwiftUI
import Charts

//Temp TBDz 20250915 Temp Force Unwrap
//struct YearChartView: View {
//    var body: some View {
//        Text("Hello Year")
//    }
//}
struct YearChartView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @EnvironmentObject private var viewModel: SqlDailyTrackerViewModel
    @State private var selectedDay: Int?
    @State private var scrollPosition: Double = 0
   // @State private var weightData: [WeightDataPoint] = []
    @State private var trackers: [SqlDailyTracker] = []

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
    
    private var uniqueDataDays: Set<Int> {
        Set(chartData.map { daysSinceEarliestDate($0.date) })
    }
    
    private func findClosestDay(to day: Int) -> Int {
        guard !uniqueDataDays.isEmpty else { return day }
        return uniqueDataDays.min(by: { abs($0 - day) < abs($1 - day) }) ?? day
        // If multiple days are equidistant, this picks the lower one; adjust logic if needed (e.g., prefer higher).
    }
    
    private var chartData: [WeightDataPoint] {
           let unitType = UnitType.fromUserDefaults()
           let dataPoints = trackers
               .filter { ($0.weightAM?.dataweight_kg ?? 0) > 0 || ($0.weightPM?.dataweight_kg ?? 0) > 0 }
               .flatMap { tracker -> [WeightDataPoint] in
                   var points: [WeightDataPoint] = []
                   if let amWeight = tracker.weightAM?.dataweight_kg, amWeight > 0 {
                       let weight = unitType == .metric ? amWeight : tracker.weightAM!.lbs
                       points.append(WeightDataPoint(date: tracker.date, weight: weight, type: .am))
                       print("🟢 •Year Chart• Added AM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
                   }
                   if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
                       let weight = unitType == .metric ? pmWeight : tracker.weightPM!.lbs
                       points.append(WeightDataPoint(date: tracker.date, weight: weight, type: .pm))
                       print("🟢 •Year Chart• Added PM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
                   }
                   return points
               }
               .sorted { $0.date < $1.date }
           print("🟢 •Chart• Created \(dataPoints.count) data points: \(dataPoints.map { "\($0.date.datestampSid), \($0.weight), \($0.type)" })")
           return dataPoints
       }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                if chartData.isEmpty {
                    Text("No weight data available")
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                } else {
                    chartView(geometry: geometry)
                        .frame(height: 310) // Reverted
                    
                    legendView
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: 350) // Increased to match or exceed parent's minHeight: 420
            .onAppear {
                Task {
                        trackers = await viewModel.fetchAllTrackers()
                    }
            }
            .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
                        Task {
                            trackers = await viewModel.fetchAllTrackers()
                            print("🟢 •Chart• DB updated via notification, refreshed trackers")
                        }
                    }
            .onChange(of: selectedDay) { _, newValue in
                if let newDay = newValue {
                    let closestDay = findClosestDay(to: newDay)
                    selectedDay = closestDay  // This snaps; if already on a data day, it stays the same.
                    scrollPosition = Double(closestDay)
                    print("YearChartView snapped selectedDay to: \(closestDay), scroll position set to: \(scrollPosition)")
                }
            }
             .border(.green, width: 1) // Uncomment for debugging
        }
    }

    private func chartView(geometry: GeometryProxy) -> some View {
        Chart {
            ForEach(chartData) { dataPoint in
                LineMark(
                    x: .value("Day", daysSinceEarliestDate(dataPoint.date)),
                    y: .value("Weight", dataPoint.weight),
                    series: .value("Series", dataPoint.type == .am ? "AM" : "PM")
                )
                .foregroundStyle(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .symbol(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .interpolationMethod(.catmullRom)
                .symbolSize(100)
                .symbol {
                        Circle()
                            .fill(dataPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"))
                            .stroke(dataPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"), lineWidth: 2)
                            .frame(width: 8, height: 8)  // Adjust size as needed for visibility
                    }
            }

            if let selectedDay = selectedDay,
               let selectedPoint = findClosestDataPoint(for: selectedDay) {
                RuleMark(
                    x: .value("Day", selectedDay)
                )
                .foregroundStyle(.gray.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
                .offset(yStart: -20)
                .zIndex(-1)

                PointMark(
                    x: .value("Day", selectedDay),
                    y: .value("Weight", selectedPoint.weight)
                )
                .foregroundStyle(selectedPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"))
                .symbol(Circle().strokeBorder(lineWidth: 2))
                .annotation(
                    position: selectedPoint.weight > (computeYDomain().upperBound * 0.8) ? .bottom : .top,
                    alignment: alignmentForPosition(selectedDay: selectedDay),
                    spacing: 10,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .fit(to: .chart)
                    )
                ) {
                    valueSelectionPopover(for: selectedPoint)
                }
            }
        }
        .chartForegroundStyleScale([
            "AM": Color("yellowSunglowColor"),
            "PM": Color("redFlamePeaColor")
        ])
//        .chartSymbolScale([
//            "AM": Circle().strokeBorder(lineWidth: 2),
//            "PM": Circle().strokeBorder(lineWidth: 2)
//        ])
        .chartXAxis {
            let axisData = yearAndMonthMarks()
            AxisMarks(values: axisData.map { $0.day }) { value in  // Removed position: .bottom
                if let day = value.as(Int.self),
                   let mark = axisData.first(where: { $0.day == day }) {
                    AxisValueLabel(verticalSpacing: 0) {  // Added verticalSpacing: 0; adjust to positive (e.g., 4) if labels need more downward space
                        Text(mark.label)
                    }
                    AxisGridLine()
                    AxisTick()
                }
            }
        }
        .chartXScale(domain: xAxisDomain())
        .chartXVisibleDomain(length: 365)
        .chartScrollPosition(x: $scrollPosition)
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
        .chartXSelection(value: $selectedDay)
        .chartPlotStyle { plot in
            plot.padding(.top, 20) // Matched to MonthView; removed .bottom
        }
        .padding(.horizontal, layoutDirection == .rightToLeft ? 30 : 20)
        .padding(.top, 0)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear)
                    .onAppear {
                        print("YearChartView plot area size: \(proxy.plotSize.width) x \(proxy.plotSize.height)")
                        print("YearChartView container size: \(geo.size.width) x \(geo.size.height)")
                    }
            }
        }
        .frame(height: 310) // Matched to MonthView
        .border(.red, width: 1) // Keep for debugging
    }
 //ChartView

    private func valueSelectionPopover(for point: WeightDataPoint) -> some View {
        GeometryReader { _ in
            ZStack {
                Text("\(point.date.dateStringLocalized(for: .short)) (\(point.timeOfDayString)): \(point.weight, specifier: "%.1f")")
                    .font(.system(size: 9))
                    .padding(2)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .fixedSize()
                    // .border(.green, width: 1) // Uncomment for debugging
            }
            //.frame(minWidth: 50, minHeight: 15)
            //.offset(x: 10, y: -10) // Reverted
//            .onAppear {
//                let position = geo.frame(in: .global).origin
//                let isBottom = point.weight > (computeYDomain().upperBound * 0.8)
//                print("YearChartView tooltip size: \(geo.size.width) x \(geo.size.height), position: (\(position.x), \(position.y)) for point: \(point.date.dateStringLocalized(for: .short)), weight: \(point.weight), position: \(isBottom ? "bottom" : "top")")
//            }
        }
    }

    private var legendView: some View {
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

    private func alignmentForPosition(selectedDay: Int) -> Alignment {
        let totalDays = xAxisDomain().upperBound
        let leftThreshold = Int(Double(totalDays) * 0.15)  // Adjust threshold as needed (e.g., first 15%)
        let rightThreshold = Int(Double(totalDays) * 0.85)  // Last 15%
        
        if selectedDay < leftThreshold {
            return .trailing
        } else if selectedDay > rightThreshold {
            return .leading
        } else {
            return .center
        }
    }
    
    private func daysSinceEarliestDate(_ date: Date) -> Int {
        guard let earliestDate = chartData.map({ $0.date }).min() else { return 0 }
        let dayCount = gregorianCalendar.dateComponents([.day], from: earliestDate, to: date).day! + 1
        return dayCount
    }

    private func yearAndMonthMarks() -> [(day: Int, label: String)] {
        guard !chartData.isEmpty else { return [] }
        guard let earliestDate = chartData.map({ $0.date }).min(),
              let latestDate = chartData.map({ $0.date }).max() else { return [] }

        let earliestYear = gregorianCalendar.component(.year, from: earliestDate)
        let latestYear = gregorianCalendar.component(.year, from: latestDate)
        var marks: [(day: Int, label: String)] = []

        for year in earliestYear...latestYear {
            if let yearStart = gregorianCalendar.date(from: DateComponents(year: year, month: 1, day: 1)),
               let day = gregorianCalendar.dateComponents([.day], from: earliestDate, to: yearStart).day.map({ $0 + 1 }) {
                let formatter = DateFormatter()
                formatter.calendar = displayCalendar
                formatter.locale = Locale.current
                formatter.dateFormat = "yyyy"
                let label = formatter.string(from: yearStart)
                marks.append((day: day, label: label))
            }

            let monthCount = displayCalendar.range(of: .month, in: .year, for: gregorianCalendar.date(from: DateComponents(year: year, month: 1, day: 1))!)?.count ?? 12
            for month in stride(from: 3, through: monthCount, by: 3) {
                if let date = displayCalendar.date(from: DateComponents(year: year, month: month, day: 1)),
                   let day = gregorianCalendar.dateComponents([.day], from: earliestDate, to: date).day.map({ $0 + 1 }) {
                    let formatter = DateFormatter()
                    formatter.calendar = displayCalendar
                    formatter.locale = Locale.current
                    formatter.dateFormat = "MMM"
                    let label = formatter.string(from: date)
                    marks.append((day: day, label: label))
                }
            }
        }

        return marks.sorted { $0.day < $1.day }
    }

    private func xAxisDomain() -> ClosedRange<Int> {
        guard let earliestDate = chartData.map({ $0.date }).min(),
              let latestDate = chartData.map({ $0.date }).max() else {
            return 1...365
        }
        let dayCount = gregorianCalendar.dateComponents([.day], from: earliestDate, to: latestDate).day ?? 365
        return 1...(dayCount + 1)
    }

    private func computeYDomain() -> ClosedRange<Double> {
        guard !chartData.isEmpty else { return 0...100 }

        let weights = chartData.map { $0.weight }
        let minWeight = weights.min() ?? 0
        let maxWeight = weights.max() ?? 100

        let padding = (maxWeight - minWeight) * 0.1
        let lowerBound = max(0, minWeight - padding) // Removed *1.5 to match MonthView
        let upperBound = maxWeight + padding

        return lowerBound...upperBound
    }

    private func findClosestDataPoint(for selectedDay: Int) -> WeightDataPoint? {
        let pointsOnDay = chartData.filter { daysSinceEarliestDate($0.date) == selectedDay }

        guard !pointsOnDay.isEmpty else {
            return nil
        }

        let selectedPoint = pointsOnDay.count > 1 ? pointsOnDay.first { $0.type == .am } ?? pointsOnDay.first! : pointsOnDay.first!
        return selectedPoint
    }
}
