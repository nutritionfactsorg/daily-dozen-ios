//
//  ServingsDataProcessor.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation
import Charts
import SwiftUI

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

@MainActor enum ChartFilterType {
    case doze
    case tweak
    
    var rowTypes: [DataCountType] {
        switch self {
        case .doze: return DozeEntryViewModel.rowTypeArray.filter { $0 != .otherVitaminB12 }
        case .tweak: return TweakEntryViewModel.rowTypeArray
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
    @Published var trackers: [SqlDailyTracker]
    @Published var filteredTrackers: [SqlDailyTracker] = []
    private let calendar = Calendar.current
    private let today: Date
    private let dbActor = SqliteDatabaseActor.shared
    let filterType: ChartFilterType
    
    init(filterType: ChartFilterType) {
        self.filterType = filterType
        self.today = calendar.startOfDay(for: Date())
        _trackers = Published(wrappedValue: [])
        _filteredTrackers = Published(wrappedValue: [])
        
        Task {
            await SqlDailyTrackerViewModel.shared.preloadAllDataForServingsIfNeeded()
            
            await MainActor.run {
                self.trackers = SqlDailyTrackerViewModel.shared.trackers
                self.applyFilter()
            }
            
        }
    }
    
    @MainActor func applyFilter() {
        let allowedTypes = filterType.rowTypes
        filteredTrackers = trackers.filter { tracker in
            // TRUE if tracker has ANY allowed type with count > 0
            return allowedTypes.contains { allowedType in
                tracker.itemsDict[allowedType]?.datacount_count ?? 0 > 0
            }
        }
       // print("•TRACE•DATA• ServingsDataProcessor applyFilter() Filtered: \(trackers.count) → \(filteredTrackers.count) (\(filterType))")
    }
    
    func updateTrackers() async {
        let fetchedTrackers = await dbActor.fetchTrackers()
        await MainActor.run {
            self.trackers = fetchedTrackers
            print("ServingsDataProcessor updateTrackers: Tracker count: \(fetchedTrackers.count), Dates: \(fetchedTrackers.map { $0.date.datestampSid })")
            self.applyFilter()
        }
    }
    
    func dailyServings(forMonthOf date: Date) -> [ChartData] {
        let startOfMonth = calendar.startOfMonth(for: date)
        let endOfMonth = min(calendar.endOfMonth(for: date), today)
        var dailyTotals: [Date: Int] = [:]
        
        var currentDate = startOfMonth
        while currentDate <= endOfMonth {
            dailyTotals[currentDate] = 0
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        for tracker in trackers where tracker.date <= today {  // ALL trackers
            if calendar.isDate(tracker.date, inSameMonthAs: date) {
                let allowedTypes = filterType.rowTypes
                let total = tracker.itemsDict.filter { allowedTypes.contains($0.key) }
                    .values.filter { $0.datacount_count > 0 }
                    .reduce(0) { $0 + $1.datacount_count }
                dailyTotals[calendar.startOfDay(for: tracker.date)] = total
            }
        }
        
        return dailyTotals.map { ChartData(date: $0.key, totalServings: $0.value) }
            .sorted { $0.date! < $1.date! }
    }
    
    func monthlyServings(forYearOf date: Date) -> [ChartData] {
        let selectedYear = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: today)
       // print("•DEBUG• monthlyServings for year: \(selectedYear), currentYear: \(currentYear)")
        
        if selectedYear > currentYear {
           // print("•DEBUG• Returning empty: selectedYear > currentYear")
            return []
        }
        
        let earliestDate = earliestDate() ?? today
        let earliestYear = calendar.component(.year, from: earliestDate)
        let earliestMonth = calendar.component(.month, from: earliestDate)
       // print("•DEBUG• earliestDate: \(earliestDate), earliestYear: \(earliestYear), earliestMonth: \(earliestMonth)")
        
        let startMonth = selectedYear == earliestYear ? earliestMonth : 1
        let maxMonth = selectedYear == currentYear ? calendar.component(.month, from: today) : 12
       // print("•DEBUG• startMonth: \(startMonth), maxMonth: \(maxMonth)")
        
        var monthlyTotals: [Date: Int] = [:]
        
        for month in startMonth...maxMonth {
            if let monthDate = calendar.date(from: DateComponents(year: selectedYear, month: month, day: 1)) {
                monthlyTotals[monthDate] = 0
            }
        }
        
        for tracker in trackers where tracker.date <= today {
            if calendar.component(.year, from: tracker.date) == selectedYear {
                let allowedTypes = filterType.rowTypes
                let total = tracker.itemsDict.filter { allowedTypes.contains($0.key) }
                    .values.filter { $0.datacount_count > 0 }
                    .reduce(0) { $0 + $1.datacount_count }
                let monthStart = calendar.startOfMonth(for: tracker.date)
                monthlyTotals[monthStart, default: 0] += total
               // print("•DEBUG• Tracker date: \(tracker.date), total: \(total), monthStart: \(monthStart)")
            }
        }
        
        //TBDz if need the filter for 0 servings
        
        let result = monthlyTotals
            .map { ChartData(date: $0.key, totalServings: $0.value) }
            .filter { $0.totalServings > 0 } // Safety: remove zero servings
            .sorted { $0.date! < $1.date! }
       // print("•DEBUG• monthlyServings result: \(result.map { "Month: \(calendar.component(.month, from: $0.date!)), Servings: \($0.totalServings)" })")
        return result
    }
    
    func yearlyServings() -> [ChartData] {
        var yearlyTotals: [Int: Int] = [:]
        
        for tracker in trackers where tracker.date <= today {
            let allowedTypes = filterType.rowTypes
            let total = tracker.itemsDict.filter { allowedTypes.contains($0.key) }
                .values.filter { $0.datacount_count > 0 }
                .reduce(0) { $0 + $1.datacount_count }
            yearlyTotals[calendar.component(.year, from: tracker.date), default: 0] += total
        }
        
        return yearlyTotals.map { ChartData(year: $0.key, totalServings: $0.value) }
            .sorted { $0.year! < $1.year! }
    }
    
    func earliestDate() -> Date? {
        filteredTrackers.map { $0.date }.min()
    }
    
    func latestDate() -> Date? {
        filteredTrackers.map { $0.date }.max()
    }
    
    func refreshIfNeeded() async {
        // The data is already loaded by preloadAllDataForServingsIfNeeded()
        // So we do nothing — or optionally re-filter if needed
        applyFilter()
    }
}
