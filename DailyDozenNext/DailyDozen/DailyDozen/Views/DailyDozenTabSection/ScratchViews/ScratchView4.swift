//
//  ScratchView3.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

//import SwiftUI
//struct ScratchView4: View {
//    var streakCount = 3000 // NYIz just a placeholder for now
//    @State private var records: [SqlDailyTracker] = returnSQLDataArray()
//    @State private var isShowingSheet = false
//    @State private var selectedRecord: SqlDailyTracker?
//    @State private var selectedDate = Date()
//    @State private var currentIndex = 0
//    @State private var dateRange: [Date] = []
//    //@State private var x: Int  = 0  // Number of checked boxes //Might need to Change to @Binding so parent can access and modify it, depending on when save to database occurs.
//    let direction: Direction = .leftToRight
//    //@State var xCheckbox: Int = 1
//    
//    private func recordForDate(_ date: Date) -> SqlDailyTracker? {
//        records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
//    }
//    private func extendDateRangeIfNeeded(for index: Int) {
//        let calendar = Calendar.current
//        let bufferDays = 30
//        let today = calendar.startOfDay(for: Date()) // User's current date
//        
//        // If dateRange is empty, initialize it from 30 days before today up to today
//        if dateRange.isEmpty {
//            dateRange = (-bufferDays...0).map { offset in
//                calendar.date(byAdding: .day, value: offset, to: today)!
//            }
//            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
//                currentIndex = todayIndex
//                selectedDate = dateRange[todayIndex]
//            }
//        }
//        
//        // Extend backward if approaching the start
//        if index <= bufferDays {
//            let earliestDate = dateRange.first!
//            let newDates = (1...bufferDays).map { offset in
//                calendar.date(byAdding: .day, value: -offset, to: earliestDate)!
//            }.reversed()
//            dateRange.insert(contentsOf: newDates, at: 0)
//            currentIndex += bufferDays // Adjust index after inserting new dates
//        }
//        
//        // Extend forward only up to today, if needed
//        if index >= dateRange.count - bufferDays - 1 {
//            let latestDate = dateRange.last!
//            if latestDate < today { // Only extend if not yet at today
//                let daysToToday = calendar.dateComponents([.day], from: latestDate, to: today).day!
//                let daysToAdd = min(bufferDays, max(daysToToday, 0)) // Cap at today
//                let newDates = (1...daysToAdd).map { offset in
//                    calendar.date(byAdding: .day, value: offset, to: latestDate)!
//                }
//                dateRange.append(contentsOf: newDates)
//            }
//            // Prevent currentIndex from exceeding today's index
//            if let todayIndex = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
//                currentIndex = min(currentIndex, todayIndex)
//            }
//        }
//    }
//    
//    func updateCheckedCount(_ newCount: Int, totalCheckboxes: Int) {
//        var checkedCount = min(newCount, totalCheckboxes)  // Keep it within bounds
//        // You'd also save this to the database here
//    }
//    private func handleTap(index: Int, numBoxes: Int, numxCheckedBoxes: Int) {
//        let x = numxCheckedBoxes
//        // xCheckbox = numBoxes
//        let adjustedIndex = direction == .leftToRight ? index : (numBoxes - 1 - index)
//        
//        // If tapping an unchecked box
//        if adjustedIndex >= x {
//            // x = adjustedIndex + 1
//            updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
//        }
//        // If tapping a checked box
//        else {
//            // Uncheck this box and everything after it
//            // x = adjustedIndex
//            updateCheckedCount(adjustedIndex + 1, totalCheckboxes: numBoxes)
//        }
//        
//        print("Tap \(adjustedIndex)")
//        //saveToDatabase here is want to save after each tap. might be overkill and may want to just save when View Disappears
//    }
//    
//    //TBDz:: Would this be needed in production?
//    init(records: [SqlDailyTracker]) {
//        self._records = State(initialValue: records)
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                DozeHeaderView(isShowingSheet: $isShowingSheet)
//                
//                VStack {
//                   
//                        TabView(selection: $currentIndex) {
//                            
//                            ForEach(dateRange.indices, id: \.self) { index in
//                                let datex = dateRange[index]
//                                let record = recordForDate(datex)
//                                ScrollView {
//                                    VStack {
//                                        if let record = record {
//                                            Text(record.date, style: .date)
//                                            ForEach(DozeEntryViewModel.rowTypeArray, id: \.self) { item in
//                                                HStack {
//                                                    Image(item.imageName)
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .aspectRatio(contentMode: .fit)
//                                                        .frame(width: 50, height: 50)
//                                                        .padding(5)
//                                                    VStack(alignment: .leading) {
//                                                        HStack {
//                                                            
//                                                            Text(item.headingDisplay)
//                                                                .padding(5)  // system images have built-in 5 padding.  TBDz see if there's another way to align
//                                                            Spacer()
//                                                            NavigationLink(destination: DailyDozenDetailView(dataCountTypeItem: item)) {
//                                                                Image(systemName: "info.circle")
//                                                                //   .font(.system(size: 12))
//                                                                //TBDz fontsize?
//                                                                    .foregroundColor(.nfDarkGray)
//                                                            }
//                                                        } //HStack
//                                                        HStack {
//                                                            Image("ic_calendar")
//                                                                .resizable()
//                                                                .scaledToFit()
//                                                                .frame(width: 30, height: 30)
//                                                            StreakView(streak: streakCount)
//                                                            Spacer()
//                                                            HStack {
//                                                                let itemData = record.itemsDict[item]
//                                                                let count = itemData?.datacount_count ?? 0
//                                                                let boxes = item.goalServings
//                                                                ContiguousCheckboxView(n: boxes, x: count, direction: .leftToRight)
//                                                            }
//                                                        } //HStack
//                                                    } //VStack
//                                                } //HStack
//                                            }
//                                            .padding(10)
//                                            .shadowboxed()
//                                        } else { VStack {
//                                            Text("No Record")
//                                                .font(.largeTitle)
//                                            Text(datex, style: .date)
//                                        }
//                                        } //else
//                                    } //VStack
//                                } // Scroll
//                                .tag(index)
//                            }  //ForEach
//                            //  }
//                            
//                        } //TabView
//                        .tabViewStyle(.page)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .onChange(of: currentIndex) { newIndex in
//                            selectedDate = dateRange[newIndex]
//                            extendDateRangeIfNeeded(for: newIndex)
//                        } //onChange
//                   
//                    } //VStack
//               
//                    .sheet(isPresented: $isShowingSheet) {
//                        DatePickerSheetView(selectedDate: $selectedDate, dateRange: $dateRange, currentIndex: $currentIndex)
//                            .presentationDetents([.medium])
//                    } //sheet
//                    .onAppear {
//                        extendDateRangeIfNeeded(for: currentIndex)
//                    }
//                }  //Top VStack
//        } //NavStack
//    }//View body
//}
//
//#Preview {
//    ScratchView4(records: [
//        SqlDailyTracker(date: Date(timeIntervalSinceReferenceDate: 732828019)),
//        //SqlDailyTracker(date: Calendar.current.startOfDay(for: Date()),
//        SqlDailyTracker(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
//        SqlDailyTracker(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!)
//    ])
//}
