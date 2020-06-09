//
//  WeightHistoryViewModel.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct WeightHistoryViewModel {

    // MARK: - Properties
    private let report: WeightReport

    var lastYearIndex: Int {
        return report.data.count - 1
    }

    // MARK: - Inits
    init(amRecords: [DataWeightRecord], pmRecords: [DataWeightRecord]) {
        report = WeightReport(amRecords: amRecords, pmRecords: pmRecords)
        LogService.shared.verbose(
            "WeightHistoryViewModel init report:\n\(report.toString())"
        )
    }

    // MARK: - Methods
    func lastMonthIndex(for yearIndex: Int) -> Int {
        return report.yearlyWeightReport(for: yearIndex).months.count - 1
    }

    func monthData(yearIndex: Int, monthIndex: Int) -> (month: String, points: [DailyWeightReport]) {
        let monthReport: MonthWeightReport = report
            .yearlyWeightReport(for: yearIndex)
            .monthWeightReport(for: monthIndex)

        let month = monthReport.month
        
        return (month, monthReport.daily)
    }

    func yearlyData(yearIndex: Int) -> (year: String, points: [DailyWeightReport]) {
        let yearlyReport = report.yearlyWeightReport(for: yearIndex)
        let year = String(yearlyReport.year)
        
        var points = [DailyWeightReport]()
        for monthWeightReport in yearlyReport.months {
            points.append(contentsOf: monthWeightReport.daily)
        }
        return (year, points)
    }

    func fullDataMap() -> [DailyWeightReport] {
        
        var allDataPoints = [DailyWeightReport]()
        for yearlyWeightReport in report.data {
            for monthWeightReport in yearlyWeightReport.months {
                allDataPoints.append(contentsOf: monthWeightReport.daily)
            }
        }
        
        return allDataPoints
    }

    func yearName(yearIndex: Int) -> String {
        return String(report.yearlyWeightReport(for: yearIndex).year)
    }

    func datesLabels(yearIndex: Int, monthIndex: Int) -> [String] {
        var labels = [String]()
        for day in report
            .yearlyWeightReport(for: yearIndex)
            .monthWeightReport(for: monthIndex)
            .daily {
                labels.append("\(day.anyDate.day)")
        }
        return labels
    }

    func monthsLabels(yearIndex: Int) -> [String] {
        return report
            .yearlyWeightReport(for: yearIndex)
            .months
            .map { $0.month }
    }

    func fullDataLabels() -> [String] {
        return report
            .data
            .map { String($0.year) }
    }
}
