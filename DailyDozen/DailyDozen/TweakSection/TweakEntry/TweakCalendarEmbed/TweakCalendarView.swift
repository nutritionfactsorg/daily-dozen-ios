//
//  TweakCalendarView.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
struct TweakCalendarView: UIViewRepresentable {
    let interval: DateInterval
    @ObservedObject var eventStore: TweakEventStore
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
        
        view.availableDateRange = interval // DateInterval
        
        //to make fit inside UIVewRepresentable
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // :NYI: Setup calendar selection behavior. currently unselectable.
        //let uiCalendarSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        //view.selectionBehavior = uiCalendarSelection
        
        return view
    }
    
    /// UIViewRepresentable makeCoordinator()
    func makeCoordinator() -> TweakEventCalendarCoordinator {
        Coordinator(parent: self, eventStore: _eventStore)
    }
    
    /// UIViewRepresentable updateUIView(UIViewType:Context)
    func updateUIView(_ uiView: UIViewType, context: Context) {
        logit.debug("@@@T1 TweakCalendar updateUIView")
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
class TweakEventCalendarCoordinator: NSObject, UICalendarViewDelegate {
    var parent: TweakCalendarView
    @ObservedObject var eventStore: TweakEventStore
    
    init(parent: TweakCalendarView, eventStore: ObservedObject<TweakEventStore>) {
        self.parent = parent
        self._eventStore = eventStore
    }
    
    @available(iOS 16.0, *)
    @MainActor
    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {
        guard let dateSid = dateComponents.date?.datestampSid else { return nil }
        //logit.verbose("@@@ TweakEventCalendar dateKey is \(dateSid)")
        
        for event in eventStore.events {
            //logit.verbose("@@@T1 \(event.date.datestampSid) =? \(dateSid) \(event.date.datestampSid == dateSid)")
            let eventSid = event.date.datestampSid
            if eventSid == dateSid {
                //logit.verbose("@@@@T2 \(eventSid) == \(dateSid) \(eventSid == dateSid) … \(event.eventType)")
                
                if event.eventType == .full || event.eventType == .some {
                    let icon2 = UICalendarView.Decoration.image(
                        UIImage(systemName: "circle.fill"),
                        color: event.eventType.icon2,
                        size: .large
                    )
                    return icon2
                } else {
                    return nil
                }
            }
        }
        return nil
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        logit.debug("""
        •• TweakCalendarView didChangeVisibleDateComponents
        previousDateComponents:
        \(previousDateComponents.date?.datestampKey ?? ".date nil")
        ••\n
        """)
        let calendar = Calendar.current
        if let previousDate = calendar.date(from: previousDateComponents) {
            if let fromDate = calendar.date(byAdding: .month, value: -1, to: previousDate),
               let toDate = calendar.date(byAdding: .month, value: +1, to: previousDate) {
                logit.debug("""
                •• :NYI: Tweak integration to fetch persistant stored data
                       fromDate: \(fromDate)
                        fromSid: \(fromDate.datestampSid)
                         toDate: \(toDate)
                          toSid: \(toDate.datestampSid)
                """)
                //PersistantDataStore.shared.fetchMultipleMonth(fromDate: beforeDate, toDate: afterDate)
            }
        }
    }
    
}

@available(iOS 16.0, *)
extension TweakEventCalendarCoordinator: UICalendarSelectionSingleDateDelegate {
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
