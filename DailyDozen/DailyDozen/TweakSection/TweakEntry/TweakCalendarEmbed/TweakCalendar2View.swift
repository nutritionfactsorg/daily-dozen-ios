//
//  TweakCalendar2View.swift
//  DailyDozen
//
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
struct TweakCalendar2View: UIViewRepresentable {
    let interval: DateInterval
    @Binding var dateSelected: DateComponents?
    @Binding var displayEvents: Bool
    @Binding var itemType: DataCountType
    
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
    func makeCoordinator() -> TweakEventCalendar2Coordinator {
        Coordinator(parent: self, itemType: itemType)
    }
    
    /// UIViewRepresentable updateUIView(UIViewType:Context)
    func updateUIView(_ uiView: UIViewType, context: Context) {
        logit.debug("@@@ TweakCalendar updateUIView")
        // :GTD:???: verify nothing to do here
    }
    
}

/// Delegate: Calendar Date Decoration
@available(iOS 16.0, *)
class TweakEventCalendar2Coordinator: NSObject, UICalendarViewDelegate {
    var parent: TweakCalendar2View
    var itemType: DataCountType
    
    init(parent: TweakCalendar2View, itemType: DataCountType) {
        self.parent = parent
        self.itemType = itemType
    }
    
    @available(iOS 16.0, *)
    @MainActor
    func calendarView(
        _ calendarView: UICalendarView,
        decorationFor dateComponents: DateComponents
    ) -> UICalendarView.Decoration? {
        guard let date: Date = dateComponents.date else { return nil }
        
        logit.verbose("•• calendarView decorationFor \(date.datestampSid) \(itemType)")
        
        if let stats = GetDataForCalendar.doit.getData(date: date, itemType: itemType) {
            logit.verbose("•• •• calendarView \(date.datestampSid) count/goal \(stats.count)/\(stats.goal)")
            
            if stats.count == 0 { return nil } // no decoration.
            
            let color = stats.count == stats.goal ? 
            ColorManager.style.calendarAllChecked : 
            ColorManager.style.calendarSomeChecked
            
            let icon2 = UICalendarView.Decoration.image(
                UIImage(systemName: "circle.fill"),
                color: color,
                size: .large
            )
            return icon2
        }
        
        return nil
    }
    
    func calendarView(
        _ calendarView: UICalendarView,
        didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            
            logit.debug("""
            •• TweakCalendar2View didChangeVisibleDateComponents
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

// /// Extension: Calendar Date Selection :NYI:
//@available(iOS 16.0, *)
//extension TweakEventCalendar2Coordinator: UICalendarSelectionSingleDateDelegate {
//    func dateSelection(_ selection: UICalendarSelectionSingleDate,
//                       didSelectDate dateComponents: DateComponents?) {
//        parent.dateSelected = dateComponents
//        guard let dateComponents else { return }
//        let foundEvents = eventStore.events
//            .filter {$0.date.startOfDay == dateComponents.date?.startOfDay}
//        if !foundEvents.isEmpty {
//            parent.displayEvents.toggle()
//        }
//    }
//    
//    func dateSelection(_ selection: UICalendarSelectionSingleDate,
//                       canSelectDate dateComponents: DateComponents?) -> Bool {
//        return true
//    }
//}
