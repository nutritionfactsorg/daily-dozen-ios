//
//  TweakzPageView.swift
//  DailyDozen
//
//
//

enum NavigationDestination: Hashable {
    // case detail(DataCountType)
    case calendar(DataCountType)
    case chart(String)
    // case weightEntry(Date)
}

import SwiftUI

struct TweakzPageView: View {
    let date: Date
    let coordinator: ScrollPositionCoordinator
    @State private var scrollID = UUID()  // Unique per tab view
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
            
            SyncedScrollView(coordinator: coordinator, id: scrollID, version: coordinator.version) {
                // LazyVStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(regularItems, id: \.self) { item in
                        TweakzEntryRowView(
                            item: item,
                            date: date,
                            onCheck: { _ in
                                Task {
                                    await syncRecordWithDB()
                                    
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
            print("•INFO•Appear• TweakzPageView appeared for \(date.datestampSid)")
        }
        
    }
}

//#Preview {
//    @Previewable @State var records: [SqlDailyTracker] = []
//    TweakzPageView(date: Date(), records: $records)
//}
