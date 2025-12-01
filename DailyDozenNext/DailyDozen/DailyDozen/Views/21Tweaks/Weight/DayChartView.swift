//
//  DayChartView.swift
//  DailyDozen
//
//
import SwiftUI
import Charts

//TBDz 20250916 Temp Forceunwrap sqlDataWeightRecord
// Day Chart View
struct DayChartView: View {
    let selectedMonth: Date
  //  private let db = SqliteDatabaseActor() // Add as property
    @Environment(\.layoutDirection) private var layoutDirection // Detect RTL or LTR
    @State private var weightData: [WeightDataPoint] = []
    private var isLoading: Bool = false
    @EnvironmentObject private var viewModel: SqlDailyTrackerViewModel
    
    private var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar
    }
    
    private var displayCalendar: Calendar {
        // Use user’s calendar for display (supports Persian calendar)
        var calendar = Calendar.current
        calendar.locale = Locale.current // Localized numerals and names
        return calendar
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 1 // For weights
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    private var dayNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0 // No decimals for days
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    private var displayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current // User’s calendar for display
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d" // e.g., "Aug 5" or "مرداد ۵"
        return formatter
    }
    
    //Brute force to test Persian
    //    private var displayFormatter: DateFormatter {
    //        let formatter = DateFormatter()
    //        formatter.calendar = Calendar(identifier: .persian) // Force Persian for testing
    //        formatter.locale = Locale(identifier: "fa")
    //        formatter.dateFormat = "MMMM yyyy"
    //        return formatter
    //    }
    
    init(selectedMonth: Date) {
            self.selectedMonth = selectedMonth
        }
    
//    @MainActor
//       private func loadWeightData(for month: Date) async {
//           isLoading = true
//           let newData = await fetchWeightData(for: month)
//           weightData = newData
//           isLoading = false
//       }
    
    var body: some View {
        VStack {
        //let weightData = fetchWeightData(for: selectedMonth)
        //TBDz In case it isn't already there
        
        // Debug data points
        //let _ = print("Weight Data Points for \(monthYearFormatter.string(from: selectedMonth)): \(weightData.map { "\($0.date.datestampSid) \($0.type.rawValue) \($0.weight)" })")
        //let amPoints = weightData.filter { $0.type == .am }
        // let pmPoints = weightData.filter { $0.type == .pm }
        // let _ = print("AM Points: \(amPoints.map { "\($0.date.datestampSid) \($0.weight)" })")
        // let _ = print("PM Points: \(pmPoints.map { "\($0.date.datestampSid) \($0.weight)" })")
        
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 250)
                } else if weightData.isEmpty {
                    Text("No weight data for this month")
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
                                        //                            AxisValueLabel {
                                        //                                Text("\(day)")
                                        //                            }
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
                                                .font(layoutDirection == .rightToLeft ? .caption2 : .caption) // Smaller font for Persian
                                                .padding(layoutDirection == .rightToLeft ? .trailing : .leading, 20) // Increased padding for RTL
                                            
                                        }
                                        AxisGridLine()
                                        AxisTick()
                                    }
                                }
                            }
                            .chartYScale(domain: computeYDomain(for: weightData))
                            .chartLegend(.hidden)
                            .padding(.horizontal, layoutDirection == .rightToLeft ? 20 : 10) // Extra horizontal padding for RTL
                            .padding(.top)
                            //.frame(height: 250)
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
            
         // fetchWeightData(for: selectedMonth)
            fetchWeightData()
        }
//        .onAppear {
//            Task { @MainActor in
//                isLoading = true
//                weightData = await fetchWeightData(for: selectedMonth)
//                isLoading = false
//            }
//        }
//        .onChange(of: selectedMonth) { _ in
//            Task { @MainActor in
//                isLoading = true
//                weightData = await fetchWeightData(for: selectedMonth)
//                isLoading = false
//                print("🟢 •Chart• Selected month changed to: \(selectedMonth.datestampSid)")
//            }
//        }
//        .onReceive(WeightEntryViewModel.mockDBTrigger) { _ in
//            Task { @MainActor in
//                isLoading = true
//                weightData = await fetchWeightData(for: selectedMonth)
//                isLoading = false
//                print("🟢 •Chart• DB updated via notification, refreshing DayChartView")
//            }
//        }
    }
    
    private func fetchWeightData() {
        Task { @MainActor in
            let trackers = await viewModel.fetchTrackers(forMonth: selectedMonth)
            var dataPoints: [WeightDataPoint] = []
            for tracker in trackers {
                if let amWeight = tracker.weightAM?.dataweight_kg, amWeight > 0 {
                    dataPoints.append(WeightDataPoint(date: tracker.date, weight: amWeight, type: .am))
                    print("🟢 •Chart• Added AM weight for \(tracker.date.datestampSid): \(amWeight) kg")
                }
                if let pmWeight = tracker.weightPM?.dataweight_kg, pmWeight > 0 {
                    dataPoints.append(WeightDataPoint(date: tracker.date, weight: pmWeight, type: .pm))
                    print("🟢 •Chart• Added PM weight for \(tracker.date.datestampSid): \(pmWeight) kg")
                }
            }
            DispatchQueue.main.async {
                weightData = dataPoints
                print("🟢 •Chart• Created \(dataPoints.count)" )
            }
        }
    }
    
//    private func fetchWeightData(for month: Date) async -> [WeightDataPoint] {
//        print("🟢 •Chart• Fetching weight data for month: \(month.datestampSid)")
//        let unitType = UnitType.fromUserDefaults()
//        let trackers = await trackerViewModel.fetchTrackers(forMonth: month)
//        print("🟢 •Chart• Found \(trackers.count) trackers for \(displayFormatter.string(from: month)): \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg (\($0.weightAM != nil ? UnitsUtility.regionalWeight(fromKg: $0.weightAM!.dataweight_kg, toUnits: .imperial, toDecimalDigits: 1) ?? "0" : "0") lbs), PM=\($0.weightPM?.dataweight_kg ?? 0) kg (\($0.weightPM != nil ? UnitsUtility.regionalWeight(fromKg: $0.weightPM!.dataweight_kg, toUnits: .imperial, toDecimalDigits: 1) ?? "0" : "0") lbs)" })")
//        
//        var weightData: [WeightDataPoint] = []
//        
//        for tracker in trackers.sorted(by: { $0.date < $1.date }) {
//            if let weightAM = tracker.weightAM, weightAM.dataweight_kg > 0 {
//                let weight = unitType == .metric ? weightAM.dataweight_kg : UnitsUtility.regionalWeight(fromKg: weightAM.dataweight_kg, toUnits: .imperial, toDecimalDigits: 1).flatMap { Double($0) } ?? (weightAM.dataweight_kg * 2.20462)
//                weightData.append(WeightDataPoint(
//                    date: tracker.date,
//                    weight: weight,
//                    type: .am
//                ))
//            }
//            
//            if let weightPM = tracker.weightPM, weightPM.dataweight_kg > 0 {
//                let weight = unitType == .metric ? weightPM.dataweight_kg : UnitsUtility.regionalWeight(fromKg: weightPM.dataweight_kg, toUnits: .imperial, toDecimalDigits: 1).flatMap { Double($0) } ?? (weightPM.dataweight_kg * 2.20462)
//                weightData.append(WeightDataPoint(
//                    date: tracker.date,
//                    weight: weight,
//                    type: .pm
//                ))
//            }
//        }
//        
//        print("🟢 •Chart• Created \(weightData.count) data points: \(weightData.map { "\($0.date.datestampSid): \($0.weight) \(unitType == .metric ? "kg" : "lbs") (\($0.type.rawValue))" })")
//        return weightData
//    }
    
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
        // Start at 5, increment by 5 (5, 10, 15, etc.)
        return stride(from: 5, through: monthDayCount, by: 5).map { $0 }
    }
    
    private func xAxisDomain(for dataPoints: [WeightDataPoint]) -> ClosedRange<Int> {
        // Use displayCalendar for month day count to support Persian calendar
        let monthDayCount = displayCalendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30
        return 1...monthDayCount
    }
    
    private func xAxisDomainWAS(for dataPoints: [WeightDataPoint]) -> ClosedRange<Int> {
        let days = dataDays(dataPoints)
        let monthDayCount = gregorianCalendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30
        
        guard let minDay = days.min(), let maxDay = days.max() else {
            return 1...monthDayCount
        }
        // Add padding to the domain for better visualization
        let lowerBound = max(1, minDay - 1)
        let upperBound = min(monthDayCount, maxDay + 1)
        return lowerBound...upperBound
    }
}
