//
//  DatePickerView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct CancelToolbarButton: ToolbarContent {
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if #available(iOS 26.0, *) {
                Button(role: .cancel, action: action)
                   
            } else {
                Button("history_data_alert_cancel", action: action)
                   
            }
               
        }
        
    }
}

struct ConfirmToolbarButton: ToolbarContent {
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if #available(iOS 26.0, *) {
                Button(role: .confirm, action: action)
            } else {
                Button("history_data_alert_ok", action: action)
            }
        }
    }
}

struct DatePickerSheetView: View {
    @Binding var selectedDate: Date
    @Binding var dateRange: [Date]
    @Binding var currentIndex: Int
    @Environment(\.dismiss) var dismiss
    private let viewModel = SqlDailyTrackerViewModel.shared
    
    @State private var tempSelectedDate: Date
    
    init(selectedDate: Binding<Date>, dateRange: Binding<[Date]>, currentIndex: Binding<Int>) {
            _selectedDate = selectedDate
            _dateRange = dateRange
            _currentIndex = currentIndex
            // Initialize temp with current value
            _tempSelectedDate = State(initialValue: selectedDate.wrappedValue)
        }
    
    var body: some View {
            NavigationStack {
                VStack(spacing: 5) {
                    // Spacer() // Uncomment if you want to push content to bottom
                    VStack {
                        DatePicker(
                            "",
                            selection: $tempSelectedDate,
                            in: ...Calendar.current.startOfDay(for: Date()),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        //.padding()
                    }
                    .toolbar {
                        CancelToolbarButton {
                            dismiss()
                            }
                        
                        ToolbarItem(placement: .principal) {
                            Button("dateButtonTitle.today") {
                                //viewModel.ensureDateIsInRange(Date(), dateRange: &dateRange, currentIndex: &currentIndex)
                                let today = Date()
                               // tempSelectedDate = today
                                let finalDate = Calendar.current.startOfDay(for: today)
                                selectedDate = finalDate
                                dismiss()  // Apply and dismiss
                            }
                        }
                        
                        ConfirmToolbarButton {
                            let finalDate = Calendar.current.startOfDay(for: tempSelectedDate)
                            selectedDate = finalDate
                              //  viewModel.ensureDateIsInRange(selectedDate, dateRange: &dateRange, currentIndex: &currentIndex, thenSelectIt: true)
                          dismiss()
                        }
                       
                    } //ToolBar
                  //  .padding()
                } //Vstack
            } //Nav
        } //body
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
