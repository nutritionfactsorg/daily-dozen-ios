//
//  CalendarExt.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
import Foundation
import SwiftUI
import Charts
// Calendar extensions
extension Calendar {
    func startOfMonth(for inputDate: Date) -> Date {
            let components = dateComponents([.year, .month], from: inputDate)
            guard let startDate = date(from: components) else {
                fatalError("Failed to compute start of month for \(inputDate)")
            }
            return startDate
        }
    
    func endOfMonth(for inputDate: Date) -> Date {
            guard let endDate = date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth(for: inputDate)) else {
                fatalError("Failed to compute end of month for \(inputDate)")
            }
            return endDate
        }
    
    func startOfYear(for inputDate: Date) -> Date {
            let components = dateComponents([.year], from: inputDate)
            guard let startDate = date(from: components) else {
                fatalError("Failed to compute start of year for \(inputDate)")
            }
            return startDate
        }
    
    func isDate(_ date1: Date, inSameMonthAs date2: Date) -> Bool {
        let components1 = dateComponents([.year, .month], from: date1)
        let components2 = dateComponents([.year, .month], from: date2)
        return components1 == components2
    }
    
    func isDate(_ date1: Date, inSameYearAs date2: Date) -> Bool {
        let components1 = dateComponents([.year], from: date1)
        let components2 = dateComponents([.year], from: date2)
        return components1 == components2
    }
    
}

// Helper to generate axis mark values
extension ClosedRange where Bound == Date {
    func toArray(using calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var current = lowerBound
        while current <= upperBound {
            dates.append(current)
            current = calendar.date(byAdding: .year, value: 1, to: current) ?? current
        }
        return dates
    }
}
