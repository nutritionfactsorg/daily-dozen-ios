//
//  SqlDailyTrackerId.swift
//  DailyDozen
//
//  Created by mc on 3/25/25.
//

import Foundation

struct SqlDailyTrackerId {
    let id: Date
    var tracker: SqlDailyTracker
    
    init(tracker: SqlDailyTracker) {
        self.id = tracker.date
        self.tracker = tracker
    }
}
