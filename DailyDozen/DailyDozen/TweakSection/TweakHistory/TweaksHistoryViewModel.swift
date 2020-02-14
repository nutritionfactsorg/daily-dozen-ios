//
//  TweaksHistoryViewModel.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

struct TweaksHistoryViewModel {

    // MARK: - Properties
    private let report: Report

    var lastYearIndex: Int {
        return report.data.count - 1
    }

    // MARK: - Inits
    init(_ trackers: [DailyTracker]) {
        report = Report(trackers, isDailyDozen: false)
    }

    // MARK: - Methods
    func lastMonthIndex(for yearIndex: Int) -> Int {
        return report.yearlyReport(for: yearIndex).months.count - 1
    }

    func monthData(yearIndex: Int, monthIndex: Int) -> (month: String, map: [Int]) {
        let monthReport = report
            .yearlyReport(for: yearIndex)
            .monthReport(for: monthIndex)

        let month = monthReport.month
        let map = monthReport.daily.map { $0.statesCount }
        return (month, map)
    }

    func yearlyData(yearIndex: Int) -> (year: String, map: [Int]) {
        let yearlyReport = report.yearlyReport(for: yearIndex)
        let year = String(yearlyReport.year)
        let map = yearlyReport.months.map { $0.statesCount }
        return (year, map)
    }

    func fullDataMap() -> [Int] {
        return report
            .data
            .map { $0.statesCount }
    }

    func yearName(yearIndex: Int) -> String {
        return String(report.yearlyReport(for: yearIndex).year)
    }

    func datesLabels(yearIndex: Int, monthIndex: Int) -> [String] {
        return report
            .yearlyReport(for: yearIndex)
            .monthReport(for: monthIndex)
            .daily
            .map { "\($0.date.day)" }
    }

    func monthsLabels(yearIndex: Int) -> [String] {
        return report
            .yearlyReport(for: yearIndex)
            .months
            .map { $0.month }
    }

    func fullDataLabels() -> [String] {
        return report
            .data
            .map { String($0.year) }
    }
}
