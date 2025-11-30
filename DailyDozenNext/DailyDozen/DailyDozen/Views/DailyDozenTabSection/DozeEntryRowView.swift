//
//  DozeEntryRowView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeEntryRowView: View {
    
    @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    //var streakCount = 3000// NYI TBD
    
    let item: DataCountType
   // let record: SqlDailyTracker?
   // let records: [SqlDailyTracker] = mockDB // needed?
    let date: Date
    let onCheck: (Int) -> Void // Callback for when checkbox changes
   // @State private var localCount: Int = 0
    @State private var checkCount: Int = 0 // Initialize with default
    @State private var isUpdating: Bool = false
    @State private var streakCount: Int = 0 // Cache streak to avoid tracker updates
    private var regularItems: [DataCountType] {
            DozeEntryViewModel.rowTypeArray.filter { $0 != .otherVitaminB12 }
        }
        
        private var supplementItems: [DataCountType] {
            DozeEntryViewModel.rowTypeArray.filter { $0 == .otherVitaminB12 }
        }
    
    var body: some View {
       
            HStack {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .padding(5)
                VStack(alignment: .leading) {
                    HStack {
                        
                        Text(item.headingDisplay)
                            .padding(5)
                        Spacer()
                        if !supplementItems.contains(item) {
                            NavigationLink(destination: DailyDozenDetailView(dataCountTypeItem: item)) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.nfDarkGray)
                            }
                        } else {
                            Link(  destination: URL(string: "https://nutritionfacts.org/topics/vitamin-b12/")!) {
                                            Image(systemName: "info.circle")
                                    .foregroundColor(.nfDarkGray)
                                        }
                        }  //TBDz!!::  Needs URL cleanup
                    }
                    HStack {
                        //NavigationLink(destination: DozeCalendarView(item: item, records: records )) {
                        NavigationLink(destination: DozeCalendarView(item: item)) {
                            Image("ic_calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        //StreakView(streak: streakCount)
                        StreakView(streak: viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0) // guess at what this might be when implemented
                        Spacer()
                        HStack {
                            // let itemData = record.itemsDict[item]
                           
                           // let boxes = item.goalServings
                            ContiguousCheckboxView(
                                n: item.goalServings,
                                x: $checkCount,
                                direction: .leftToRight,
                                onChange: { newCount in
                                    guard !isUpdating else { return }
                                    isUpdating = true
                                    checkCount = newCount
                                    Task { @MainActor in
                                        await viewModel.setCount(for: item, count: newCount, date: date)
                                        streakCount = viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0
                                        onCheck(newCount)
                                        isUpdating = false
                                    }
                                },
                                isDisabled: false,
                                onTap: nil
                            )
                            
                        }
                    }
                }
            } //HStack
            .padding(10)
            .shadowboxed()
            .onAppear {
                Task { @MainActor in
                    checkCount = viewModel.getCount(for: item)
                    streakCount = viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0
                     //  await viewModel.loadTracker(forDate: date)
                       //checkCount = viewModel.tracker?.itemsDict[item]?.datacount_count ?? 0
                      // checkCount = viewModel.getCount(for: item)
                           }
                    }
//            .onChange(of: viewModel.tracker?.itemsDict[item]?.datacount_count) { _, newCount in
//                        checkCount = newCount ?? 0
//                    }
        //else is for supplements
//        else {
//            HStack {
//                Image(item.imageName)
//                    .resizable()
//                    .scaledToFit()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 50, height: 50)
//                    .padding(5)
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text(item.headingDisplay)
//                            .padding(5)
//                        Spacer()
////                        if !item.topic.isEmpty {
////                            Link(destination: LinksService.shared.link(topic: item.topic)) {
////                                Text("videos.link.label")
////                            }
////                        }
////                        NavigationLink(destination: DailyDozenDetailView(dataCountTypeItem: item)) {
//                       
//                            Link(  destination: URL(string: "https://nutritionfacts.org/topics/vitamin-b12/")!) {
//                                            Image(systemName: "info.circle")
//                                    .foregroundColor(.nfDarkGray)
//                                        }
//                           
//                      //  }
//                    }
//                    HStack {
//                        Image("ic_calendar")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                        //StreakView(streak: streakCount)
//                        StreakView(streak: record?.itemsDict[item]?.datacount_streak ?? 0) // guess at what this might be when implemented
//                        Spacer()
//                        HStack {
//                            // let itemData = record.itemsDict[item]
//                            let count = record?.itemsDict[item]?.datacount_count ?? localCount
//                            let boxes = item.goalServings
//                            ContiguousCheckboxView(
//                                n: boxes,
//                                x: count,
//                                direction: .leftToRight,
//                                onChange: { newCount in
//                                    if record == nil {
//                                        localCount = newCount
//                                        onCheck(newCount)
//                                    } else {
//                                        onCheck(newCount)
//                                    }
//                                }
//                            )
//                        }
//                    }
//                    .padding(10)
//                    .shadowboxed()
//                }
//            }
//        }  //temp else
    }
}

//#Preview {
//    struct PreviewWrapper: View {
//        @StateObject private var viewModel = SqlDailyTrackerViewModel()
//        
//        var body: some View {
//            DozeEntryRowView(
//                item: .dozeBeans,
//                date: Date(),
//                onCheck: { newCount in
//                    Task { @MainActor in
//                        await viewModel.setCount(for: .dozeBeans, count: newCount, date: Date())
//                    }
//                }
//            )
//            .environmentObject(viewModel)
//        }
//    }
//    
