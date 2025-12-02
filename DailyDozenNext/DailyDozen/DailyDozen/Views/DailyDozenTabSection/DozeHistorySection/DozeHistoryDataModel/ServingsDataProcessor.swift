//
//  ServingsDataProcessor.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation
import Charts
import SwiftUI

//enum TimeScale: String, CaseIterable, Identifiable {
//    case daily = "Daily"
//    case monthly = "Monthly"
//    case yearly = "Yearly"
//    var id: String { rawValue }
//}

enum TimeScale: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .daily:
            return String(localized: "history_scale_choice_day", comment: "Daily time scale")
        case .monthly:
            return String(localized: "history_scale_choice_month", comment: "Monthly time scale")
        case .yearly:
            return String(localized: "history_scale_choice_year", comment: "Yearly time scale")
        }
    }
}
// Chart data struct
struct ChartData: Identifiable {
    let id = UUID()
    let date: Date? // Used for daily and monthly
    let year: Int? // Used for yearly
    let totalServings: Int
    
    init(date: Date, totalServings: Int) {
        self.date = date
        self.year = nil
        self.totalServings = totalServings
    }
    
    init(year: Int, totalServings: Int) {
        self.date = nil
        self.year = year
        self.totalServings = totalServings
    }
}

@MainActor
class ServingsDataProcessor: ObservableObject {
    @Published private var trackers: [SqlDailyTracker]
    private let calendar = Calendar.current
    private let today: Date
    private let dbActor = SqliteDatabaseActor.shared
    
    init() {
       
        self.trackers = []
        self.today = calendar.startOfDay(for: Date())
        Task {
            do {
                try await dbActor.setup()
                let fetchedTrackers = await dbActor.fetchTrackers()
               
                    self.trackers = fetchedTrackers
                    print("ServingsDataProcessor updateTrackers: Tracker count: \(fetchedTrackers.count), Dates: \(fetchedTrackers.map { $0.date.datestampSid })")
                
            } catch {
                
                    print("🔴 •ServingsDataProcessor• Failed to setup database: \(error)")
                
            }
        }
    }
    
    func updateTrackers() async {
        let fetchedTrackers = await dbActor.fetchTrackers()
        await MainActor.run {
             self.trackers = fetchedTrackers
              print("ServingsDataProcessor updateTrackers: Tracker count: \(fetchedTrackers.count), Dates: \(fetchedTrackers.map { $0.date.datestampSid })")
               }
    }
    
    func dailyServings(forMonthOf date: Date) -> [ChartData] {
        let startOfMonth = calendar.startOfMonth(for: date)
        let endOfMonth = min(calendar.endOfMonth(for: date), today)
        var dailyTotals: [Date: Int] = [:]
        
        print("DailyServings: Processing month: \(date.datestampSid), Start: \(startOfMonth.datestampSid), End: \(endOfMonth.datestampSid)")
        var currentDate = startOfMonth
        while currentDate <= endOfMonth {
            dailyTotals[currentDate] = 0
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        for tracker in trackers where tracker.date <= today {
            if calendar.isDate(tracker.date, inSameMonthAs: date) {
                let total = tracker.itemsDict.values
                    .filter { $0.datacount_count > 0 }
                    .reduce(0) { sum, record in
                        print("Daily: Tracker date: \(tracker.date.datestampSid), Record: \(record.datacount_count)")
                        return sum + record.datacount_count
                    }
                let trackerDate = calendar.startOfDay(for: tracker.date)
                dailyTotals[trackerDate] = total
                print("Daily: Tracker date: \(trackerDate.datestampSid), Total: \(total)")
            }
        }
        
        let result = dailyTotals.map { ChartData(date: $0.key, totalServings: $0.value) }
            .sorted { $0.date! < $1.date! }
        print("DailyServings: Result count: \(result.count), Dates and Totals: \(result.map { ($0.date!.datestampSid, $0.totalServings) })")
        return result
    }
    
    func monthlyServings(forYearOf date: Date) -> [ChartData] {
        let selectedYear = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)
        
        if selectedYear > currentYear {
            return []
        }
        
        var monthlyTotals: [Date: Int] = [:]
        let maxMonth = selectedYear == currentYear ? currentMonth : 12
        
        for month in 1...maxMonth {
            if let monthDate = calendar.date(from: DateComponents(year: selectedYear, month: month, day: 1)) {
                monthlyTotals[monthDate] = 0
            }
        }
        
        for tracker in trackers where tracker.date <= today {
            if calendar.isDate(tracker.date, inSameYearAs: date) {
                let monthStart = calendar.startOfMonth(for: tracker.date)
                let total = tracker.itemsDict.values
                    .filter { $0.datacount_count > 0 }
                    .reduce(0) { $0 + $1.datacount_count }
                monthlyTotals[monthStart, default: 0] += total
            }
        }
        
        let theMappedMonthlyTotals = monthlyTotals.map { ChartData(date: $0.key, totalServings: $0.value) }
            .sorted { $0.date! < $1.date! }
        print("MappedMonthlyTotals: \(theMappedMonthlyTotals)")
        return theMappedMonthlyTotals
    }
    
    func yearlyServings() -> [ChartData] {
        print("YearlyServings: Today is \(today.datestampSid), Tracker count: \(trackers.count)")
        print("YearlyServings: Tracker dates: \(trackers.map { $0.date.datestampSid })")
        var yearlyTotals: [Int: Int] = [:]
        
        for tracker in trackers where tracker.date <= today {
            let year = calendar.component(.year, from: tracker.date)
            let total = tracker.itemsDict.values
                .filter { $0.datacount_count > 0 }
                .reduce(0) { sum, record in
                    print("Yearly: Tracker date: \(tracker.date.datestampSid), Record: \(record.datacount_count)")
                    return sum + record.datacount_count
                }
            yearlyTotals[year, default: 0] += total
            print("Yearly: Tracker date: \(tracker.date.datestampSid), Year: \(year), Total: \(total)")
        }
        
        print("YearlyTotals: \(yearlyTotals)")
        let result = yearlyTotals.map { ChartData(year: $0.key, totalServings: $0.value) }
            .sorted { $0.year! < $1.year! }
        print("YearlyServings: Result count: \(result.count), Years and Servings: \(result.map { ($0.year!, $0.totalServings) })")
        return result
    }
    
    func earliestDate() -> Date? {
        trackers.map { $0.date }.min()
    }
    
    func latestDate() -> Date? {
        trackers.map { $0.date }.max()
    }
}
