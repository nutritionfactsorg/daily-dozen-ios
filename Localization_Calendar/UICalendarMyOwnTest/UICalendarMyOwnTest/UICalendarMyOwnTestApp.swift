//
//  UICalendarMyOwnTestApp.swift
//  UICalendarMyOwnTest
//
//

import SwiftUI

@main
struct UICalendarMyOwnTestApp: App {
    
    @StateObject var myEvents = EventStore(preview: true)
    
    var body: some Scene {
        WindowGroup {
            EventsCalendarView()
                .environmentObject(myEvents)
        }
    }
}
