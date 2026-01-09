//
//  DozeEntryRowView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeEntryRowView: View {
    
   // @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    @Environment(\.dataCountAttributes) var dataCountAttributes
    private let viewModel = SqlDailyTrackerViewModel.shared
    //var streakCount = 3000// NYI TBD
    
    let item: DataCountType
    // let record: SqlDailyTracker?
    // let records: [SqlDailyTracker] = mockDB // needed?
    let date: Date
    let onCheck: (Int) -> Void // Callback for when checkbox changes
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
                        .font(.title3)
                        .padding(5)
                    Spacer()
                    if !supplementItems.contains(item) {
                        NavigationLink(destination: DailyDozenDetailView(dataCountTypeItem: item)) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.nfGrayDark)
                        }
                    } else {
                        Link(  destination: URL(string: "https://nutritionfacts.org/topics/vitamin-b12/")!) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.nfGrayDark)
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
                    StreakView(streak: streakCount)
                    Spacer()
                    HStack {
                        // let itemData = record.itemsDict[item]
                        
                        // let boxes = item.goalServings
                        ContiguousCheckboxView(
                            n: item.goalServings,
                            x: $checkCount,
                            // direction: .leftToRight, // :v4: Now determined by system locale
                            onChange: { newCount in
                                guard !isUpdating else { return }
                                isUpdating = true
                                checkCount = newCount
                                Task {
                                    // await viewModel.setCount(for: item, count: newCount, date: date)
                                    //                                        await viewModel.setCountAndUpdateStreak(for: item, count: newCount, date: date)
                                    //                                        print("🟢 •DozeEntryRowView• Updated \(item.typeKey) on \(date.datestampSid): count=\(newCount), streak=\(viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0)")
                                    //
                                    //                                       // streakCount = viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0
                                    //                                        onCheck(newCount)
                                    //                                        isUpdating = false
                                    await viewModel.setCountAndUpdateStreak(for: item, count: newCount, date: date)
                                    onCheck(newCount)
                                    //let streak = viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0
                                    // print("🟢 •DozeEntryRowView• Updated \(item.typeKey) on \(date.datestampSid): count=\(newCount), streak=\(streak)")
                                    streakCount = viewModel.tracker(for: date).itemsDict[item]?.datacount_streak ?? 0
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
                let localTracker = viewModel.tracker(for: date)
                
                // await viewModel.loadTracker(forDate: date.startOfDay)
                checkCount = viewModel.getCount(for: item, date: date.startOfDay)
                streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                onCheck(checkCount)
                
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .sqlDBUpdated)) { notification in
            guard let updatedDate = notification.object as? Date,
                  Calendar.current.isDate(updatedDate, inSameDayAs: date) else { return }
            
            Task {
                let localTracker = viewModel.tracker(for: date)
                checkCount = viewModel.getCount(for: item, date: date)
                streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                onCheck(checkCount)
            }
        }
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
