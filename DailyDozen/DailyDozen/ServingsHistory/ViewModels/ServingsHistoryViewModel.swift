//
//  ServingsHistoryViewModel.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 07.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

struct ServingsHistoryViewModel {

    // MARK: - Properties
    private let report: Report

    var lastYearIndex: Int {
        return report.data.count - 1
    }

    // MARK: - Inits
    init(_ results: Results<Doze>) {
        report = Report(Array(results))
    }

    // MARK: - Methods
    func lastMonthIndex(for yearIndex: Int) -> Int {
        return report.data[yearIndex].months.count - 1
    }

    func monthData(yearIndex: Int, monthIndex: Int) -> (month: String, map: [Int]) {
        let monthReport = report.data[yearIndex].months[monthIndex]
        let month = monthReport.month
        let map = monthReport.daily.map { $0.statesCount }
        return (month, map)
    }

    func datesLabels(yearIndex: Int, monthIndex: Int) -> [String] {
        let labels = report.data[yearIndex].months[monthIndex].daily.map { "\($0.date.day) \n \($0.date.monthName)" }
        return labels
    }
}
