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
    
    /// Seconds since 1970.01.01 00:00:00 UTC
    var getCurrentBenchmarkSeconds: Double {
        return self.timeIntervalSince1970
    }
    
    /// Return `yyyyMMdd` based on the current locale.
    var datestampKey: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
    
    /// Return `yyyy-MM-dd` ISO 8601 String ID based on the current locale.
    var datestampSid: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    /// `HH:mm`
    var datestampHHmm: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    /// `yyyyMMdd_HHmmss`
    var datestampyyyyMMddHHmmss: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: self)
    }
    
    /// `yyyyMMdd_HHmmss.SSS`
    var datestampyyyyMMddHHmmssSSS: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss.SSS"
        return dateFormatter.string(from: self)
    }
    
    /// filename compatible format `yyyyMMdd_HHmmss`
    static func datestampNow() -> String {
        let currentTime = DateManager.currentDatetime()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: currentTime)
    }
    
    /// filename compatible format `yyyyMMdd-HHmmss`, hyphen for word break
    static func datestampExport() -> String {
        let currentTime = DateManager.currentDatetime()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        return dateFormatter.string(from: currentTime)
    }
    
    /// email subject format `yyyy.MM.dd HH:mm:ss`
    static func datestampExportSubject() -> String {
        let currentTime = DateManager.currentDatetime()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
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
    
    /// yyyy-MM-dd ISO 8601 String ID based on the current locale
    init?(datestampSid: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: datestampSid) {
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
    
    /// Returns a new date by adding a number of days.
    ///
    /// - Parameters:
    ///   - value: The calendar component value.
    /// - Returns: A new date
    func adding(days: Int) -> Date {
        // unwrap since Calendar.Component.day is a reliable constraint.
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
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
    
    /// duration 
    /// selectedWeekdays = [2, 4, 6] // Example - Mon, Wed, Fri
    func dateArray(
        duration: Int, /// number of days
        selectedWeekdays: [Int] = [1, 2, 3, 4, 5, 6, 7] /// week day 1=Sunday
    ) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let dateEnding = calendar.date(byAdding: .day, value: duration, to: today)!

        var matchingDates = [Date]()
        // Finding matching dates at midnight - adjust as needed
        let components = DateComponents(hour: 0, minute: 0, second: 0) // midnight
        calendar.enumerateDates(startingAfter: today, matching: components, matchingPolicy: .nextTime) { 
            (date, _, stop) in // (date: Date, strict: Bool, stop: Bool)
            if let date = date {
                if date <= dateEnding {
                    let weekDay = calendar.component(.weekday, from: date)
                    print(date, weekDay)
                    if selectedWeekdays.contains(weekDay) {
                        matchingDates.append(date)
                    }
                } else {
                    stop = true
                }
            }
        }
        return matchingDates
    }
    
}
