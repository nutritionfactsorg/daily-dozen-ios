//
//  DateManager.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct DateManager {
    
    static private var _currentDatetime = Date()
    
    /// return "now" date and time
    static func currentDatetime() -> Date {
        var datetime = Date()
        #if DEBUG
        datetime = _currentDatetime
        #endif
        return datetime
    }
    
    static func setCurrentDateTime(_ datetime: Date) {
        _currentDatetime = datetime
    }
    
    static func incrementDay() {
        if let datePlusOneDay = Calendar.current.date(
            byAdding: Calendar.Component.day,
            value: 1,
            to: _currentDatetime
        ) {
            _currentDatetime = datePlusOneDay
        }
    }
    
}
