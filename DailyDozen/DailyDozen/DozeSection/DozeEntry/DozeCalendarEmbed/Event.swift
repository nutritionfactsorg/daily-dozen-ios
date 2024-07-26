//
//  Event.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct Event: Identifiable {
    
    enum EventType: String, Identifiable, CaseIterable {
        case full, some, none, unspecified
        
        var id: String {
            self.rawValue
        }
        
        var icon2: UIColor? {
            switch self {
            case .full:
                return ColorManager.style.calendarAllChecked
            case .some:
                return ColorManager.style.calendarSomeChecked
            case .none:
                return nil // effectively `.white` per existing DD code.
            case .unspecified:
                return nil
            }
        }
        
    }
    
    var eventType: EventType
    var date: Date
    
    var id: String
    
    var dateComponents: DateComponents {
        var dateComponents = Calendar.current.dateComponents(
            [.month, .day, .year, .hour, .minute],
            from: date)
        dateComponents.timeZone = TimeZone.current
        dateComponents.calendar = Calendar(identifier: .gregorian)
        return dateComponents
    }
    
    init(id: String = UUID().uuidString, eventType: EventType = .unspecified, date: Date) {
        self.eventType = eventType
        self.date = date
        
        self.id = id
    }
    
    // Data to be used in the preview
    static var sampleEvents: [Event] {
        return [
            Event(eventType: .full, date: Date().adding(days: 0) ),
            Event(date: Date().adding(days: -1)),
            Event(eventType: .full, date: Date().adding(days: 6) ),
            Event(eventType: .some, date: Date().adding(days: 2) ),
            //Event(eventType: .none, date: Date().adding(days: -1)),
            Event(eventType: .some, date: Date().adding(days: -3)),
            Event(date: Date().adding(days: -4))
        ]
    }
    
}
