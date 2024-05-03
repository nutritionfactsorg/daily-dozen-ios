//
//  UICalendarMyOwnTestApp.swift
//  UICalendarMyOwnTest
//
//

import SwiftUI

// :FUTURE:iOS16: @main future use
struct UICalendarMyOwnTestApp: App {
    
    @StateObject var myEvents = EventStore(preview: true)
    
    var body: some Scene {
        WindowGroup {
            EventsCalendarView()
                .environmentObject(myEvents)
        }
    }
}
