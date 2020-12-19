//
//  Report.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 01.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

struct DailyReport {
    var statesCount = 0
    var date: Date

    init(tracker: DailyTracker, isDailyDozen: Bool) {
        var statesCount = 0
        if isDailyDozen {
            for type in DozeEntryViewModel.rowTypeArray {
                if let item = tracker.itemsDict[type] {
                    statesCount += item.count
                }
            }
        } else {
            for type in TweakEntryViewModel.rowTypeArray {
                if let item = tracker.itemsDict[type] {
                    statesCount += item.count
                }
            }
        }
        self.statesCount = statesCount
        date = tracker.date
    }
}

struct MonthReport {
    var daily = [DailyReport]()
    var month: String
    var statesCount = 0

    init(daily: [DailyReport], month: String) {
        self.daily = daily
        self.month = month

        statesCount = daily.reduce(0) { $0 + $1.statesCount }
    }
}

struct YearlyReport {
    var months = [MonthReport]()
    var year: Int
    var statesCount = 0

    init(months: [MonthReport], year: Int) {
        self.months = months
        self.year = year
        statesCount = months.reduce(0) { $0 + $1.statesCount }
    }
    
    func monthReport(for index: Int) -> MonthReport {
        return months[index]
    }
}

struct Report {
    var data = [YearlyReport]()

    init(_ trackers: [DailyTracker], isDailyDozen: Bool) {
        let dailyReports = trackers.map { DailyReport(tracker: $0, isDailyDozen: isDailyDozen) }
        var monthReports = [MonthReport]()

        guard var month = dailyReports.first?.date.monthNameLocalized else { 
            return
        }

        // Segment days into months
        var reportsInMonth = [DailyReport]()
        dailyReports.forEach { report in
            if report.date.monthNameLocalized == month {
                reportsInMonth.append(report)
                month = report.date.monthNameLocalized
            } else {
                let monthReport = MonthReport(daily: reportsInMonth, month: month)
                monthReports.append(monthReport)
                reportsInMonth.removeAll()
                reportsInMonth.append(report)
                month = report.date.monthNameLocalized
            }
        }
        monthReports.append(MonthReport(daily: reportsInMonth, month: month))

        guard var year = monthReports.first?.daily.first?.date.year else {
            return
        }

        // Segment months into years
        var reportsInYear = [MonthReport]()
        monthReports.forEach { report in
            if report.daily.first!.date.year == year {
                reportsInYear.append(report)
                year = report.daily.first!.date.year
            } else {
                let yearlyReport = YearlyReport(months: reportsInYear, year: year)
                data.append(yearlyReport)
                reportsInYear.removeAll()
                reportsInYear.append(report)
                year = report.daily.first!.date.year
            }
        }
        data.append(YearlyReport(months: reportsInYear, year: year))
    }

    func yearlyReport(for index: Int) -> YearlyReport {
        return data[index]
    }
}
