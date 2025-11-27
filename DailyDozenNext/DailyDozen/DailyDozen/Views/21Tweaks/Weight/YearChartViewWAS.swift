//
//  YearChartView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
import SwiftUI
import Charts

struct YearChartViewWAS: View {
    @Environment(\.layoutDirection) private var layoutDirection
    
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = displayCalendar
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    private struct WeightData: Identifiable {
        let id = UUID()
        let date: Date
        let weight: Double
        let type: DataWeightType
    }
    
    private var chartData: [WeightData] {
        let unitType = UnitType.fromUserDefaults()
        return mockDB
            .filter { $0.weightAM.dataweight_kg > 0 || $0.weightPM.dataweight_kg > 0 }
            .flatMap { tracker in
                var points: [WeightData] = []
                if tracker.weightAM.dataweight_kg > 0 {
                    let weight = unitType == .metric ? tracker.weightAM.dataweight_kg : tracker.weightAM.lbs
                    points.append(WeightData(date: tracker.date, weight: weight, type: .am))
                }
                if tracker.weightPM.dataweight_kg > 0 {
                    let weight = unitType == .metric ? tracker.weightPM.dataweight_kg : tracker.weightPM.lbs
                    points.append(WeightData(date: tracker.date, weight: weight, type: .pm))
                }
                return points
            }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if chartData.isEmpty {
                Text("No weight data available")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, minHeight: 250)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart(chartData) { data in
                        LineMark(
                            x: .value("Day", daysSinceEarliestDate(data.date)),
                            y: .value("Weight", data.weight),
                            series: .value("Series", data.type == .am ? "AM" : "PM")
                        )
                        .foregroundStyle(by: .value("Series", data.type == .am ? "AM" : "PM"))
                        .symbol(by: .value("Series", data.type == .am ? "AM" : "PM"))
                        .interpolationMethod(.catmullRom)
                    }
                    .chartForegroundStyleScale([
                        "AM": Color("yellowSunglowColor"),
                        "PM": Color("redFlamePeaColor")
                    ])
                    .chartSymbolScale([
                        "AM": Circle().strokeBorder(lineWidth: 2),
                        "PM": Circle().strokeBorder(lineWidth: 2)
                    ])
                    .chartXAxis {
                        let axisData = yearAndMonthMarks()
                        AxisMarks(values: axisData.map { $0.day }) { value in
                            if let day = value.as(Int.self),
                               let mark = axisData.first(where: { $0.day == day }) {
                                AxisValueLabel {
                                    Text(mark.label)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                AxisGridLine()
                                AxisTick()
                            }
                        }
                    }
                    .chartXScale(domain: xAxisDomain())
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            if let weight = value.as(Double.self) {
                                AxisValueLabel {
                                    Text(numberFormatter.string(from: NSNumber(value: weight)) ?? String(format: "%.1f", weight))
                                        .font(layoutDirection == .rightToLeft ? .caption2 : .caption)
                                        .padding(layoutDirection == .rightToLeft ? .trailing : .leading, 8)
                                }
                                AxisGridLine()
                                AxisTick()
                            }
                        }
                    }
                    .chartYScale(domain: computeYDomain())
                    .chartLegend(.hidden)
                    .padding(.horizontal, layoutDirection == .rightToLeft ? 8 : 4)
                    .padding(.top, 4)
                    .frame(minWidth: max(300, CGFloat(xAxisDomain().count) * 1.2), minHeight: 250) // Reduced multiplier
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
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func daysSinceEarliestDate(_ date: Date) -> Int {
        guard let earliestDate = chartData.map({ $0.date }).min() else { return 0 }
        return gregorianCalendar.dateComponents([.day], from: earliestDate, to: date).day! + 1
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
            for month in stride(from: 2, through: monthCount, by: 2) {
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
        let lowerBound = max(0, minWeight - padding)
        let upperBound = maxWeight + padding
        
        return lowerBound...upperBound
    }
}
