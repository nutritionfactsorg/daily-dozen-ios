//
//  Date.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import Foundation

extension Date {
    
    /// Seconds since 1970.01.01 00:00:00 UTC
    var getCurrentBenchmarkSeconds: Double {
        return self.timeIntervalSince1970
    }
    
    /// Return `yyyyMMdd` in English.
    var datestampKey: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.string(from: self)
    }
    
    /// Return `yyyy-MM-dd` ISO 8601 in English.
    var datestampSid: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.string(from: self)
    }
    
    /// `HH:mm`
    var datestampHHmm: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en") //added
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
    static func datestampNow() async -> String {
        let currentTime = await DateManager.shared.currentDatetime()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: currentTime)
    }
    
    /// filename compatible format `yyyyMMdd-HHmmss`, hyphen for word break
    static func datestampExport() async -> String {
        let currentTime = await DateManager.shared.currentDatetime()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        return dateFormatter.string(from: currentTime)
    }
    
    /// email subject format `yyyy.MM.dd HH:mm:ss`
    static func datestampExportSubject() async -> String {
        let currentTime = await DateManager.shared.currentDatetime()
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
    
    // `"yyyy-MM-dd HH:mm:ss Z"` ISO 8601 international standard compliant
    //
    //- **`yyyy`**: Represents the four-digit year (e.g., 2025)
    //- **`MM`**: Represents the two-digit month (e.g., 03 for March)
    //- **`dd`**: Represents the two-digit day (e.g., 26)
    //- **`HH`**: Represents the two-digit hour in 24-hour format (e.g., 14 for 2 PM)
    //- **`mm`**: Represents the two-digit minutes (e.g., 30)
    //- **`ss`**: Represents the two-digit seconds (e.g., 45)
    //- **`Z`**: Represents the UTC offset or "Z" for Zulu time (UTC), such as "+00:00" or "Z" timezone information.
    //
    //The standard is flexible but typically uses a "T" separator between the date and time (e.g., `2025-03-26T14:30:45Z`)
    init?(iso8601: String) {
        let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.dateFormat = iso8601.contains("T") ? "yyyy-MM-ddTHH:mm:ss Z" : "yyyy-MM-dd HH:mm:ss Z"
        
        if let date = formatter.date(from: iso8601) {
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
        dateFormatter.locale = Locale(identifier: "en")  //added
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
    
    /// - Parameters:
    ///   - component: A component type.
    ///   - value: The calendar component value.
    /// - Returns: A new date
    ///
    /// •TBDz•  Conform to Gregorian?
    func adding(_ component: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: component, value: value, to: self)
    }
    
    func adding(months: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar.date(byAdding: .month, value: months, to: self)!
    }
    
    /// Returns a new date by adding a number of days.
    ///
    /// - Parameters:
    ///   - value: The calendar component value.
    /// - Returns: A new date
    func adding(days: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    var startOfDay: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        return calendar.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en")
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    // MARK: - Version 4.x Additions :v4.x:
    init?(datestampHHmm: String, referenceDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let timeComponents = formatter.date(from: datestampHHmm) else { return nil }
        
        let calendar = Calendar.current
        let time = calendar.dateComponents([.hour, .minute], from: timeComponents)
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = time.hour
        components.minute = time.minute
        guard let date = calendar.date(from: components) else { return nil }
        self = date
    }
    
    // For UI ranges — respect user's calendar and locale
        private var userCalendar: Calendar {
            Calendar.current
        }
        
        var userDisplayStartOfDay: Date {
            userCalendar.startOfDay(for: self)
        }
        
        var userNoon: Date {
            userCalendar.date(byAdding: .hour, value: 12, to: userDisplayStartOfDay)!
        }
        
        var userEndOfAM: Date {
            userCalendar.date(byAdding: .second, value: -1, to: userNoon)!
        }
        
        var userEndOfDay: Date {
            userCalendar.date(byAdding: .second, value: -1, to: userCalendar.date(byAdding: .day, value: 1, to: userDisplayStartOfDay)!)!
        }
}
