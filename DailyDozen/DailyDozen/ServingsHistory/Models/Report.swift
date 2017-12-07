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

    init(doze: Doze) {
        var statesCount = 0
        for item in doze.items {
            let selectedStates = item.states.filter { $0 }
            statesCount += selectedStates.count
        }
        self.statesCount = statesCount
        date = doze.date
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

    init(_ results: [Doze]) {
        let dailyReports = results.map { DailyReport(doze: $0) }
        var monthReports = [MonthReport]()

        guard var date = dailyReports.first?.date else { return }
        var month = date.monthName

        var reportsInMonth = [DailyReport]()

        dailyReports.forEach { report in
            if report.date.isInCurrentMonthWith(date) {
                reportsInMonth.append(report)
                month = report.date.monthName
            } else {
                let monthReport = MonthReport(daily: reportsInMonth, month: month)
                monthReports.append(monthReport)
                reportsInMonth.removeAll()
                reportsInMonth.append(report)
                date = report.date
            }
        }
        monthReports.append(MonthReport(daily: reportsInMonth, month: month))

        let yearlyReport = YearlyReport(months: monthReports, year: 2017)
        data.append(yearlyReport)
    }

    func yearlyReport(for index: Int) -> YearlyReport {
        return data[index]
    }
}
