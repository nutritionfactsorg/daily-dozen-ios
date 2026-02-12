//
//  DozePageView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import StoreKit

@preconcurrency
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DozePageView: View {
    private let viewModel = SqlDailyTrackerViewModel.shared
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    @Environment(\.requestReview) var requestReview
    let coordinator: ScrollPositionCoordinator
    
    let date: Date
    @State private var showingAlert = false
    @State private var showStarImage = false
    @State private var dozeDailyStateCount: Int = 0
    @State private var scrollID = UUID()  // Unique per tab view
    
    private let dozeDailyStateCountMaximum = 24
    
    private var regularItems: [DataCountType] {
        DozeEntryViewModel.rowTypeArray.filter { $0 != .otherVitaminB12 }
    }
    
    private var supplementItems: [DataCountType] {
        DozeEntryViewModel.rowTypeArray.filter { $0 == .otherVitaminB12 }
    }
    
    private func syncRecordWithDB() async {
        let localTracker = viewModel.tracker(for: date)
        
        let count = regularItems.reduce(0) { total, type in
            total + (localTracker.itemsDict[type]?.datacount_count ?? 0)
        }
        
        dozeDailyStateCount = count
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("doze_entry_header")
                Spacer()
                if showStarImage {
                    Image("ic_star")
                        .onAppear {
                            requestReview()
                        }
                }
                Text("\(dozeDailyStateCount)/\(dozeDailyStateCountMaximum)")
                NavigationLink {
                    ServingsHistoryView(filterType: .doze)
                        .environmentObject(SqlDailyTrackerViewModel())
                } label: {
                    Image("ic_stat")
                }
            }
            .padding(10)
            
            SyncedScrollView(coordinator: coordinator, id: scrollID, version: coordinator.version) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(regularItems, id: \.self) { item in
                        DozeEntryRowView(
                            item: item,
                            date: date,
                            onCheck: { _ in
                                Task {
                                    await syncRecordWithDB()
                                    showStarImage = dozeDailyStateCount == dozeDailyStateCountMaximum
                                }
                            }
                        )
                    }
                    
                    if !supplementItems.isEmpty {
                        HStack {
                            Text("dozeOtherInfo.section")
                                .font(.headline)
                                .foregroundColor(.primary)  // optional: ensure visibility
                           // Spacer()
                            Button {
                                showingAlert.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.nfGrayDark)
                                    .font(.headline)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)  // match row horizontal padding; adjust as needed
                        .padding(.top, 20)         // keeps separation from previous row
                        .padding(.bottom, 15)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.clear)   // optional: ensures no layout surprises

                        ForEach(supplementItems, id: \.self) { item in
                            DozeEntryRowView(
                                item: item,
                                date: date,
                                onCheck: { _ in
                                    Task { @MainActor in
                                        await syncRecordWithDB()
                                    }
                                }
                            )
                        }
                    }
                }
                //.padding(.horizontal)
                // Capture scroll offset
                //.padding(.top, 30)
                //.padding(.bottom, 40)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("dozeOtherInfo.title"), message: Text("dozeOtherInfo.message"))
        }
        .onAppear {
            Task { await syncRecordWithDB() }
        }
    }
}

//#Preview {
//    DozePageView(date: Date(), scrollOffset:)
//        .environmentObject(SqlDailyTrackerViewModel())
//}
