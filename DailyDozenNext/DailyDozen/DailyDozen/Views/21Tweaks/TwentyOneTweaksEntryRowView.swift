//
//  TwentyOneTweaksEntryiRowView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct TwentyOneTweaksEntryRowView: View {
        var streakCount = 3000// NYI TBD
        @EnvironmentObject var viewModel: SqlDailyTrackerViewModel
        let item: DataCountType
        let record: SqlDailyTracker?
        let date: Date
        let onCheck: (Int) -> Void // Callback for checkbox changes
        @State private var navigateToWeightEntry: Bool = false
        @State private var localCount: Int = 0
        @State private var count: Int = 0
        @State private var navigationPath = NavigationPath()

    private func updateCount() {
        Task { @MainActor in
            if item == .tweakWeightTwice {
                // Use viewModel.tracker instead of mockDB
                if let tracker = viewModel.tracker, Calendar.current.isDate(tracker.date, inSameDayAs: date.startOfDay) {
                    let amWeight = tracker.weightAM?.dataweight_kg ?? 0
                    let pmWeight = tracker.weightPM?.dataweight_kg ?? 0
                    let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                    if newCount != localCount {
                        count = newCount
                        localCount = newCount
                        await viewModel.setCount(for: item, count: newCount, date: date.startOfDay) // Persist count
                        onCheck(newCount)
                        //  onCheck(newCount)
                        print("🟢 •Update• Count updated for \(date.startOfDay.datestampSid): \(newCount), AM: \(amWeight), PM: \(pmWeight)")
                    } else {
                        count = newCount
                        localCount = newCount
                        // print("🟢 •Skip• No count change for \(date.startOfDay.datestampSid): \(newCount)")
                    }
                } else {
                    if 0 != localCount {
                        count = 0
                        localCount = 0
                        await viewModel.setCount(for: item, count: 0, date: date.startOfDay) // Persist count
                        onCheck(0) //TBDz this was commented out, don't recall what it does
                        print("🟢 •Update• No tracker found for \(date.startOfDay.datestampSid), count set to 0")
                    } else {
                        count = 0
                        localCount = 0
                        print("🟢 •Skip• No tracker found, no count change for \(date.startOfDay.datestampSid)")
                    }
                }
            } else {
                let newCount = record?.itemsDict[item]?.datacount_count ?? 0
                if newCount != localCount {
                    count = newCount
                    localCount = newCount
                    await viewModel.setCount(for: item, count: newCount, date: date.startOfDay) // Ensure consistency
                    onCheck(newCount)
                    print("🟢 •Update• Count set for \(date.startOfDay.datestampSid): \(item.headingDisplay) count \(newCount)")
                } else {
                    count = newCount
                    localCount = newCount
                    //print("🟢 •Skip• No count change for \(date.startOfDay.datestampSid): \(item.headingDisplay) count \(newCount)")
                }
            }
        }
    }

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
                        StreakView(streak: record?.itemsDict[item]?.datacount_streak ?? 0)
                        Spacer()
                        ContiguousCheckboxView(
                            n: item.goalServings,
                            x: $count,
                            direction: .leftToRight,
                            onChange: { newCount in
                                if item == .tweakWeightTwice {
                                    navigateToWeightEntry = true
                                } else {
                                    Task { @MainActor in
                                        await viewModel.setCount(for: item, count: newCount, date: date.startOfDay)
                                        localCount = newCount
                                        onCheck(newCount)
                                        print("🟢 •Update• Checkbox changed for \(item.headingDisplay): \(newCount)")
                                    }
                                }
                            },
                            isDisabled: item == .tweakWeightTwice,
                            onTap: item == .tweakWeightTwice ? { navigateToWeightEntry = true } : nil
                        )
                    }
                }
            }
            .padding(10)
            .shadowboxed()
            //                            
//            .navigationDestination(isPresented: $navigateToWeightEntry) {
//                WeightEntryView(initialDate: date.startOfDay)
//            }
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
                    await viewModel.loadTracker(forDate: date.startOfDay)
                    updateCount()
                }
            }
            .onChange(of: navigateToWeightEntry) { _, isActive in
                if !isActive && item == .tweakWeightTwice {
                    Task { @MainActor in
                        await viewModel.loadTracker(forDate: date.startOfDay)
                        updateCount()
                        print("🟢 •Refresh• Returned from WeightEntryView, updated count for \(date.datestampSid)")
                    }
                }
            }
            .onChange(of: viewModel.tracker) { _, newTracker in
                if item != .tweakWeightTwice, let newCount = newTracker?.itemsDict[item]?.datacount_count, newCount != localCount {
                    count = newCount
                    localCount = newCount
                    onCheck(newCount)
                    print("🟢 •Update• Tracker changed for \(date.startOfDay.datestampSid): \(item.headingDisplay) count \(newCount)")
                } else if item == .tweakWeightTwice {
                    Task { @MainActor in
                        await viewModel.loadTracker(forDate: date.startOfDay)
                        updateCount()
                        print("🟢 •Update• Tracker changed for tweakWeightTwice, updated count for \(date.datestampSid)")
                    }
                }
            }
        }
    }
    }

struct TwentyOneTweaksEntryRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockDate = Date().startOfDay
        let mockTracker = SqlDailyTracker(date: mockDate)
       // let mockDataCountType = DataCountType.tweakWeightTwice // Adjust based on your DataCountType
        return NavigationStack {
            VStack {
                TwentyOneTweaksEntryRowView(
                    item: DataCountType.dozeBeans,
                    record: mockTracker,
                    date: mockDate,
                    onCheck: { _ in }
                )
                TwentyOneTweaksEntryRowView(
                    item: .tweakWeightTwice,
                    record: mockTracker,
                    date: mockDate,
                    onCheck: { newCount in
                        print("Preview: Count updated for tweakWeightTwice: \(newCount)")
                    }
                )
            }
            .environmentObject(SqlDailyTrackerViewModel())
        }
    }
}
