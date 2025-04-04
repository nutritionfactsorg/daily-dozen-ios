//
//  DozeEntryRowView.swift
//  DailyDozen
//
//  Created by mc on 3/27/25.
//

import SwiftUI

struct DozeEntryRowView: View {
    var streakCount = 3000// NYI TBD
    
    let item: DataCountType
    let record: SqlDailyTracker?
    let date: Date
    let onCheck: (Int) -> Void // Callback for when checkbox changes
    @State private var localCount: Int = 0
    
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
                        Image("ic_calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        //StreakView(streak: streakCount)
                        StreakView(streak: record?.itemsDict[item]?.datacount_streak ?? 0) // guess at what this might be when implemented
                        Spacer()
                        HStack {
                            // let itemData = record.itemsDict[item]
                            let count = record?.itemsDict[item]?.datacount_count ?? localCount
                            let boxes = item.goalServings
                            ContiguousCheckboxView(
                                n: boxes,
                                x: count,
                                direction: .leftToRight,
                                onChange: { newCount in
                                    if record == nil {
                                        localCount = newCount
                                        onCheck(newCount)
                                    } else {
                                        onCheck(newCount)
                                    }
                                }
                            )
                        }
                    }
                }
            } //HStack
            .padding(10)
            .shadowboxed()
        
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

#Preview {
    // Wrapper to provide mock data and handle onCheck
    struct PreviewWrapper: View {
        @State private var mockCount: Int = 0
        
        var body: some View {
            DozeEntryRowView(
                item: .dozeBeans, // Example item
                record: nil, // Test no-record case; use mockRecord for record case
                date: Date(),
                onCheck: { newCount in
                    // Mock callback: update local state and log for preview
                    mockCount = newCount
                    print("Preview: Checkbox changed to \(newCount)")
                }
            )
        }
    }
    
    return PreviewWrapper()
}
#Preview {
    struct PreviewWrapper: View {
        @State private var mockCount: Int = 0
        
        // Mock record for testing the "record exists" case
        let mockRecord = SqlDailyTracker(
            date: Date(),
            itemsDict: [
                DataCountType.dozeBeans: SqlDataCountRecord(datacount_date_psid: "2025-03-28", datacount_kind_pfnid: 1, datacount_count: 3, datacount_streak: 5)!
            ]
        )
        
        var body: some View {
            DozeEntryRowView(
                item: .dozeBeans,
                record: mockRecord, // Test with record
                date: Date(),
                onCheck: { newCount in
                    mockCount = newCount
                    print("Preview: Checkbox changed to \(newCount)")
                }
            )
        }
    }
    
    return PreviewWrapper()
}
