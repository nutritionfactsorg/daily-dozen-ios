//
//  Extras.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

/// Use: EventStore events [Event]
var fetchedEvents: [Event] = []

/// Fetch Realm data for calendar
struct GetDataForCalendar {
    /// Singleton: GetDataForCalendar // :GTD: change to instance approach?
    static var doit = GetDataForCalendar()
    
    // @ObservedObject var eventStore: EventStore
    var date = Date()
    let realm = RealmProvider.primary
    
    mutating func getData(itemType: DataCountType) {
        var dozevents: [Event] = []
        let goal = itemType.goalServings
        
        let currentDatetime = DateManager.currentDatetime()
        guard date <= currentDatetime else {
            logit.error("Error: getData date '\(date)' > currentDatetime '\(currentDatetime)'")
            return
        }
        
        for i in 0...1095 { //*** :GTD: fetch events loop fixed vs UI range
            date = Date().adding(days: -i)
            
            let itemsDict = realm.getDailyTracker(date: date).itemsDict
            if let count = itemsDict[itemType]?.count {
                if count == goal {
                    dozevents.append(Event(eventType: .full, date: date ))
                } else if count > 0 {
                    dozevents.append(Event(eventType: .some, date: date ))
                } else {
                    dozevents.append(Event(eventType: .none, date: date ))
                }
            } else {
                dozevents.append(Event(eventType: .none, date: date ))
            }
        }
        
        fetchedEvents = dozevents
    }
    
}
