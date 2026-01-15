//
//  DozeTabPageView.swift
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

struct DozeTabPageView: View {
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
            
            // Use LazyVStack inside ScrollView for performance
            SyncedScrollView(coordinator: coordinator, id: scrollID, version: coordinator.version) {
                LazyVStack(alignment: .leading, spacing: 0) {
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
                        VStack {
                            HStack {
                                Text("dozeOtherInfo.section")
                                    .font(.headline)
                                    .padding(.top, 20)
                                    .padding(.horizontal, 8)
                                Button {
                                    showingAlert.toggle()
                                } label: {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.nfGrayDark)
                                }
                                .buttonStyle(.plain)
                            } //HStack
                        } //VStack
                                
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                        
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
               // .padding(.horizontal)
                // Capture scroll offset
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("dozeOtherInfo.title"), message: Text("dozeOtherInfo.message"))
        }
        .onAppear {
            Task { await syncRecordWithDB() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .sqlDBUpdated)) { notification in
            guard let updatedDate = notification.object as? Date,
                  Calendar.current.isDate(updatedDate, inSameDayAs: date) else { return }
            Task { await viewModel.loadTracker(forDate: date) }
        }
    }
}

//#Preview {
//    DozeTabPageView(date: Date(), scrollOffset:)
//        .environmentObject(SqlDailyTrackerViewModel())
//}
