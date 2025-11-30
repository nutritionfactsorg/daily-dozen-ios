//
//  SqlDailyTrackerId.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

// TBDz:  Not sure this is used anywhere besides initial mockdb
import Foundation

struct SqlDailyTrackerId {
    let id: Date
    var tracker: SqlDailyTracker
    
    init(tracker: SqlDailyTracker) {
        self.id = tracker.date
        self.tracker = tracker
    }
}
