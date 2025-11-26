//
//  SqlDailyTrackerId.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
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
