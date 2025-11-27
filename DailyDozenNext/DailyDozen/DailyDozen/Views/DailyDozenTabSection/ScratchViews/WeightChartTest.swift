//
//  WeightChartTest.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import Charts

// Data model
struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let series: String //category?
}

struct MultiLineChartView: View {
    // Input data
    private let amPoints = [
        "2025-06-01 153.22129850000002",
        "2025-06-02 155.42592150000002"
    ]
    private let pmPoints = [
        "2025-06-01 154.32361",
        "2025-06-02 156.52823300000003"
    ]
    
    // Parse data into DataPoint array
    private var chartData: [DataPoint] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var points: [DataPoint] = []
        
        // Parse AM points
        for point in amPoints {
            let components = point.split(separator: " ")
            if let date = dateFormatter.date(from: String(components[0])),
               let value = Double(components[1]) {
                points.append(DataPoint(date: date, value: value, series: "AM"))
            }
        }
        
        // Parse PM points
        for point in pmPoints {
            let components = point.split(separator: " ")
            if let date = dateFormatter.date(from: String(components[0])),
               let value = Double(components[1]) {
                points.append(DataPoint(date: date, value: value, series: "PM"))
            }
        }
        
        return points
    }
    
    var body: some View {
        VStack {
            Chart(chartData) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value),
                    series: .value("Series", point.series)
                )
                .foregroundStyle(by: .value("Series", point.series))
                .symbol(by: .value("Series", point.series))
                .interpolationMethod(.catmullRom)
            }
            .chartForegroundStyleScale([
                "AM": .blue,
                "PM": .red
            ])
            .chartSymbolScale([
                "AM": Circle().strokeBorder(lineWidth: 2),
                "PM": Circle().strokeBorder(lineWidth: 2)
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                        }
                        AxisGridLine()
                        AxisTick()
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let number = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(number, specifier: "%.2f")")
                        }
                        AxisGridLine()
                        AxisTick()
                    }
                }
            }
            .chartLegend(position: .top, alignment: .center)
            .frame(height: 300)
            .padding()
        }
    }
}

// Custom square symbol for PM series


#Preview {
    MultiLineChartView()
}
      
