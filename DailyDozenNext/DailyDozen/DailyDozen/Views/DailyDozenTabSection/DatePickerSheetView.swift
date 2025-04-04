//
//  DatePickerView.swift
//  DailyDozen
//
//  Created by mc on 3/20/25.
//

import SwiftUI

struct DatePickerSheetView: View {
    @Binding var selectedDate: Date
    @Binding var dateRange: [Date]
    @Binding var currentIndex: Int
    @Environment(\.dismiss) var dismiss
    
    private func extendDateRangeForSelectedDate() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // If selectedDate is outside current dateRange, extend it
        if let earliestDate = dateRange.first, let latestDate = dateRange.last {
            if selectedDate < earliestDate {
                let daysToAdd = calendar.dateComponents([.day], from: selectedDate, to: earliestDate).day!
                let newDates = (1...daysToAdd).map { offset in
                    calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
                }.reversed()
                dateRange.insert(contentsOf: newDates, at: 0)
                currentIndex += daysToAdd // Adjust index after inserting
            } else if selectedDate > latestDate && selectedDate <= today {
                let daysToAdd = calendar.dateComponents([.day], from: latestDate, to: selectedDate).day!
                let newDates = (1...daysToAdd).map { offset in
                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
                }
                dateRange.append(contentsOf: newDates)
            }
            if selectedDate > today {
                 selectedDate = today
            }
        }
    }
    
    private func goToToday() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        selectedDate = today
        
        // Extend range if today is outside current dateRange
        if let earliestDate = dateRange.first, let latestDate = dateRange.last {
            if today < earliestDate {
                let daysToAdd = calendar.dateComponents([.day], from: today, to: earliestDate).day!
                let newDates = (1...daysToAdd).map { offset in
                    calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
                }.reversed()
                dateRange.insert(contentsOf: newDates, at: 0)
                currentIndex += daysToAdd
            } else if today > latestDate && today <= today { // This condition is redundant but kept for consistency
                let daysToAdd = calendar.dateComponents([.day], from: latestDate, to: today).day!
                let newDates = (1...daysToAdd).map { offset in
                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
                }
                dateRange.append(contentsOf: newDates)
            }
        }
        // Update currentIndex to today’s position
                if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
                    currentIndex = todayIndex
                }
            }
    
    var body: some View {
        VStack(spacing: 5) {
         //   Spacer() //Pushes content to bottom
            VStack {
                HStack {
                    Button("Cancel") {
                        //  isShowingSheet = false
                        dismiss()
                    }
                    .foregroundColor(.blue)
                  //  .padding(.horizontal)
                    Spacer()
                    Button("Today") {
                        // selectedDate = Date()
                        goToToday()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                   // .padding(.horizontal)
                     Spacer()
                    Button("Done") {
                        // isShowingSheet = false
                        // TBDz  action you want with selectedDate here
                        print("Selected date: \(selectedDate)")
                        // Extend date range if needed and update currentIndex
                        extendDateRangeForSelectedDate()
                        if let index = dateRange.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
                            currentIndex = index
                        }
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                }
                // .padding(10)
                
                
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...Calendar.current.startOfDay(for: Date()),  //sets picker to use no date greater than today
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
              //  .frame(maxHeight: UIScreen.main.bounds.height / 3)
                .labelsHidden()  //needed to center
                
                
            }
            .padding()
            //.frame(maxHeight: UIScreen.main.bounds.height / 2)
            .padding()
            
        }
    }
}

#Preview {
    // Wrapper view to provide bindings for the preview
    struct PreviewWrapper: View {
        @State private var selectedDate = Date()
        @State private var dateRange: [Date] = {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            return (-30...0).map { offset in
                calendar.date(byAdding: .day, value: offset, to: today)!
            }
        }()
        @State private var currentIndex = 30 // Today’s index in the initial range
        
        var body: some View {
            DatePickerSheetView(
                selectedDate: $selectedDate,
                dateRange: $dateRange,
                currentIndex: $currentIndex
            )
        }
    }
    
    return PreviewWrapper()
}
