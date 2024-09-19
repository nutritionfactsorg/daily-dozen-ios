//
//  Extras.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

/// Use: EventStore events [Event]
var fetchedDozeEvents: [Event] = []
var fetchedTweakEvents: [Event] = []

/// Fetch Realm data for calendar
struct GetDataForCalendar {
    /// Singleton: GetDataForCalendar // :GTD: change to instance approach?
    static var doit = GetDataForCalendar()
    
    var date = Date()
    let realm = RealmProvider.primary
    
    mutating func getData(itemType: DataCountType) {
        var eventList: [Event] = []
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
                    eventList.append(Event(eventType: .full, date: date ))
                } else if count > 0 {
                    eventList.append(Event(eventType: .some, date: date ))
                } else {
                    eventList.append(Event(eventType: .none, date: date ))
                }
            } else {
                eventList.append(Event(eventType: .none, date: date ))
            }
        }
        
        if itemType.isTweak {
            fetchedTweakEvents = eventList
        } else {
            fetchedDozeEvents = eventList
        }
    }
    
    func getData(date: Date, itemType: DataCountType) -> (count: Int, goal: Int)? {
        if let r = realm.getDailyCountRecord(date: date, countType: itemType) {
            return (count: r.count, goal: itemType.goalServings)
        }
        return nil
    }
    
}
