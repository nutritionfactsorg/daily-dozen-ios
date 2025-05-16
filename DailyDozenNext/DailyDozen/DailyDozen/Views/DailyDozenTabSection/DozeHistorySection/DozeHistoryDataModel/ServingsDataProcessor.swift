//
//  ServingsDataProcessor.swift
//  DailyDozen
//
//  Created by mc on 4/23/25.
//

import Foundation
import Charts
import SwiftUI

// Time scale enum
enum TimeScale: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case monthly = "Monthly"
    case yearly = "Yearly"
    var id: String { rawValue }
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

class ServingsDataProcessor {
    let trackers: [SqlDailyTracker] = returnSQLDataArray()
    let calendar = Calendar.current
    let today: Date
    
    init(trackers: [SqlDailyTracker]) {
        self.today = calendar.startOfDay(for: Date())
    }
    
    func dailyServings(forMonthOf date: Date) -> [ChartData] {
            let startOfMonth = calendar.startOfMonth(for: date)
            // End at the last day of the month or today, whichever is earlier
            let endOfMonth = min(calendar.endOfMonth(for: date), today)
            var dailyTotals: [Date: Int] = [:]
            
            // Initialize days up to endOfMonth
            var currentDate = startOfMonth
            while currentDate <= endOfMonth {
                dailyTotals[currentDate] = 0
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            // Only include trackers up to today
            for tracker in trackers where tracker.date <= today {
                if calendar.isDate(tracker.date, inSameMonthAs: date) {
                    let total = tracker.itemsDict.values.reduce(0) { $0 + $1.datacount_count }
                    dailyTotals[calendar.startOfDay(for: tracker.date)] = total
                }
            }
            
            return dailyTotals.map { ChartData(date: $0.key, totalServings: $0.value) }
                .sorted { $0.date! < $1.date! }
        }
        
        func monthlyServings(forYearOf date: Date) -> [ChartData] {
            var monthlyTotals: [Date: Int] = [:]
            
            let selectedYear = calendar.component(.year, from: date)
            let currentYear = calendar.component(.year, from: today)
            let currentMonth = calendar.component(.month, from: today)
            
            // If the selected year is after the current year, return empty data
            if selectedYear > currentYear {
                return []
            }
            
            // Initialize months up to the current month if in the current year, otherwise all months
            let maxMonth = (selectedYear == currentYear) ? currentMonth : 12
            for month in 1...maxMonth {
                if let monthDate = calendar.date(from: DateComponents(year: selectedYear, month: month)) {
                    monthlyTotals[monthDate] = 0
                }
            }
            
            // Only include trackers up to today
            for tracker in trackers where tracker.date <= today {
                if calendar.isDate(tracker.date, inSameYearAs: date) {
                    let monthStart = calendar.startOfMonth(for: tracker.date)
                    let total = tracker.itemsDict.values.reduce(0) { $0 + $1.datacount_count }
                    monthlyTotals[monthStart, default: 0] += total
                }
            }
            
            return monthlyTotals.map { ChartData(date: $0.key, totalServings: $0.value) }
                .sorted { $0.date! < $1.date! }
        }
        
        func yearlyServings() -> [ChartData] {
            var yearlyTotals: [Int: Int] = [:]
            let currentYear = calendar.component(.year, from: today)
            
            // Only include trackers up to today
            for tracker in trackers where tracker.date <= today {
                let year = calendar.component(.year, from: tracker.date)
                let total = tracker.itemsDict.values.reduce(0) { $0 + $1.datacount_count }
                yearlyTotals[year, default: 0] += total
            }
            
            print("Yearly Totals: \(yearlyTotals)")
            
            return yearlyTotals.map { year, total in
                ChartData(year: year, totalServings: total)
            }.sorted { $0.year! < $1.year! }
        }
    }
