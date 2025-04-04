//
//  SwiftView3BC.swift
//  DailyDozen
//
//  Created by mc on 3/26/25.
//
//import SwiftUI
//
//struct ScratchView3BC: View {
//    var records: [SqlDailyTracker] = returnSQLDataArray()
//    let startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 3, day: 13))!
//    let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 26))!
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
//    var body: some View {
//        VStack {
//            TabView {
//                
//                ForEach(dateRange.reversed(), id: \.self) { datex in
//                    VStack {
//                        Text(datex, style: .date)
//                            .font(.headline)
//                        
//                        if let record = records.first(where: { record in Calendar.current.isDate(record.date, inSameDayAs: datex) }) {
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
//                           // .tag(datex)  //datex?
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .onDisappear {
//                        print("SwipeView disappeared! Save Changes")
//                    }
//                    .tag(datex)  //datex?
//
//                }
//            }
//            .tabViewStyle(.page)
//        }
//        .onAppear {
//            //dailyInfos = returnSQLDataArray()
//        }
//    }
//}
//
//#Preview {
//    ScratchView3BC()
//}
