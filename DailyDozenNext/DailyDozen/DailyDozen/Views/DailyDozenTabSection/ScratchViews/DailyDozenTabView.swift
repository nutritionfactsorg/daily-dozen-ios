//
//  DailyDozenTabView.swift
//  DailyDozen
//
//  Created by mc on 3/12/25.
//

import SwiftUI

struct DailyDozenTabView: View {
    @State private var isShowingSheet = false
    @State private var selectedDate = Date()
    private var dozeDateBarField: String = ""
    private var dozePageDate = DateManager.currentDatetime()
    @State private var currentIndex: Int = 0
    @State private var selectedRecord: SqlDailyTracker?
    
    var records: [SqlDailyTracker] = returnSQLDataArray()
    let startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 3, day: 13))!
    let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 20))!
    let direction: Direction = .leftToRight
    
    private var dateRange: [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    private func findRecordForDate(_ date: Date) {
       
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        selectedRecord = records.first { record in
            let recordComponents = calendar.dateComponents([.year, .month, .day], from: record.date)
            return selectedComponents == recordComponents
        }
    }
    
    func updateCheckedCount(_ newCount: Int, totalCheckboxes: Int) {
            var checkedCount = min(newCount, totalCheckboxes)  // Keep it within bounds
            // You'd also save this to the database here
        }
    private func handleTap(index: Int, numBoxes: Int, numxCheckedBoxes: Int) {
        let x = numxCheckedBoxes
        // xCheckbox = numBoxes
        let adjustedIndex = direction == .leftToRight ? index : (numBoxes - 1 - index)
        
        // If tapping an unchecked box
        if adjustedIndex >= x {
            // x = adjustedIndex + 1
            updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
        }
        // If tapping a checked box
        else {
            // Uncheck this box and everything after it
            // x = adjustedIndex
            updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
        }
    }
    mutating func updatePageDate(_ date: Date) {
        let order = Calendar.current.compare(date, to: dozePageDate, toGranularity: .day)
        dozePageDate = date
        if dozePageDate.isInCurrentDayWith(DateManager.currentDatetime()) {
           // dozeBackButton.superview?.isHidden = true
            dozeDateBarField = String(localized: "dateButtonTitle.today", comment: "Date Button Title: 'Today'")
        } else {
        }
       
    }
    var body: some View {
        NavigationStack {
            VStack {
                Text("TEST")
                Button(action: {
                    //isShowingSheet = true
                    isShowingSheet.toggle()
                }, label: {
                    Text("dateButtonTitle.today")
                        .frame(width: 300, height: 30, alignment: .center)
                    //or .frame(maxWidth: .infinity)
                    //TBDz check original for width
                })
                .buttonStyle(.borderedProminent)
                .tint(.brandGreen)
                .padding(5)
                .sheet(isPresented: $isShowingSheet) {
                    DatePickerSheetViewWAS(selectedDate: $selectedDate) { date in
                        findRecordForDate(date)
    
                    }
                        .presentationDetents([.medium]) // Optional: controls sheet height
                }
                //  .presentationDetents([.medium])
                //{
                //                // Buttons
                //                VStack {
                //                HStack {
                //                    Button("Cancel") {
                //                        isShowingSheet = false
                //                    }
                //                    .foregroundColor(.blue)
                //                    Spacer()
                //                    Button("Today") {
                //                        selectedDate = Date()
                //                    }
                //                    .foregroundColor(.blue)
                //                    Spacer()
                //                    Button("Done") {
                //                        isShowingSheet = false
                //                        // TBDz  action you want with selectedDate here
                //                        print("Selected date: \(selectedDate)")
                //                    }
                //                    .foregroundColor(.blue)
                //                }
                //                .padding(10)
                //
                //                    // DatePicker
                //                    //.sheet(isPresented: $showDatePicker) {
                //                    //DatePickerView(selectedDate: $selectedDate)
                //                }
                //                    DatePicker(
                //                        "",
                //                        selection: $selectedDate,
                //                        in: ...Date(),  //sets picker to use no date greater than today
                //                        displayedComponents: [.date]
                //                    )
                //                    .datePickerStyle(.wheel)
                //                    .labelsHidden()  //needed to center
                //                    .padding()
                //
                // }
                //    .presentationDetents([.medium]) // Optional: controls sheet height
                
//                TabView(selection: $currentIndex) {
//                    //ForEach
//                }
               // .padding(5)
                DailyDozenTabSingleDayView()
                DozeBackToTodayButtonViewWAS()
            } //VStack
               // .presentationDetents([.medium])
        .navigationTitle(Text("navtab.doze")) //!!Needs localization comment
        .navigationBarTitleDisplayMode(.inline)
        //
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.brandGreen, for: .navigationBar)
        }
    }
}

#Preview {
    DailyDozenTabView()
}
