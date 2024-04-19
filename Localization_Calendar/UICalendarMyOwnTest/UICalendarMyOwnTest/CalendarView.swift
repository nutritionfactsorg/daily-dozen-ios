//
//  CalendarView.swift
//  UICalendarMyOwnTest
//
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @ObservedObject var eventStore: EventStore
    @Binding var dateSelected: DateComponents?
    @Binding var displayEvents: Bool
    
    func makeUIView(context: Context) -> some UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        
        if !isGregorian {
            //both of these are needed to make persian calendar
            view.calendar = Calendar(identifier: .persian)
            view.locale = Locale(identifier: "fa") // will this be needed if language is fa?
        }
        
        else {
            view.calendar = Calendar(identifier: .gregorian)
        }
        
        view.availableDateRange = interval
        
        //to make fit inside UIVewRepresentable
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        return view
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, eventStore: _eventStore)
    }
    
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
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        @ObservedObject var eventStore: EventStore
        init(parent: CalendarView, eventStore: ObservedObject<EventStore>) {
            self.parent = parent
            self._eventStore = eventStore
        }
        
        @MainActor
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let foundEvents = eventStore.events
                .filter {$0.date.startOfDay == dateComponents.date?.startOfDay}
            if foundEvents.isEmpty { return nil }
            
            if foundEvents.count > 1 {  //more than one event for same date
                return .image(UIImage(systemName: "doc.on.doc.fill"),
                              color: .red,
                              size: .large)
            }
            let singleEvent = foundEvents.first!
            //return .customView {
            //                let icon = UILabel()
            //                
            //                icon.text = singleEvent.eventType.icon
            
            
            if singleEvent.eventType == .full || singleEvent.eventType == .some {
                let icon2 = UICalendarView.Decoration.image(
                    UIImage(systemName: "circle.fill"),
                    color: singleEvent.eventType.icon2,
                    size: .large
                )
                
                return icon2
            }
            else {
                return nil
            }
            //   }
            
            
            // let heart = UICalendarView.Decoration.image(
            //     UIImage(systemName: "circle.fill"),
            //     color: UIColor.green,
            //     size: .large
            // )
            // return heart
        }
        
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
    
    
}
