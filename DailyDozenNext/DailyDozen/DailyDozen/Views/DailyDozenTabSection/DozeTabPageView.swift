//
//  DozeTabPageView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import StoreKit

struct DozeTabPageView: View {
    @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    @Environment(\.requestReview) var requestReview
    let date: Date
    @State private var showingAlert = false
    @State private var showStarImage = false
    @State private var dozeDailyStateCount: Int = 0
    
    private let dozeDailyStateCountMaximum = 24
    
    private var regularItems: [DataCountType] {
        DozeEntryViewModel.rowTypeArray.filter { $0 != .otherVitaminB12 }
    }
    
    private var supplementItems: [DataCountType] {
        DozeEntryViewModel.rowTypeArray.filter { $0 == .otherVitaminB12 }
    }
    
    private func syncRecordWithDB() async {
        
        let localTracker = viewModel.tracker(for: date)
        dozeDailyStateCount = localTracker.itemsDict
            .filter { DozeEntryViewModel.rowTypeArray.contains($0.key) }
            .reduce(0) { $0 + $1.value.datacount_count } ?? 0
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
                    DozeServingsHistoryView()
                        .environmentObject(SqlDailyTrackerViewModel())
                } label: {
                    Image("ic_stat")
                }
            }
            .padding(10)
            
            ScrollView {
                VStack {
                    ForEach(regularItems, id: \.self) { item in
                        DozeEntryRowView(
                            item: item,
                            date: date,
                            onCheck: { _ in
                                Task {
                                    await syncRecordWithDB()
                                  //  @MainActor in
                                   // await viewModel.setCount(for: item, count: count, date: date)
                                    showStarImage = dozeDailyStateCount == dozeDailyStateCountMaximum
                                }
                            }
                        )
                    }
                    if !supplementItems.isEmpty {
                        HStack {
                            Text("dozeOtherInfo.section")
                                .font(.headline)
                                .padding(.top, 20)
                                .padding(.horizontal, 10)
                            Button {
                                showingAlert.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.nfDarkGray)
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("dozeOtherInfo.title"), message: Text("dozeOtherInfo.message"))
                            }
                        }
                        
                        ForEach(supplementItems, id: \.self) { item in
                            DozeEntryRowView(
                                item: item,
                                date: date,
                                onCheck: { _ in
                                    Task { @MainActor in
                                        await syncRecordWithDB()
//                                        await viewModel.setCount(for: item, count: count, date: date)
//                                        dozeDailyStateCount = viewModel.tracker?.itemsDict
//                                            .filter { $0.key.isDailyDozen && DozeEntryViewModel.rowTypeArray.contains($0.key) }
//                                            .reduce(0) { $0 + $1.value.datacount_count } ?? 0
//                                        showStarImage = dozeDailyStateCount == dozeDailyStateCountMaximum
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            
            Task { await syncRecordWithDB()}
//            Task { @MainActor in
//             //   await viewModel.loadTracker(forDate: date)
//                dozeDailyStateCount = viewModel.tracker?.itemsDict
//                    .filter { $0.key.isDailyDozen && DozeEntryViewModel.rowTypeArray.contains($0.key) }
//                    .reduce(0) { $0 + $1.value.datacount_count } ?? 0
//                showStarImage = dozeDailyStateCount == dozeDailyStateCountMaximum
            }
        }
    }


#Preview {
    DozeTabPageView(date: Date())
        .environmentObject(SqlDailyTrackerViewModel())
}
