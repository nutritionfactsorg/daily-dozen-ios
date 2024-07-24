//
//  Extras.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

//Global to set calendar to use Persian Calendar
var isPersian: Bool = false
//*********************Below is testing
//**Getting Realm Data**//

var getDataForCalendar = GetDataForCalendar()

var fetchedEvents: [Event] = []

// Related: extension ItemHistoryViewController: FSCalendarDataSource
//*** Get data from Realm

struct GetDataForCalendar {
    var dozevents: [Event] = []
    // @ObservedObject var eventStore: EventStore
    var date = Date()
    let realm = RealmProvider.primary
    //var itemType: DataCountType!
    
    mutating func getData(itemType: DataCountType) {
        let currentDatetime = DateManager.currentDatetime()
        guard date <= currentDatetime else {
            logit.error("Error: getData date '\(date)' > currentDatetime '\(currentDatetime)'")
            return
        }
        dozevents = []
        //:GTD:// this is where the loop is to read Realm
        for i in 0...1095 {
            date = Date().diff(numDays: -i)
            
            // expected: all itemTypes for ONE day
            let itemsDict = realm.getDailyTracker(date: date).itemsDict
            if let statesCount = itemsDict[itemType]?.count {
                //   print("\(itemType.typeKey) \(statesCount)/\(itemType.goalServings)")
                //cell.configure(for: statesCount, maximum: itemType.goalServings)
                configure(for: statesCount, maximum: itemType.goalServings, date: date)
            } else {
                // print("\(itemType.typeKey) nil/\(itemType.goalServings)")
                //cell.configure(for: 0, maximum: itemType.goalServings)
                configure(for: 0, maximum: itemType.goalServings, date: date)
            }
        }
        
    }
    
    mutating func configure(for count: Int, maximum: Int, date: Date) {
        
        if count == maximum {
            dozevents.append(Event(eventType: .full, date: date ))
            
            // borderView.backgroundColor = UIColor.yellowColor
        } else if count > 0 {
            dozevents.append(Event(eventType: .some, date: date ))
            // borderView.backgroundColor = UIColor.yellow
        } else {
            dozevents.append(Event(eventType: .none, date: date ))
            //            borderView.backgroundColor = UIColor.white
        }
        
        fetchedEvents = dozevents
    }
    
}
