//
//  Date.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 09.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

extension Date {

    /// Returns a day name from the date.
    var dayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        return dateFormatter.string(from: self)
    }

    /// Returns a day int for the date.
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    /// Returns a date string from the date.
    ///
    /// - Parameter style: A dateFormatter style (default is .medium).
    /// - Returns: A date string.
    func dateString(for style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = style
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }

    /// Checks if a date is within the current date day.
    ///
    /// - Parameter date: The current date.
    /// - Returns: Bool - Is a same day.
    func isInCurrentDayWith(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }

    /// Checks if a date is within the current date month.
    ///
    /// - Parameter date: The current date.
    /// - Returns: Bool - Is a same month.
    func isInCurrentMonthWith(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }

    /// Returns a new date by adding the calendar component value.
    ///
    /// - Parameters:
    ///   - component: A component type.
    ///   - value: The calendar component value.
    /// - Returns: A new date
    func adding(_ component: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: component, value: value, to: self)
    }
}
