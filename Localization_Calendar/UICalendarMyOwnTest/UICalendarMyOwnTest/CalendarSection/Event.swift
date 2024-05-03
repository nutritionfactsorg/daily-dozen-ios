//
//  Event.swift
//  UICalendarMyOwnTest
//
//

import SwiftUI

struct Event: Identifiable {
    //    let itemIcon = UIImage(systemName: "circle.fill")
    //    var itemIconColor: Color?
    enum EventType: String, Identifiable, CaseIterable {
        case full, some, none, unspecified
        
        var id: String {
            self.rawValue
        }
        
        var icon2: UIColor? {
            switch self {
            case .full:
                return mainMedium
                
                
            case .some:
                return yellowSunglowColor
                
            case .none:
                return nil
                
                
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
            [.month,
             .day,
             .year,
             .hour,
             .minute],
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
            Event(eventType: .full, date: Date().diff(numDays: 0) ),
            Event(date: Date().diff(numDays: -1)),
            Event(eventType: .full, date: Date().diff(numDays: 6) ),
            Event(eventType: .some, date: Date().diff(numDays: 2) ),
            //Event(eventType: .none, date: Date().diff(numDays: -1)),
            Event(eventType: .some, date: Date().diff(numDays: -3)),
            Event(date: Date().diff(numDays: -4))
        ]
    }
}
