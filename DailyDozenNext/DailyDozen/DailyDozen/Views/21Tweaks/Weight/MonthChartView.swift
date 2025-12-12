//
//  MonthChartView.swift
//  DailyDozen
//
// Month Chart View (shows all weights for a year)
//The AM/PM tiebreaker logic is preserved by selecting the closest point based on weight when multiple points exist for the same day.   defaults to AM if multiple points exist
//
// swiftlint:disable function_body_length

import SwiftUI
import Charts

struct MonthChartView: View {
    let selectedYear: Int
    @Environment(\.layoutDirection) private var layoutDirection
    //@EnvironmentObject private var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var selectedDay: Int? // Tracks the selected day (x-value)
    @State private var weightData: [WeightDataPoint] = []

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

    var body: some View {
        GeometryReader { geometry in
           // let weightData = fetchWeightData()

            VStack(spacing: 12) {
                if weightData.isEmpty {
                    Text("No weight data for this year")
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                } else {
                    chartView(weightData: weightData, geometry: geometry)
                        .frame(height: 310)

                    legendView
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 340)
            .onAppear {
               // weightData = computeWeightData(from: viewModel.trackers, for: selectedYear)
                weightData = computeWeightData()
                print("🟢 •MonthChartView• onAppear: Initialized weightData with \(weightData.count) points for \(selectedYear)")
            }
            .onChange(of: selectedYear) { _, newYear in
                selectedDay = nil // Clear selection when year changes
                //weightData = computeWeightData(from: viewModel.trackers, for: newYear)
                weightData = computeWeightData()
                print("🟢 •MonthChartView• onChange: Updated weightData with \(weightData.count) points for \(newYear)")
            }
            .onChange(of: viewModel.trackers) { _, _ in
               //weightData = computeWeightData(from: newTrackers, for: selectedYear)
                weightData = computeWeightData()
                print("🟢 •MonthChartView• onChange: Updated weightData with \(weightData.count) points for \(selectedYear) after trackers update")
            }
            .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
                weightData = computeWeightData()
                print("🟢 •MonthChartView• onReceive: Refreshed weightData with \(weightData.count) points for \(selectedYear) after DB update")
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
                .symbol {
                        Circle()
                            .fill(dataPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"))
                            .stroke(dataPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"), lineWidth: 2)
                            .frame(width: 8, height: 8)  // Adjust size as needed for visibility
                    }
                .symbolSize(100)
                .symbol(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                .interpolationMethod(.catmullRom)
            }

            if let selectedDay = selectedDay,
               let selectedPoint = findClosestDataPoint(for: selectedDay, in: weightData) {
                RuleMark(
                    x: .value("Day", selectedDay)
                )
                .foregroundStyle(.gray.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
                .offset(yStart: -20) // Adjusted to prevent tooltip cutoff
                .zIndex(-1)

                PointMark(
                    x: .value("Day", selectedDay),
                    y: .value("Weight", selectedPoint.weight)
                )
                .foregroundStyle(selectedPoint.type == .am ? Color("yellowSunglowColor") : Color("redFlamePeaColor"))
                .symbol(Circle().strokeBorder(lineWidth: 2))
                .annotation(
                    position: .top,
                    alignment: selectedDay < 30 ? .leading : .center, // Shift left-aligned for early days (e.g., January 2)
                    spacing: 5, // Reverted to original value
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
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
        .chartXSelection(value: $selectedDay)
        .chartPlotStyle { plot in
        plot.padding(.top, 20) // Add top padding to plot area
    }
        .padding(.horizontal, layoutDirection == .rightToLeft ? 20 : 10)
        .padding(.top) // Reverted to minimal top padding
        .border(.red, width: 1) // Uncomment -- used for debugging
    }  //chartView

    private func valueSelectionPopover(for point: WeightDataPoint) -> some View {
        Text("\(point.date.dateStringLocalized(for: .short)) (\(point.timeOfDayString)): \(point.weight, specifier: "%.1f")")
            .font(.caption2)
            .padding(3)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(4)
            .offset(x: 10) // Shift right to avoid y-axis clipping
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

    private func computeWeightData() -> [WeightDataPoint] {
            let unitType = UnitType.fromUserDefaults()
            var dataPoints: [WeightDataPoint] = []
            
            for tracker in viewModel.trackers where tracker.date.year == selectedYear {
                if let amWeight = tracker.weightAM?.dataweight_kg, amWeight > 0 {
                    let weight = unitType == .metric ? amWeight : tracker.weightAM?.lbs ?? amWeight
                    dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .am))
                    print("🟢 •Month Chart• Added AM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
                }
                if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
                    let weight = unitType == .metric ? pmWeight : tracker.weightPM?.lbs ?? pmWeight
                    dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .pm))
                    print("🟢 •Month Chart• Added PM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
                }
            }
            
            print("🟢 •Chart• Created \(dataPoints.count) data points for \(selectedYear): \(dataPoints.map { "\($0.date.datestampSid), \($0.weight), \($0.type)" })")
            return dataPoints.sorted { $0.date < $1.date }
        }
//    private func fetchWeightData() {
//           Task { @MainActor in
//               let trackers = await viewModel.fetchAllTrackers()
//               let unitType = UnitType.fromUserDefaults()
//               var dataPoints: [WeightDataPoint] = []
//               
//               for tracker in trackers where tracker.date.year == selectedYear {
//                   if let amWeight = tracker.weightAM?.dataweight_kg, amWeight > 0 {
//                       let weight = unitType == .metric ? amWeight : tracker.weightAM?.lbs ?? amWeight
//                       dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .am))
//                       print("🟢 •Month Chart• Added AM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
//                   }
//                   if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
//                       let weight = unitType == .metric ? pmWeight : tracker.weightPM?.lbs ?? pmWeight
//                       dataPoints.append(WeightDataPoint(date: tracker.date, weight: weight, type: .pm))
//                       print("🟢 •Month Chart• Added PM weight for \(tracker.date.datestampSid): \(weight) \(unitType == .metric ? "kg" : "lbs")")
//                   }
//               }
//               
//                   weightData = dataPoints.sorted { $0.date < $1.date }
//                   print("🟢 •Chart• Created \(dataPoints.count) data points for \(selectedYear): \(dataPoints.map { "\($0.date.datestampSid), \($0.weight), \($0.type)" })")
//           }
//       }

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

    private func findClosestDataPoint(for selectedDay: Int, in dataPoints: [WeightDataPoint]) -> WeightDataPoint? {
        // Filter points for the selected day
        let pointsOnDay = dataPoints.filter { daysSinceYearStart($0.date) == selectedDay }
        
        guard !pointsOnDay.isEmpty else {
           // print("No points found for day \(selectedDay)")
            return nil
        }
        
        // If multiple points (AM/PM), select one (e.g., AM by default or closest to average weight)
        let selectedPoint = pointsOnDay.count > 1 ? pointsOnDay.first { $0.type == .am } ?? pointsOnDay.first! : pointsOnDay.first!
        
        print("Selected point for day \(selectedDay): \(selectedPoint.date.dateStringLocalized(for: .short)), \(selectedPoint.weight), \(selectedPoint.type == .am ? "AM" : "PM")")
        return selectedPoint
    }
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
