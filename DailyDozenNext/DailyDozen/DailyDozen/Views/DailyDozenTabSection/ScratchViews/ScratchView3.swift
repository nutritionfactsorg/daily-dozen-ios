//
//  ScratchView3.swift
//  DailyDozen
//
//  Created by mc on 2/17/25.
//

import SwiftUI

//struct ScratchView3: View {
//    var records: [SqlDailyTracker] = returnSQLDataArray()
//    @State private var isShowingSheet = false
//    let startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 3, day: 13))!
//    let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 24))! //NYIz: Needs to be localized -- something like dateStamSid?
//    //let endDate = Date(datestampSid: <#T##String#>)
//    @State private var selectedRecord: SqlDailyTracker?
//    @State private var selectedDate = Date()
//    //@State private var x: Int  = 0  // Number of checked boxes //Might need to Change to @Binding so parent can access and modify it, depending on when save to database occurs.
//    let direction: Direction = .leftToRight
//    //@State var xCheckbox: Int = 1
//    
//    private var dateRange: [Date] {
//        var dates: [Date] = []
//        var currentDate = startDate
//        
//        while currentDate <= endDate {
//            dates.append(currentDate)
//            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
//        }
//        return dates
//    }
//    func updateCheckedCount(_ newCount: Int, totalCheckboxes: Int) {
//            var checkedCount = min(newCount, totalCheckboxes)  // Keep it within bounds
//            // You'd also save this to the database here
//        }
//    private func handleTap(index: Int, numBoxes: Int, numxCheckedBoxes: Int) {
//        let x = numxCheckedBoxes
//       // xCheckbox = numBoxes
//        let adjustedIndex = direction == .leftToRight ? index : (numBoxes - 1 - index)
//        
//        // If tapping an unchecked box
//        if adjustedIndex >= x {
//           // x = adjustedIndex + 1
//            updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
//        }
//        // If tapping a checked box
//        else {
//            // Uncheck this box and everything after it
//           // x = adjustedIndex
//            updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
//        }
//        
//        print("Tap \(adjustedIndex)")
//        //saveToDatabase here is want to save after each tap. might be overkill and may want to just save when View Disappears
//    }
//    
////    func getCount(for item: Item) -> Int { // Adjust return type as needed
////            record.itemsDict[item]?.datacount_count ?? 0 // Provide a default value
////        }
//    
//    private func findRecordForDate(_ date: Date) {
//        let calendar = Calendar.current
//        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: date)
//        print("I am in findRecord")
//        selectedRecord = records.first { record in
//           //let recordComponents = calendar.isDate(record.date, inSameDayAs: datex) })
//            let recordComponents = calendar.dateComponents([.year, .month, .day], from: record.date)
//            return selectedComponents == recordComponents
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            Button("dateButtonTitle.today") {
//                isShowingSheet = true
//            }
//            .buttonStyle(.bordered)
//            TabView {
//                
//                ForEach(dateRange.reversed().indices, id: \.self) { datex in
//                    VStack {
//                        Text(datex, style: .date)
//                            .font(.headline)
//                    
////                        if let record = selectedRecord {
////                            Text(record.date.datestampSid)
//                      if let record = records.first(where: { record in Calendar.current.isDate(record.date, inSameDayAs: datex) }) {
//                            ForEach(DozeEntryViewModel.rowTypeArray, id: \.self) {
//                                item in
//                                HStack {
//                                    let itemData = record.itemsDict[item]
//                                    // Text(record.itemsDict[item])
//                                    Text(item.headingDisplay)
//                                    //Text(String(record.itemsDict[item]?.datacount_count ?? 0))
//                                        .font(.body)
//                                   // var count = record.itemsDict[item]?.datacount_count
//                                    let count = itemData?.datacount_count ?? 0
//                                  //  var boxes = item.goalServings
//                                    let boxes = item.goalServings
//                                    ContiguousCheckboxView(n: boxes, x: count, direction: .leftToRight)
//                                   // Text(String(item.goalServings))
//                                  //  xCheckbox = item.goalServings
////                                    var numBoxes: Int = 5
////                                    //var count = record.itemsDict[item]?.datacount_count
////                                    var count: Int =  3
////                                    //record.itemsDict[item]?.datacount_count
////                                    
////                                    ForEach(0..<numBoxes, id: \.self) { index in
////                                       // Text("Hello")
////                                            CheckboxView2(isChecked: index < count,
////                                                          onTap: { handleTap(index: index, numBoxes: numBoxes, numxCheckedBoxes: count)
////                                              }
////                                            )
////                                        }
//                                }//HStack
//                            }//ForEach Outer
//                            
//                            //                          Text(String(record.itemsDict[.dozeGreens]?.datacount_count ?? 0))
//                            //                                .font(.body)
//                        } else {
//                            Text("No data available")
//                                .font(.body)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .onDisappear {
//                        print("SwipeView disappeared! Save Changes")
//                        
//                    }
//                    .onAppear {
//                        findRecordForDate(selectedDate)
//                        print(selectedDate)
//                    }
//                   // .tag(datex)
//                }
//                .onChange(of: selectedDate) { newValue in
//                                debugPrint("[a]: new value \(newValue)")
//                    findRecordForDate(newValue)
//                            }
//               
//            }
//            .tabViewStyle(.page)
//        }
//       
//        .sheet(isPresented: $isShowingSheet) {
//            DatePickerSheetView(selectedDate: $selectedDate) { date in
//                findRecordForDate(date)
//                print(records[0].date)
//            }
//        }
//        
//    }
//}

//#Preview {
//    ScratchView3()
//}
