//
//  DateManager.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import Foundation

actor DateManager {
    
    private var offsetDay = 0
    static let shared = DateManager()
    private init() {}
    
    /// return "now" date and time
    func currentDatetime() -> Date {
        var datetime = Date()
        #if DEBUG
        var components = DateComponents()
        components.day = offsetDay
        if let d = Calendar.current.date(byAdding: components, to: datetime) {
            datetime = d
        } else {
           // logit.error("DateManager currentDatetime() failed to ")
            print("DateManager currentDatetime() failed to ")
        }
        #endif
        return datetime
    }
    
    func incrementDay() {
        offsetDay += 1
    }
    
}
