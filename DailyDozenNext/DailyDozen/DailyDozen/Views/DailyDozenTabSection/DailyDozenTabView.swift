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
                    DatePickerView(selectedDate: $selectedDate)
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
                DozeBackToTodayButtonView()
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
