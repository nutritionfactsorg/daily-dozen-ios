//
//  DozeEntryRowView.swift
//  DailyDozen
//
//  Copyright © 2025-2026 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct DozeEntryRowView: View {
    
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    @Environment(\.dataCountAttributes) var dataCountAttributes
    private let viewModel = SqlDailyTrackerViewModel.shared
    //var streakCount = 3000// NYI TBD
    
    let item: DataCountType
    //let record: SqlDailyTracker?
    //let records: [SqlDailyTracker] = mockDB // needed?
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
                        NavigationLink(destination: DozeDetailView(dataCountTypeItem: item)) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.nfGrayDark)
                        }
                    } else {
                        Link(  destination: URL(string: "https://nutritionfacts.org/topics/vitamin-b12/")!) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.nfGrayDark)
                        }
                    }  // •TBDz• Needs URL cleanup
                }
                HStack {
                    //NavigationLink(destination: DozeCalendarView(item: item, records: records )) {
                    NavigationLink(destination: DozeCalendarView(item: item)) {
                        Image("ic_calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    StreakView(streak: streakCount)
                    Spacer()
                    HStack {
                        ContiguousCheckboxView(
                            n: item.goalServings,
                            x: $checkCount,
                            // direction: .leftToRight, // :v4: uses system locale
                            onChange: handleCountChange,
                            isDisabled: false,
                            onTap: nil
                        )
                    }
                }
            }
        } //HStack
        .padding(10)
        .shadowboxed()
        .task(handleLoadData) // runs async before view appears
        .onReceive(NotificationCenter.default.publisher(for: .sqlDBUpdated),
                   perform: handleDatabaseUpdate)
    }
    
    /// •STREAK•V21•
    @MainActor
    private func handleLoadData() async {
        print("•INFO•DB•WATCH• DozeEntryRowView handleLoadData() \(item)")
        checkCount = viewModel.getCount(for: item, date: date.startOfDay)
        Task {
            await refreshStreak()
            await MainActor.run {
                onCheck(checkCount)
            }
        }
    }

    private func handleCountChange(to newCount: Int) {
        print("•INFO•DB•WATCH• DozeEntryRowView handleCountChange() \(item)")
        guard !isUpdating else { return }
        print("•INFO•DB•WATCH• DozeEntryRowView handleCountChange() isUpdating")
        isUpdating = true
        checkCount = newCount // Immediate UI update (on main actor)

        Task {
            // •STREAK•V21•
            await viewModel.setCount(for: item, count: newCount, date: date)
            await refreshStreak()
            await MainActor.run {
                onCheck(newCount)
                isUpdating = false
            }
        }
    }

    private func handleDatabaseUpdate(_ notification: Notification) {
        //if let notifyDate = notification.object as? Date {
        //    print("•INFO•DB•WATCH• DozeEntryRowView handleDatabaseUpdate().1 \(item) notification: \(notifyDate)")
        //} else {
        //    print("•INFO•DB•WATCH• DozeEntryRowView handleDatabaseUpdate().1 \(item) notification: date unknown")
        //}
        
        guard let updatedDate = notification.object as? Date else { return }
        
        //print("•INFO•DB•WATCH• DozeEntryRowView handleDatabaseUpdate().2 \(item) A:\(updatedDate) B:\(date)")
        guard Calendar.current.isDate(updatedDate, inSameDayAs: date) else {
            //print("•INFO•DB•WATCH• DozeEntryRowView handleDatabaseUpdate().3 \(item) inSameDayAs: A != B")
            return
        }
                
        Task { @MainActor in
            //print("•INFO•DB•WATCH• DozeEntryRowView handleDatabaseUpdate().4 \(item) Task{} begin")
            checkCount = viewModel.getCount(for: item, date: date)
            await refreshStreak()
            await MainActor.run {
                onCheck(checkCount)
            }
        }
    }
    
    // •STREAK•V21•
    private func refreshStreak() async {
        streakCount = await viewModel.currentStreak(for: item, on: date)
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
