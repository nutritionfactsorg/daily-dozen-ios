//
//  DateManager.swift
//  DailyDozen
//
//  Copyright © 2020-2025 NutritionFacts.org. All rights reserved.
//

import Foundation

actor DateManager {
    static let shared = DateManager()
    
    private var offsetDay = 0
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
            print("•ERROR• DateManager currentDatetime() failed to ")
        }
#endif
        return datetime
    }
    
    func incrementDay() {
        offsetDay += 1
    }
}
