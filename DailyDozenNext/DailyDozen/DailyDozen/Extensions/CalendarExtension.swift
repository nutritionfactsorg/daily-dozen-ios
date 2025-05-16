//
//  CalendarExt.swift
//  DailyDozen
//
//  Created by mc on 4/23/25.
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
