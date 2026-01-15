//
//  CalendarViewRepresentable.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import UIKit

struct UICalendarViewRepresentable: UIViewRepresentable {
    let item: DataCountType
    //let viewModel: SqlDailyTrackerViewModel
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @Binding var currentMonth: Date
    
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = calendar
        calendarView.locale = Locale.autoupdatingCurrent
        calendarView.availableDateRange = DateInterval(start: Date.distantPast, end: today)
        calendarView.fontDesign = .default // Support dynamic type
        calendarView.delegate = context.coordinator
        calendarView.visibleDateComponents = DateComponents(
            year: calendar.component(.year, from: currentMonth),
            month: calendar.component(.month, from: currentMonth)
        )
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        let newComponents = DateComponents(
            year: calendar.component(.year, from: currentMonth),
            month: calendar.component(.month, from: currentMonth)
        )
        if uiView.visibleDateComponents != newComponents {
            uiView.visibleDateComponents = newComponents
        }
        
        Task { @MainActor in
            let trackers = await viewModel.fetchTrackers(forMonth: currentMonth)
            print("UICalendarViewRepresentable updateUIView: trackers=\(trackers.map { "\($0.date.datestampSid): \(($0.itemsDict[item]?.datacount_count ?? 0))" })")
            context.coordinator.updateDecorations(for: uiView, with: trackers, item: item, calendar: calendar, today: today)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate {
        let parent: UICalendarViewRepresentable
        private var trackers: [SqlDailyTracker] = [] // Store trackers for decoration
        
        init(_ parent: UICalendarViewRepresentable) {
            self.parent = parent
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = parent.calendar.date(from: dateComponents) else {
               // print("decorationFor: Invalid date components for \(dateComponents)")
                return nil
            }
            
            if date > parent.today {
              //  print("decorationFor: Skipping future date \(date.datestampSid)")
                return nil
            }
            
            // Find tracker for the date from stored trackers
            let tracker = trackers.first { parent.calendar.isDate($0.date, inSameDayAs: date) }
            let count = tracker?.itemsDict[parent.item]?.datacount_count ?? 0
            
           // print("decorationFor: date=\(date.datestampSid), item=\(parent.item), count=\(count), trackersCount=\(trackers.count)")
            
            if count == 0 {
                return nil
            } else if count == parent.item.goalServings {
                return .customView {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                    view.backgroundColor = .nfCalendarAllChecked // Green for full completion
                    view.layer.cornerRadius = 10
                    return view
                }
            } else {
                return .customView {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                    view.backgroundColor = .nfCalendarSomeChecked // Yellow for partial
                    view.layer.cornerRadius = 10
                    return view
                }
            }
        }
        
        func updateDecorations(for calendarView: UICalendarView, with trackers: [SqlDailyTracker], item: DataCountType, calendar: Calendar, today: Date) {
            self.trackers = trackers // Update stored trackers
            
            var dateComponentsToReload: [DateComponents] = []
            
            // Get start and end of the current month
            let startOfMonth = calendar.startOfMonth(for: parent.currentMonth)
            let endOfMonth = calendar.endOfMonth(for: parent.currentMonth)
            var currentDate = startOfMonth
            
            // Iterate through all days in the month
            while currentDate <= endOfMonth {
                let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
                if currentDate <= today, let tracker = trackers.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }),
                   let count = tracker.itemsDict[item]?.datacount_count, count > 0 {
                    dateComponentsToReload.append(components)
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            print("updateDecorations: reloading \(dateComponentsToReload.count) dates for item=\(item)")
            if !dateComponentsToReload.isEmpty {
                calendarView.reloadDecorations(forDateComponents: dateComponentsToReload, animated: true)
            }
        }
        
        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom oldComponents: DateComponents) {
            if let newMonth = calendarView.visibleDateComponents.date {
                print("calendarView: month changed to \(newMonth.datestampSid)")
                Task { @MainActor in
                    parent.currentMonth = newMonth
                }
            }
        }
    }
}
