//
//  WeightChartView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import Charts

// Enum for chart time periods
enum ChartPeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case month = "Month"
    case year = "Year"
    
    var id: String { rawValue }
}

// Data point for chart
struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let type: DataWeightType // AM or PM
}

struct WeightChartView: View {
    @State private var selectedPeriod: ChartPeriod = .day
    @State private var selectedMonth: Date = Date().startOfMonth
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    private var monthsWithData: [Date] {
        let calendar = Calendar.current
        let validTrackers = mockDB.filter { $0.weightAM.dataweight_kg > 0 || $0.weightPM.dataweight_kg > 0 }
        let months = Set(validTrackers.map { calendar.startOfMonth(for: $0.date) })
        return months.sorted()
    }
    
    private var monthsInSelectedYear: [Date] {
        let calendar = Calendar.current
        return monthsWithData.filter { calendar.component(.year, from: $0) == selectedYear }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Period toggle
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(ChartPeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .disabled(selectedPeriod != .day)
                
                // Chevron navigation for month
                if selectedPeriod == .day {
                    HStack {
                        Button(action: {
                            if let earliest = monthsInSelectedYear.first {
                                selectedMonth = earliest
                            }
                        }, label: {
                            Image(systemName: "chevron.left.2")
                                .foregroundColor(monthsInSelectedYear.isEmpty ? .gray : .brandGreen)
                        }
                        )
                        .disabled(monthsInSelectedYear.isEmpty)
                        
                        Button(
                            action: {
                                if let currentIndex = monthsInSelectedYear.firstIndex(of: selectedMonth),
                                   currentIndex > 0 {
                                    selectedMonth = monthsInSelectedYear[currentIndex - 1]
                                } else if let previousYear = monthsWithData
                                    .filter({ Calendar.current.component(.year, from: $0) < selectedYear })
                                    .max() {
                                    selectedYear = Calendar.current.component(.year, from: previousYear)
                                    selectedMonth = monthsInSelectedYear.last ?? previousYear
                                }
                            },
                            label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(monthsWithData.isEmpty ? .gray : .brandGreen)
                            }
                        )
                        .disabled(monthsWithData.isEmpty)
                        
                        Text("\(selectedMonth, formatter: monthYearFormatter)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        
                        Button(
                            action: {
                                if let currentIndex = monthsInSelectedYear.firstIndex(of: selectedMonth),
                                   currentIndex < monthsInSelectedYear.count - 1 {
                                    selectedMonth = monthsInSelectedYear[currentIndex + 1]
                                } else if let nextYear = monthsWithData
                                    .filter({ Calendar.current.component(.year, from: $0) > selectedYear })
                                    .min() {
                                    selectedYear = Calendar.current.component(.year, from: nextYear)
                                    selectedMonth = monthsInSelectedYear.first ?? nextYear
                                }
                            },
                            label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(selectedMonth >= Date().startOfMonth || monthsWithData.isEmpty ? .gray : .brandGreen)
                            }
                        )
                        .disabled(selectedMonth >= Date().startOfMonth || monthsWithData.isEmpty)
                        
                        Button(action: {
                            if let latest = monthsInSelectedYear.last {
                                selectedMonth = latest
                            }
                        }, label: {
                            Image(systemName: "chevron.right.2")
                                .foregroundColor(monthsInSelectedYear.isEmpty || selectedMonth >= Date().startOfMonth ? .gray : .brandGreen)
                        }
                        )
                        .disabled(monthsInSelectedYear.isEmpty || selectedMonth >= Date().startOfMonth)
                    }
                    .padding(.horizontal)
                }
                
                // Chart
                if selectedPeriod == .day {
                    DayChartView(selectedMonth: selectedMonth)
                } else {
                    Text("Chart type not implemented yet")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Edit Data button
                NavigationLink(destination: WeightEntryView()) {
                    Text("Edit Data")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Weight Charts")
        }
        .onAppear {
            if !monthsWithData.contains(selectedMonth), let latest = monthsWithData.last {
                selectedMonth = latest
                selectedYear = Calendar.current.component(.year, from: latest)
            }
        }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

// Day Chart View
struct DayChartView: View {
    let selectedMonth: Date
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
    
    var body: some View {
        let weightData = fetchWeightData(for: selectedMonth)
        
        // Debug data points
        //let _ = print("Weight Data Points for \(monthYearFormatter.string(from: selectedMonth)): \(weightData.map { "\($0.date.datestampSid) \($0.type.rawValue) \($0.weight)" })")
        //let amPoints = weightData.filter { $0.type == .am }
       // let pmPoints = weightData.filter { $0.type == .pm }
       // let _ = print("AM Points: \(amPoints.map { "\($0.date.datestampSid) \($0.weight)" })")
       // let _ = print("PM Points: \(pmPoints.map { "\($0.date.datestampSid) \($0.weight)" })")
        
        if weightData.isEmpty {
            Text("No weight data for this month")
                .foregroundStyle(.gray)
                .frame(height: 250)
        } else {
            VStack(spacing: 12) {
                Chart(weightData) { dataPoint in
                    LineMark(
                        x: .value("Day", Calendar.current.component(.day, from: dataPoint.date)),
                        y: .value("Weight", dataPoint.weight),
                        series: .value("Series", dataPoint.type == .am ? "AM" : "PM")
                    )
                    .foregroundStyle(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
                    .symbol(by: .value("Series", dataPoint.type == .am ? "AM" : "PM"))
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
                    AxisMarks(values: dataDays(weightData)) { value in
                        if let day = value.as(Int.self) {
                            AxisValueLabel {
                                Text("\(day)")
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
                                Text("\(weight, specifier: "%.1f")")
                            }
                            AxisGridLine()
                            AxisTick()
                        }
                    }
                }
                .chartYScale(domain: computeYDomain(for: weightData))
                .chartLegend(.hidden)
                .padding(.horizontal)
                .padding(.top)
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
    
    private func fetchWeightData(for month: Date) -> [WeightDataPoint] {
        let calendar = Calendar.current
        let unitType = UnitType.fromUserDefaults()
        
        guard let monthRange = calendar.range(of: .day, in: .month, for: month),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else {
            print("Failed to compute month range or start for \(monthYearFormatter.string(from: month))")
            return []
        }
        
        let trackers = mockDB.filter { tracker in
            calendar.isDate(tracker.date, equalTo: monthStart, toGranularity: .month)
        }
        
        print("Found \(trackers.count) trackers for \(monthYearFormatter.string(from: month))")
        
        var dataPoints: [WeightDataPoint] = []
        
        for tracker in trackers {
            if tracker.weightAM.dataweight_kg > 0 {
                let weight = unitType == .metric ? tracker.weightAM.dataweight_kg : tracker.weightAM.lbs
                dataPoints.append(WeightDataPoint(
                    date: tracker.date,
                    weight: weight,
                    type: .am
                ))
            }
            
            if tracker.weightPM.dataweight_kg > 0 {
                let weight = unitType == .metric ? tracker.weightPM.dataweight_kg : tracker.weightPM.lbs
                dataPoints.append(WeightDataPoint(
                    date: tracker.date,
                    weight: weight,
                    type: .pm
                ))
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
        let calendar = Calendar.current
        let days = Set(dataPoints.map { calendar.component(.day, from: $0.date) })
        return Array(days).sorted()
    }
    
    private func xAxisDomain(for dataPoints: [WeightDataPoint]) -> ClosedRange<Int> {
        let days = dataDays(dataPoints)
        guard let minDay = days.min(), let maxDay = days.max() else {
            return 1...30
        }
        // Add padding to the domain for better visualization
        let lowerBound = max(1, minDay - 1)
        let upperBound = min(30, maxDay + 1)
        return lowerBound...upperBound
    }
}

#Preview {
    WeightChartView()
}
