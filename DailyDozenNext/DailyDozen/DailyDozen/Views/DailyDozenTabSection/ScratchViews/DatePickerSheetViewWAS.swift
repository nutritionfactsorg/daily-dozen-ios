//
//  DatePickerView.swift
//  DailyDozen
//
//  Created by mc on 3/20/25.
//

import SwiftUI

struct DatePickerSheetViewWAS: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            VStack {
            HStack {
                Button("Cancel") {
                  //  isShowingSheet = false
                    dismiss()
                }
                .foregroundColor(.blue)
                Spacer()
                Button("Today") {
                   // selectedDate = Date()
                    onDateSelected(selectedDate)
                    dismiss()
                }
                .foregroundColor(.blue)
                Spacer()
                Button("Done") {
                   // isShowingSheet = false
                    // TBDz  action you want with selectedDate here
                    print("Selected date: \(selectedDate)")
                    onDateSelected(selectedDate)
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding(10)
           
            }
                    
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: ...Date(),  //sets picker to use no date greater than today
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                   // .modifier(OnChangeDateModifier(date: selectedDate) { newDate in
                  //      onDateSelected(newDate)
                 //   })
                    .labelsHidden()  //needed to center
                    .padding()
                    
                }
                .padding()
    }
}

//#Preview {
//    @State static var previewDate = Date()
//    DatePickerView(selectedDate: $previewDate)
//}
//struct DatePickerView_Previews: PreviewProvider {
//    @State static var previewDate = Date()  // Static state for preview
//    @State static var previewSelected = Date()
//    static var previews: some View {
//        DatePickerSheetView(selectedDate: $previewDate, onDateSelected: previewDate)
//    }
//}
