//
//  DateUtilities.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct DateUtilities {
    
    static let gregorianCalendar = Calendar(identifier: .gregorian)
        
        // Optional: Add related helpers here, e.g.,
        static func startOfDay(for date: Date) -> Date {
            gregorianCalendar.startOfDay(for: date)
        }
        
        static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
            gregorianCalendar.isDate(date1, inSameDayAs: date2)
        }
}
