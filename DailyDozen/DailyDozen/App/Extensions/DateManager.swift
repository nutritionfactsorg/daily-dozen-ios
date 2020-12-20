//
//  DateManager.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation

struct DateManager {
    
    static private var _offsetDay = 0
    
    /// return "now" date and time
    static func currentDatetime() -> Date {
        var datetime = Date()
        #if DEBUG
        var components = DateComponents()
        components.day = _offsetDay
        if let d = Calendar.current.date(byAdding: components, to: datetime) {
            datetime = d
        } else {
            LogService.shared.error("DateManager currentDatetime() failed to ")
        }
        #endif
        return datetime
    }
    
    static func incrementDay() {
        _offsetDay += 1
    }
    
}
