//
//  TwentyOnePageView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

enum NavigationDestination: Hashable {
    // case detail(DataCountType)
    case calendar(DataCountType)
    case chart(String)
    // case weightEntry(Date)
}

import SwiftUI

struct TwentyOnePageView: View {
    let date: Date
    let coordinator: ScrollPositionCoordinator
    
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    private let viewModel = SqlDailyTrackerViewModel.shared
    @State private var showingAlert = false
    @State private var showStarImage = false
    @State private var localTweakStateCount: Int = 0
    
    private let tweakStateCountMaximum = 37
    
    private var regularItems: [DataCountType] {
        TweakEntryViewModel.rowTypeArray
    }
    
    private func syncRecordWithDB() async {
        let localTracker = viewModel.tracker(for: date)
        localTweakStateCount = localTracker.itemsDict
            .filter { TweakEntryViewModel.rowTypeArray.contains($0.key) }
            .reduce(0) { $0 + $1.value.datacount_count }
       // print("🟢 •Sync• Updated localTweakStateCount for \(date.datestampSid): \(localTweakStateCount)")
       // print("🟢 SYNC CALLED for \(date.ISO8601Format().prefix(10)): itemsDict.count = \(localTracker.itemsDict.count)")
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("tweak_entry_header")
                Spacer()
                if showStarImage {
                    Image("ic_star")
                }
                Text("\(localTweakStateCount)/\(tweakStateCountMaximum)")
                
                NavigationLink {
                    ServingsHistoryView(filterType: .tweak)
                        .environmentObject(SqlDailyTrackerViewModel())
                } label: {
                    Image("ic_stat")
                }
            }
            .padding(10)
            
            SyncedScrollView(coordinator: coordinator, version: coordinator.version) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(regularItems, id: \.self) { item in
                                TwentyOneTweaksEntryRowView(
                                    item: item,
                                    date: date,
                                    onCheck: { _ in
                                        Task {
                                            await syncRecordWithDB()
//                                            print("🟢 •Parent• onCheck called for \(item.headingDisplay) on \(date.datestampSid) (no action needed)")
                                        }
                                    }
                                )
                                .id(item) // Ensure stable identity
                      } //For Each
                } //VStack
            } //Sync
        } //VStack
        .onAppear {
            Task { await syncRecordWithDB() }
            print("🟢 •Appear• TwentyOnePageView appeared for \(date.datestampSid)")
        }
//        .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
//            Task { await syncRecordWithDB() }
//        }
        .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { notification in
            guard let updatedDate = notification.object as? Date,
                  Calendar.current.isDate(updatedDate, inSameDayAs: date) else { return }
            Task { await syncRecordWithDB() }
        }
        
    }
}

//#Preview {
//    @Previewable @State var records: [SqlDailyTracker] = []
//    TwentyOnePageView(date: Date(), records: $records)
//}
