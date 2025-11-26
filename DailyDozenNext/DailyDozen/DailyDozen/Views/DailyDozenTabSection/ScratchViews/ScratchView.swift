//
//  ScratchView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct ScratchView: View {
    var records: [SqlDailyTracker] = returnSQLDataArray()
    let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 13))!
    let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 19))!
    
    private var dateRange: [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    var body: some View {
        VStack {
            TabView {
                ForEach(dateRange, id: \.self) { datex in
                    VStack {
                        Text(datex, style: .date)
                            .font(.headline)
                        
                        if let record = records.first(where: { record in Calendar.current.isDate(record.date, inSameDayAs: datex) }) {
                            ForEach(DozeEntryViewModel.rowTypeArray, id: \.self) {
                                item in
                                HStack {
                                    // Text(record.itemsDict[item])
                                    Text(item.headingDisplay)
                                    Text(String(record.itemsDict[item]?.datacount_count ?? 0))
                                        .font(.body)
                                    Text(String(item.goalServings))
                                    if let count = record.itemsDict[item]?.datacount_count {
                                        ForEach(0..<item.goalServings, id: \.self) { index in
                                            CheckboxView(isChecked: index < count)
                                            //                                            Image(systemName: index < count ? "checkmark.square.fill" : "square")
                                            //                                                .resizable()
                                            //                                                .frame(width: 20, height: 20)
                                            //                                                .foregroundColor(index < count ? .brandGreen : .grayLight)
                                            //                                                .fontWeight(.heavy)
                                            //                                                .onTapGesture {
                                            //                                                           print("tapped")
                                            //
                                                .simultaneousGesture(TapGesture().onEnded {
                                                    print("Tap \(index)")
                                                })
                                        }
                                    }
                                    //ForEach(0..<item.goalServings, id: \.self) { index in
                                    // Text(index)
                                    //var x: Int = record.itemsDict[item]?.datacount_count
                                    //                                        var x = 2
                                    //                                        Image(systemName: index <= x ? "checkmark.square.fill" : "square")
                                    //                                            .foregroundColor(x ? .blue : .gray)
                                    // Text("hello")
                                    //                                    if index <= record.itemsDict[item]?.datacount_count{
                                    //                                            Image(systemName: "checkmark.square.fill")}
                                    //                                    else {
                                    //                                        Image(systemName: "square")}
                                    //  }
                                }//HStack
                            }//ForEach Outer
                            
                            //                          Text(String(record.itemsDict[.dozeGreens]?.datacount_count ?? 0))
                            //                                .font(.body)
                        } else {
                            Text("No data available")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onDisappear {
                        print("SwipeView disappeared! Save Changes")
                    }
                }
            }
            .tabViewStyle(.page)
        }
        .onAppear {
            //dailyInfos = returnSQLDataArray()
        }
    }
}

#Preview {
    ScratchView()
}
