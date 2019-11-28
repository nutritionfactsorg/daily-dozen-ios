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

    init(tracker: DailyTracker) {
        var statesCount = 0
        for type in DailyDozenViewModel.rowTypeArray {
            if let item = tracker.itemsDict[type] {
                statesCount += item.count
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

    func monthReport(for index: Int) -> MonthReport {
        return months[index]
    }

    init(months: [MonthReport], year: Int) {
        self.months = months
        self.year = year
        statesCount = months.reduce(0) { $0 + $1.statesCount }
    }
}

struct Report {
    var data = [YearlyReport]()

    init(_ trackers: [DailyTracker]) {
        let dailyReports = trackers.map { DailyReport(tracker: $0) }
        var monthReports = [MonthReport]()

        guard var month = dailyReports.first?.date.monthName else { 
            return
        }

        var reportsInMonth = [DailyReport]()

        dailyReports.forEach { report in
            if report.date.monthName == month {
                reportsInMonth.append(report)
                month = report.date.monthName
            } else {
                let monthReport = MonthReport(daily: reportsInMonth, month: month)
                monthReports.append(monthReport)
                reportsInMonth.removeAll()
                reportsInMonth.append(report)
                month = report.date.monthName
            }
        }
        monthReports.append(MonthReport(daily: reportsInMonth, month: month))

        guard var year = monthReports.first?.daily.first?.date.year else {
            return
        }

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
