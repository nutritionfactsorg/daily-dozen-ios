//
//  WeightReport.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation
import RealmSwift

struct DailyWeightReport {
    var dateAM: Date?
    var datePM: Date?
    var kgAM: Double?
    var kgPM: Double?
    
    var anyDate: Date {
        if let date = dateAM {
            return date
        }
        return datePM!
    }
    
    init?(am: DataWeightRecord?, pm: DataWeightRecord?) {
        if am == nil && pm == nil { return nil }
        if let am = am, let date = am.datetime {
            dateAM = date
            kgAM = am.kg
        }
        if let pm = pm, let date = pm.datetime {
            datePM = date
            kgPM = pm.kg
        }
    }
    
    func toString() -> String {
        let str = """
        \(dateAM?.datestampKey ?? "yyyyHHdd")\t\
        \(dateAM?.datestampHHmm ?? "nil")\t\(String(format: "%.2f", kgAM ?? -0.1))\t\
        \(datePM?.datestampKey ?? "yyyyHHdd")\t\
        \(datePM?.datestampHHmm ?? "nil")\t\(String(format: "%.2f", kgPM ?? -0.1))
        """
        return str
    }
}

struct MonthWeightReport {
    var daily = [DailyWeightReport]()
    var month: String
    // var weightAverageMorningKg: Double? :NYI:
    // var weightAverageEveningKg: Double? :NYI:

    init(daily: [DailyWeightReport], month: String) {
        self.daily = daily
        self.month = month
        // weightAverageMorningKg =
        // weightAverageEveningKg =
    }
    
    func toString() -> String {
        var str = "•• MONTH:\(month) ••\n"
        for report in daily {
            str.append("\(report.toString())\n")
        }
        return str
    }
}

struct YearlyWeightReport {
    var months = [MonthWeightReport]()
    var year: Int // 2019, 2020, etc
    // var weightAverageMorningKg: Double? :NYI:
    // var weightAverageEveningKg: Double? :NYI:

    init(months: [MonthWeightReport], year: Int) {
        self.months = months
        self.year = year
        // weightAverageMorningKg =
        // weightAverageEveningKg =
    }
    
    func monthWeightReport(for index: Int) -> MonthWeightReport {
        return months[index]
    }

    func toString() -> String {
        var str = "•• YEAR:\(year) ••\n"
        for report in months {
            str.append(report.toString())
        }
        return str
    }

}

struct WeightReport {
    var data = [YearlyWeightReport]()

    // amRecords: [DataWeightRecord], pmRecords: [DataWeightRecord]
    // amRecords, pmRecords must be presorted
    // amRecords, pmRecords must both contain at least one member
    private func merge(amRecords: [DataWeightRecord], pmRecords: [DataWeightRecord]) -> [DailyWeightReport] {
        var results = [DailyWeightReport]()

        var amIndex = 0
        var pmIndex = 0
        while amIndex < amRecords.count && pmIndex < pmRecords.count {
            guard
                let datestampAM = amRecords[amIndex].pidParts?.datestamp,
                let datestampPM = pmRecords[pmIndex].pidParts?.datestamp
                else { return [] }
            if datestampAM == datestampPM {
                let recordAM = amRecords[amIndex]
                let recordPM = pmRecords[pmIndex]
                if let report = DailyWeightReport(am: recordAM, pm: recordPM) {
                    results.append(report)
                }
                amIndex += 1
                pmIndex += 1
            } else if datestampAM > datestampPM {
                let record = amRecords[amIndex]
                if let report = DailyWeightReport(am: record, pm: nil) {
                    results.append(report)
                }
                amIndex += 1
            } else {
                let record = pmRecords[pmIndex]
                if let report = DailyWeightReport(am: nil, pm: record) {
                    results.append(report)
                }
                pmIndex += 1
            }
        }
        while amIndex < amRecords.count {
            let record = amRecords[amIndex]
            if let report = DailyWeightReport(am: record, pm: nil) {
                results.append(report)
            }
            amIndex += 1
        }
        while pmIndex < pmRecords.count {
            let record = pmRecords[pmIndex]
            if let report = DailyWeightReport(am: nil, pm: record) {
                results.append(report)
            }
            pmIndex += 1
        }

        return results
    }
    
    /// weight pecords must be date sorted
    init(amRecords: [DataWeightRecord], pmRecords: [DataWeightRecord]) {
        var dailyReports = [DailyWeightReport]()
        
        // Convert am/pm into daily weight records
        if amRecords.count > 0 && pmRecords.count > 0 {
            let merged = merge(amRecords: amRecords, pmRecords: pmRecords)
            dailyReports.append(contentsOf: merged)
        } else if amRecords.count > 0 {
            for record in amRecords {
                if let report = DailyWeightReport(am: record, pm: nil) {
                    dailyReports.append(report)
                }
            }
        } else if pmRecords.count > 0 {
            for record in pmRecords {
                if let report = DailyWeightReport(am: nil, pm: record) {
                    dailyReports.append(report)
                }
            }
        }

        // Segment days into months
        var monthReports = [MonthWeightReport]()
        guard var month = dailyReports.first?.anyDate.monthNameLocalized else { return }
        
        var weightInMonth = [DailyWeightReport]()
        dailyReports.forEach { weightReport in
            if weightReport.anyDate.monthNameLocalized == month {
                weightInMonth.append(weightReport)
                month = weightReport.anyDate.monthNameLocalized
            } else {
                let monthWeightReport = MonthWeightReport(daily: weightInMonth, month: month)
                monthReports.append(monthWeightReport)
                weightInMonth.removeAll()
                weightInMonth.append(weightReport)
                month = weightReport.anyDate.monthNameLocalized
            }
        }
        monthReports.append(MonthWeightReport(daily: weightInMonth, month: month))
        
        guard var year = monthReports.first?.daily.first?.anyDate.year else {
            return
        }

        // Segment months into years
        var reportsInYear = [MonthWeightReport]()
        monthReports.forEach { weightReport in
            if weightReport.daily.first!.anyDate.year == year {
                reportsInYear.append(weightReport)
                year = weightReport.daily.first!.anyDate.year
            } else {
                let yearlyWeightReport = YearlyWeightReport(months: reportsInYear, year: year)
                data.append(yearlyWeightReport)
                reportsInYear.removeAll()
                reportsInYear.append(weightReport)
                year = weightReport.daily.first!.anyDate.year
            }
        }
        data.append(YearlyWeightReport(months: reportsInYear, year: year))
    }
    
    func yearlyWeightReport(for index: Int) -> YearlyWeightReport {
        return data[index]
    }
    
    func toString() -> String {
        var str = "••• FULL WEIGHT REPORT •••\n"
        for report in data {
            str.append(report.toString())
        }
        return str
    }
}
