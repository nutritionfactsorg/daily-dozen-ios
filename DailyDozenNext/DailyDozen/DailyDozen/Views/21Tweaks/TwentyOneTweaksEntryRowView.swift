//
//  TwentyOneTweaksEntryiRowView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TwentyOneTweaksEntryRowView: View {
        //var streakCount = 3000// NYI TBD
        @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
        @Environment(\.dataCountAttributes) var dataCountAttributes
        let item: DataCountType
        let date: Date
        let onCheck: (Int) -> Void // Callback for checkbox changes
        @State private var navigateToWeightEntry: Bool = false
       // @State private var localCount: Int = 0
        @State private var checkCount: Int = 0
        @State private var navigationPath = NavigationPath()
        @State private var isUpdating: Bool = false
        @State private var streakCount: Int = 0
        //added for concurrency
       // @State private var headingDisplay: String = "Loading..."
        //@State private var localStreak: Int = 0
    
//    private func updateCount() async {
//            await viewModel.loadTracker(forDate: date.startOfDay)
//            if item == .tweakWeightTwice {
//                // Use viewModel.tracker instead of mockDB
//             //   if let tracker = viewModel.tracker, Calendar.current.isDate(tracker.date, inSameDayAs: date.startOfDay) {
//                    let tracker = viewModel.tracker(for: date.startOfDay)
//                    let amWeight = tracker.weightAM?.dataweight_kg ?? 0
//                    let pmWeight = tracker.weightPM?.dataweight_kg ?? 0
//                    let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
//                    if newCount != localCount {
//                        count = newCount
//                        localCount = newCount
//                        await viewModel.setCount(for: item, count: newCount, date: date.startOfDay) // Persist count
//                        onCheck(newCount)
//                        //  onCheck(newCount)
//                        print("🟢 •Update• Count updated for \(date.startOfDay.datestampSid): \(newCount), AM: \(amWeight), PM: \(pmWeight)")
//                    } else {
//                        count = newCount
//                        localCount = newCount
//                        // print("🟢 •Skip• No count change for \(date.startOfDay.datestampSid): \(newCount)")
//                    }
//                } else {
//                    let newCount = viewModel.getCount(for: item)
//                                    if newCount != localCount {
//                                        count = newCount
//                                        localCount = newCount
//                                        //await viewModel.setCount(for: item, count: newCount, date: date.startOfDay) // Ensure consistency
//                                        onCheck(newCount)
//                                        print("🟢 •Update• Count set for \(date.startOfDay.datestampSid): \( item.headingDisplay) count \(newCount)")
//                                    } else {
//                                        count = newCount
//                                        localCount = newCount
//                                        //print("🟢 •Skip• No count change for \(date.startOfDay.datestampSid): \(item.headingDisplay) count \(newCount)")
//                }
//            }
//            localStreak = viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0
//        }

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                        NavigationLink(destination: TwentyOneDetailView(dataCountTypeItem: item)) {
                            // NavigationLink(destination: TwentyOneDetailView(dataCountTypeItem: item)) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.nfDarkGray)
                        }
                    }
                    HStack {
                        if item == .tweakWeightTwice {
                            NavigationLink(value: "chart") {
                           // NavigationLink(value: NavigationDestination.chart("chart")) {
                                Image("ic_calendar")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        } else {
                            NavigationLink(destination: DozeCalendarView(item: item)) {
                            //NavigationLink(value: NavigationDestination.calendar(item)) {
                                Image("ic_calendar")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        }
                       // StreakView(streak: viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0)
                        StreakView(streak: streakCount)
                        Spacer()
                        ContiguousCheckboxView(
                            n: item.goalServings,
                            x: $checkCount,
                            direction: .leftToRight,
                            onChange: { newCount in
                                guard !isUpdating else { return}
                                isUpdating = true
                                checkCount = newCount
                                if item == .tweakWeightTwice {
                                    navigateToWeightEntry = true
                                    //isUpdating = false
                                } else {
                                    Task {
                                        await viewModel.setCountAndUpdateStreak(for: item, count: newCount, date: date)
                                        // localCount = newCount
                                      //  checkCount = newCount
                                        onCheck(newCount)
                                        streakCount = viewModel.tracker(for: date).itemsDict[item]?.datacount_streak ?? 0
                                       // isUpdating = false
                                    }
                                }
                                isUpdating = false
                            },
                            isDisabled: item == .tweakWeightTwice,
                            onTap: item == .tweakWeightTwice ? { navigateToWeightEntry = true } : nil
                        )
                    }
                }
            }
            .padding(10)
            .shadowboxed()

            .navigationDestination(for: DataCountType.self) { item in
                TwentyOneDetailView(dataCountTypeItem: item)
            }
            .navigationDestination(for: String.self) { value in
                if value == "chart" {
                    WeightChartView()
                }
            }
            
            .navigationDestination(for: Date.self) { date in
                WeightEntryView(initialDate: date)
            }
            .navigationDestination(isPresented: $navigateToWeightEntry) {
                 WeightEntryView(initialDate: date.startOfDay)
                       }
            
            //  }
            // End Nav
            .onAppear {
                Task { @MainActor in
                    let localTracker = viewModel.tracker(for: date)
//
                    if item == .tweakWeightTwice {
                       // await viewModel.loadTracker(forDate: date)
                        // Derive count from saved weights (read-only, no save needed here)
                       // let localTracker = viewModel.tracker! // Safe after load
                        let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
                        let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
                        let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                        checkCount = newCount
                       // streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                        // onCheck(newCount) // Notify parent to refresh sum (e.g., header "X/37")
                        print("🟢 •Load• Derived weight count for \(date.datestampSid): \(newCount) (AM: \(amWeight > 0), PM: \(pmWeight > 0))")
                    } else {
                        // For normal items, load existing count from DB (read-only)
                        checkCount = viewModel.getCount(for: item, date: date)
                       
//                        print("🟢 date.startOfDay: \(date.startOfDay)")
//                        print("🟢 date.startOfDay.datestampSid: \(date.startOfDay.datestampSid)")
//                        print("🟢 viewModel.tracker?.date.datestampSid: \(viewModel.tracker?.date.datestampSid ?? "nil")")
//                       // onCheck(checkCount) // Notify parent to refresh sum
//                        //streakCount = tracker.itemsDict[item]?.datacount_streak ?? 0
//                        print("🟢 •Load• Loaded count for \(date.datestampSid) \(item.headingDisplay): \(checkCount)")
                    }
                    streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                    onCheck(checkCount)  //Notify parent to refresh sum
                }
            }
            .onChange(of: navigateToWeightEntry) { _, isActive in
                if !isActive && item == .tweakWeightTwice {
                    Task {
                        // After returning from WeightEntryView (where weights were saved via savePendingWeights())
                      //  await viewModel.loadTracker(forDate: date.startOfDay) // Reload fresh weights
                        let localTracker = viewModel.tracker(for: date)
                        let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
                        let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
                        let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                        checkCount = newCount
                       // onCheck(newCount) // Notify parent to refresh sum
                        streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                        onCheck(checkCount)
                        print("🟢 •Refresh• Returned from WeightEntryView, derived count for \(date.datestampSid): \(newCount)")
                    }
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: .mockDBUpdated)) { _ in
                Task {
                    let localTracker = viewModel.tracker(for: date)
                    // On global DB update (e.g., from WeightEntryView savePendingWeights()), reload
                   // await viewModel.loadTracker(forDate: date.startOfDay)
                    if item == .tweakWeightTwice {
                       
                        let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
                        let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
                        let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                        checkCount = newCount
                        
                       // onCheck(newCount)
                        print("🟢 •Receive• Derived weight count for \(date.datestampSid): \(newCount)")
                    } else {
                        checkCount = viewModel.getCount(for: item, date: date)  // add date?
                       // onCheck(checkCount)
                      //  streakCount = tracker?.itemsDict[item]?.datacount_streak ?? 0
                        print("🟢🟢🟢 •Receive• Loaded count for \(date.datestampSid) \(item.headingDisplay): \(checkCount)")
                    }
                    streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                    onCheck(checkCount)
                }
            }
            //            .onChange(of: viewModel.tracker) { _, newTracker in
            //                if item != .tweakWeightTwice, let newCount = newTracker?.itemsDict[item]?.datacount_count, newCount != localCount {
            //                    count = newCount
            //                    localCount = newCount
            //                    onCheck(newCount)
            //                    print("🟢 •Update• Tracker changed for \(date.startOfDay.datestampSid): \(item.headingDisplay) count \(newCount)")
//                } else if item == .tweakWeightTwice {
//                    Task { @MainActor in
//                        await viewModel.loadTracker(forDate: date.startOfDay)
//                        await updateCount()
//                        print("🟢 •Update• Tracker changed for tweakWeightTwice, updated count for \(date.datestampSid)")
//                    }
//                }
//            } //onChange
        }
    }
    }

//struct TwentyOneTweaksEntryRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Mock data for preview
//        let mockDate = Date().startOfDay
//        let mockTracker = SqlDailyTracker(date: mockDate)
//       // let mockDataCountType = DataCountType.tweakWeightTwice // Adjust based on your DataCountType
//        return NavigationStack {
//            VStack {
//                TwentyOneTweaksEntryRowView(
//                    item: DataCountType.dozeBeans,
//                    record: mockTracker,
//                    date: mockDate,
//                    onCheck: { _ in }
//                )
//                TwentyOneTweaksEntryRowView(
//                    item: .tweakWeightTwice,
//                    record: mockTracker,
//                    date: mockDate,
//                    onCheck: { newCount in
//                        print("Preview: Count updated for tweakWeightTwice: \(newCount)")
//                    }
//                )
//            }
//            .environmentObject(SqlDailyTrackerViewModel())
//        }
//    }
//}
