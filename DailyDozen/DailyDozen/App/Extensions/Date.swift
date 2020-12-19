//
//  Date.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 09.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

// :TDB:???: review setLocalizedDateFormatFromTemplate() use 
// let dateFormatter = DateFormatter()            
// Template string is used only to specify which date format components should be included. 
// Ordering and other text will not be preserved.
// dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")
// let dateString = dateFormatter.string(from: datePickerView.date)

extension Date {
    
    /// Return DataWeightType `.am` or `.pm` 
    var ampm: DataWeightType {
        if self.hour < 12 {
            return .am
        }
        return .pm
    }
    
    /// Return yyyyMMdd based on the current locale.
    var datestampKey: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
    
    var datestampHHmm: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    var datestampyyyyMMddHHmmss: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: self)
    }
    
    var datestampyyyyMMddHHmmssSSS: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss.SSS"
        return dateFormatter.string(from: self)
    }
    
    static func datestampNow() -> String {
        let currentTime = DateManager.currentDatetime()
        let dateFormatter = DateFormatter()
        // filename compatible format
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: currentTime)
    }
    
    init?(healthkit: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd hh:mm a"
        if let date = dateFormatter.date(from: healthkit) {
            self = date
            return
        } else {
            return nil
        }
    }
    
    init?(datestampKey: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        if let date = dateFormatter.date(from: datestampKey) {
            self = date
            return
        } else {
            return nil
        }
    }
    
    /// - parameter datastampLong: "yyyyMMdd_HHmmss.SSS" 24-hour millisecond format
    init?(datastampLong: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss.SSS"
        if let date = dateFormatter.date(from: datastampLong) {
            self = date
            return
        } else {
            return nil
        }
    }
    
    init?(y: Int, m: Int, d: Int) {
        let calendar = Calendar.current
        var dateComponents: DateComponents = DateComponents()
        dateComponents.year = y
        dateComponents.month = m
        dateComponents.day = d
        if let date = calendar.date(from: dateComponents) {
            self = date
            return
        } else {
            return nil
        }
    }
    
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
    
    var lastDayInMonth: Int {
        let month = self.month
        let year = self.year
        return Date.lastDayInMonth(month: month, year: year)
    }
    
    static func lastDayInMonth(month: Int, year: Int) -> Int {
        let cal = Calendar.current
        var comps = DateComponents(calendar: cal, year: year, month: month)
        comps.setValue(month + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        return cal.component(.day, from: date)
    }
    
    var monthNameLocalized: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
        return dateFormatter.string(from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var hour: Int {
        get {
            return Calendar.current.component(.hour, from: self)
        }
        set {
            let allowedRange = Calendar.current.range(of: .hour, in: .day, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentHour = Calendar.current.component(.hour, from: self)
            let hoursToAdd = newValue - currentHour
            if let date = Calendar.current.date(byAdding: .hour, value: hoursToAdd, to: self) {
                self = date
            }
        }
    }
    
    public var minute: Int {
        get {
            return Calendar.current.component(.minute, from: self)
        }
        set {
            let allowedRange = Calendar.current.range(of: .minute, in: .hour, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentMinutes = Calendar.current.component(.minute, from: self)
            let minutesToAdd = newValue - currentMinutes
            if let date = Calendar.current.date(byAdding: .minute, value: minutesToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// Returns a date string from the date.
    ///
    /// - Parameter style: A dateFormatter style (default is .medium).
    /// - Returns: A localized date string.
    func dateStringLocalized(for style: DateFormatter.Style = .medium) -> String {
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
    
    // :???: candidate code to be either improved or deleted
    //    var startOfDay: Date {
    //        return Calendar.current.startOfDay(for: self)
    //    }
    //
    //    var endOfDay: Date {
    //    var components = DateComponents()
    //    components.day = 1
    //    components.second = -1
    //    return Calendar.current.date(byAdding: components, to: startOfDay)!
    //    }
    
    //    var startOfMonth: Date {
    //        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
    //        return Calendar.current.date(from: components)!
    //    }
    //
    //    var endOfMonth: Date {
    //        var components = DateComponents()
    //        components.month = 1
    //        components.second = -1
    //        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    //    }
    // End of day = Start of tomorrow minus 1 second
    // End of month = Start of next month minus 1 second
    
}
