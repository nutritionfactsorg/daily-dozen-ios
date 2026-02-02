//
//  TweakzEntryRowView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

enum RowNavigationDestination: Hashable {
    case weightEntry(Date)
    // Add other cases if needed, e.g., .detail(DataCountType)
}

struct TweakzEntryRowView: View {
    
    private let viewModel = SqlDailyTrackerViewModel.shared
    @Environment(\.dataCountAttributes) var dataCountAttributes
    let item: DataCountType
    let date: Date
    let onCheck: (Int) -> Void // Callback for checkbox changes
    //@State private var navigateToWeightEntry: Bool = false
    //@State private var localCount: Int = 0
    @State private var checkCount: Int = 0
    @State private var navigationPath = NavigationPath()
    @State private var isUpdating: Bool = false
    @State private var streakCount: Int = 0
    @State private var isNavigatingToWeight: Bool = false  // state to control navigation
    
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
                            .font(.title3)
                            .padding(5)
                        Spacer()
                        NavigationLink(destination: TweakzDetailView(dataCountTypeItem: item)) {
                            // NavigationLink(destination: TweakzDetailView(dataCountTypeItem: item)) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.nfGrayDark)
                        }
                    }
                    HStack {
                        if item == .tweakWeightTwice {
                            NavigationLink(destination: WeightChartView()) {
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
                        StreakView(streak: streakCount)
                        Spacer()
                        ContiguousCheckboxView(
                            n: item.goalServings,
                            x: $checkCount,
                            // direction: .leftToRight, // :v4: uses system locale
                            onChange: handleCountChange,
                            isDisabled: item == .tweakWeightTwice,
                            onTap: item == .tweakWeightTwice ? {
                                print("•TRACE•DB• onTap called for weight on \(date.datestampSid)")
                                // navigationPath.append(date.startOfDay) } : nil
                                isNavigatingToWeight = true} : nil
                        )
                    }
                }
            }
            .padding(10)
            .shadowboxed()
            
            .navigationDestination(for: DataCountType.self) { item in
                TweakzDetailView(dataCountTypeItem: item)
            }
            
            .navigationDestination(for: Date.self) { date in
                WeightEntryView(initialDate: date.startOfDay)
                    .onDisappear {  // Clear path when disappearing (back navigation)
                        navigationPath = NavigationPath()
                    }
            }
            
            //  }
            // End Nav
            .task(handleLoadData) // runs async before view appears
            
            //.onChange(of: navigateToWeightEntry) { _, isActive in
            //    if !isActive && item == .tweakWeightTwice {
            //        Task {
            //            // After returning from WeightEntryView (where weights were saved via savePendingWeights())
            //            let localTracker = viewModel.tracker(for: date)
            //            let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
            //            let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
            //            let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
            //            checkCount = newCount
            //            // onCheck(newCount) // Notify parent to refresh sum
            //            await refreshStreak()
            //            onCheck(checkCount)
            //            print("•INFO•Refresh• Returned from WeightEntryView, derived count for \(date.datestampSid): \(newCount)")
            //        }
            //    }
            //}
            
            .onChange(of: isNavigatingToWeight) { _, newValue in
                print("•INFO•DB•WATCH• TweaksEntryRowView .onChange(of: isNavigatingToWeight)")
                if newValue && navigationPath.count == 0 {  // Only append if not already navigating
                    print("•INFO•DB•WATCH• TweaksEntryRowView .onChange(of: isNavigatingToWeight) append \(date.startOfDay)")
                    navigationPath.append(date.startOfDay)
                } else if !newValue {
                    // Optional: Force clear if needed, but back button should handle pop
                }
            }
            .onChange(of: navigationPath, handleNavChange)
            .onReceive(NotificationCenter.default.publisher(for: .sqlDBUpdated),
                       perform: handleDatabaseUpdate)
        }
    }
    
    /// •STREAK•V21•
    @MainActor
    private func handleLoadData() async {
        //print("•INFO•DB•WATCH• TweaksEntryRowView handleLoadData() \(item)")
        let localTracker = viewModel.tracker(for: date)
        //
        if item == .tweakWeightTwice {
            print("•INFO•DB•WATCH• TweaksEntryRowView handleLoadData() == .tweakWeightTwice")
            // await viewModel.loadTracker(forDate: date)
            // Derive count from saved weights (read-only, no save needed here)
            // let localTracker = viewModel.tracker! // Safe after load
            let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
            let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
            let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
            checkCount = newCount
            print("•INFO•Load• Derived weight count for \(date.datestampSid): \(checkCount) (AM: \(amWeight > 0), PM: \(pmWeight > 0))")
        } else {
            // For normal items, load existing count from DB (read-only)
            checkCount = viewModel.getCount(countType: item, date: date.startOfDay)
        }
        Task {
            await refreshStreak()
            await MainActor.run {
                onCheck(checkCount)
            }
        }
    }

    private func handleCountChange(to newCount: Int) {
        print("•INFO•DB•WATCH• TweaksEntryRowView handleCountChange() \(item)")
        guard !isUpdating else { return }
        print("•INFO•DB•WATCH• TweaksEntryRowView handleCountChange() isUpdating")
        isUpdating = true
        checkCount = newCount // Immediate UI update (on main actor)
        
        if item == .tweakWeightTwice {
            isNavigatingToWeight = true
            //navigationPath.append(date.startOfDay)
            //isUpdating = false
        } else {
            Task {
                await viewModel.setCount(countType: item, count: newCount, date: date)
                await refreshStreak()
                await MainActor.run {
                    onCheck(checkCount)
                    isUpdating = false   // PlzDoubleCheck
                }
            }
        }
        //isUpdating = false  // PlzCheck
    }
    
    private func handleNavChange(oldPath: NavigationPath, newPath: NavigationPath) {
        print("•INFO•Refresh•WATCH• TweakzEntryRowView handleNavChange")
        if newPath.count == 0 && oldPath.count > 0 && item == .tweakWeightTwice {
            isNavigatingToWeight = false  // Reset the flag here on return
            Task {
                let localTracker = viewModel.tracker(for: date)
                let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
                let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
                let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                checkCount = newCount
                await refreshStreak()
                await MainActor.run {
                    onCheck(checkCount)
                }
                print("•INFO•Refresh• Returned from WeightEntryView, derived count for \(date.datestampSid): \(newCount)")
            }
        }
    }

    private func handleDatabaseUpdate(_ notification: Notification) {
        let watchItemType = DataCountType.tweakWeightTwice
        if item == watchItemType {
            if let notifyDate = notification.object as? Date {
                print("•INFO•DB•WATCH• TweaksEntryRowView handleDatabaseUpdate().1 \(item) notification: \(notifyDate)")
            } else {
                print("•INFO•DB•WATCH• TweaksEntryRowView handleDatabaseUpdate().2 \(item) notification: date unknown")
            }
           
        }
        
        guard let updatedDate = notification.object as? Date else { return }
        
        if item == watchItemType {
            print("•INFO•DB•WATCH• TweaksEntryRowView handleDatabaseUpdate().3 \(item) A:\(updatedDate) B:\(date)")
        }
        guard Calendar.current.isDate(updatedDate, inSameDayAs: date) else {
            if item == watchItemType {
                print("•INFO•DB•WATCH• TweaksEntryRowView handleDatabaseUpdate().4 \(item) inSameDayAs: A != B")
            }
            return
        }
                
        Task { @MainActor in
            let localTracker = viewModel.tracker(for: date)
            if item == .tweakWeightTwice {
                let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
                let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
                let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                checkCount = newCount
                print("•INFO•Receive• Derived weight count for newCount \(date.datestampSid): \(newCount)")
            } else {
                checkCount = viewModel.getCount(countType: item, date: date)
            }
            await refreshStreak()
            await MainActor.run {
                onCheck(checkCount)
            }
        }
    }
    
    // •STREAK•V21•
    private func refreshStreak() async {
        streakCount = await viewModel.currentStreak(countType: item, on: date)
    }
}

//struct TweakzEntryRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Mock data for preview
//        let mockDate = Date().startOfDay
//        let mockTracker = SqlDailyTracker(date: mockDate)
//       // let mockDataCountType = DataCountType.tweakWeightTwice // Adjust based on your DataCountType
//        return NavigationStack {
//            VStack {
//                TweakzEntryRowView(
//                    item: DataCountType.dozeBeans,
//                    record: mockTracker,
//                    date: mockDate,
//                    onCheck: { _ in }
//                )
//                TweakzEntryRowView(
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
