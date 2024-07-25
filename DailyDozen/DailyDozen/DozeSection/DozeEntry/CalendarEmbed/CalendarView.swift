//
//  CalendarView.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @ObservedObject var eventStore: EventStore
    @Binding var dateSelected: DateComponents?
    @Binding var displayEvents: Bool
    
    /// UIViewRepresentable makeUIView(Context)
    func makeUIView(context: Context) -> some UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        
        if Locale.current.isPersian {
            //both of these are needed to make persian calendar?
            view.calendar = Calendar(identifier: .persian)
            // view.locale = Locale(identifier: "fa") // :???: required if device language is fa?
        } else {
            view.calendar = Calendar(identifier: .gregorian)
        }
        
        view.availableDateRange = interval
        
        //to make fit inside UIVewRepresentable
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // :NYI: Setup calendar selection behavior. currently unselectable.
        //let uiCalendarSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        //view.selectionBehavior = uiCalendarSelection
        
        return view
    }
    
    /// UIViewRepresentable makeCoordinator()
    func makeCoordinator() -> EventCalendarCoordinator {
        Coordinator(parent: self, eventStore: _eventStore)
    }
    
    /// UIViewRepresentable updateUIView(UIViewType:Context)
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let changedEvent = eventStore.changedEvent {
            uiView.reloadDecorations(forDateComponents: [changedEvent.dateComponents], animated: true)
            eventStore.changedEvent = nil
        }
        
        if let movedEvent = eventStore.movedEvent {
            uiView.reloadDecorations(forDateComponents: [movedEvent.dateComponents], animated: true)
            eventStore.movedEvent = nil
        }
    }
    
}

@available(iOS 16.0, *)
class EventCalendarCoordinator: NSObject, UICalendarViewDelegate {
    var parent: CalendarView
    @ObservedObject var eventStore: EventStore
    
    init(parent: CalendarView, eventStore: ObservedObject<EventStore>) {
        self.parent = parent
        self._eventStore = eventStore
    }
    
    @available(iOS 16.0, *)
    @MainActor
    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {
        let foundEvents = eventStore.events
            .filter {$0.date.startOfDay == dateComponents.date?.startOfDay}
        
        if foundEvents.isEmpty { return nil }
        
        if foundEvents.count > 1 {  //more than one event for same date
            logit.debug("same day found multiple events: \(foundEvents)")
            return .image(UIImage(systemName: "doc.on.doc.fill"),
                          color: .red,
                          size: .large)
        }
        
        let singleEvent = foundEvents.first!
        if singleEvent.eventType == .full || singleEvent.eventType == .some {
            let icon2 = UICalendarView.Decoration.image(
                UIImage(systemName: "circle.fill"),
                color: singleEvent.eventType.icon2,
                size: .large
            )
            return icon2
        } else {
            return nil
        }
        
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        logit.debug("""
        •• CalendarView didChangeVisibleDateComponents
        previousDateComponents:
        \(previousDateComponents)
        ••\n
        """)
        let calendar = Calendar.current
        if let previousDate = calendar.date(from: previousDateComponents) {
            if let fromDate = calendar.date(byAdding: .month, value: -1, to: previousDate),
               let toDate = calendar.date(byAdding: .month, value: +1, to: previousDate) {
                logit.debug("""
                •• :NYI: integration to fetch persistant stored data
                           from: \(fromDate)
                         toDate: \(toDate)
                """)
                //PersistantDataStore.shared.fetchMultipleMonth(fromDate: beforeDate, toDate: afterDate)
            }
        }
    }
    
}

@available(iOS 16.0, *)
extension EventCalendarCoordinator: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate,
                       didSelectDate dateComponents: DateComponents?) {
        parent.dateSelected = dateComponents
        guard let dateComponents else { return }
        let foundEvents = eventStore.events
            .filter {$0.date.startOfDay == dateComponents.date?.startOfDay}
        if !foundEvents.isEmpty {
            parent.displayEvents.toggle()
        }
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate,
                       canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
}
