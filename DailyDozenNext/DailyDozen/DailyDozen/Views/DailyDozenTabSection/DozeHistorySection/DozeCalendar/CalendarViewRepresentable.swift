//
//  CalendarViewRepresentable.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import UIKit // Needed for UICalendarView

// UICalendarViewRepresentable to integrate UICalendarView in SwiftUI
struct UICalendarViewRepresentable: UIViewRepresentable {
    let item: DataCountType
    let records: [SqlDailyTracker]
    @Binding var currentMonth: Date
    
    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = calendar
        calendarView.locale = Locale.autoupdatingCurrent
        calendarView.availableDateRange = DateInterval(start: Date.distantPast, end: today)
        calendarView.setVisibleDateComponents(DateComponents(year: calendar.component(.year, from: currentMonth), month: calendar.component(.month, from: currentMonth)), animated: false)
        // Ensure font supports dynamic type
        calendarView.fontDesign = .default // or .rounded for better accessibility
        calendarView.delegate = context.coordinator
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Update the visible month if currentMonth changes
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        uiView.setVisibleDateComponents(components, animated: true)
        
        // Reload decorations for the visible month (fixed: wrap in array)
        uiView.reloadDecorations(forDateComponents: [uiView.visibleDateComponents], animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    //CalendarViewDelegate
    class Coordinator: NSObject, UICalendarViewDelegate {
        let parent: UICalendarViewRepresentable
        
        init(_ parent: UICalendarViewRepresentable) {
            self.parent = parent
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = parent.calendar.date(from: dateComponents) else { return nil }
            
            if date > parent.today {
                return nil
            }
            
            let count = parent.records.first(where: { parent.calendar.isDate($0.date, inSameDayAs: date) })?
                .itemsDict[parent.item]?.datacount_count ?? 0
            
            if count == 0 {
                return nil
            } else if count == parent.item.goalServings {
                return .customView {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                    view.backgroundColor = .calendarAllChecked //!!TBDz  fix color
                    view.layer.cornerRadius = 10
                    return view
                }
            } else {
                return .customView {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                    view.backgroundColor = .calendarSomeChecked ////!!TBDz  fix color
                    view.layer.cornerRadius = 10
                    return view
                }
            }
        }
    }
}
