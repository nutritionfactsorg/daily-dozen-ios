//
//  TwentyOneTweaksEntryiRowView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

enum RowNavigationDestination: Hashable {
    case weightEntry(Date)
    // Add other cases if needed, e.g., .detail(DataCountType)
}

struct TwentyOneTweaksEntryRowView: View {
  
    private let viewModel = SqlDailyTrackerViewModel.shared
    @Environment(\.dataCountAttributes) var dataCountAttributes
    let item: DataCountType
    let date: Date
    let onCheck: (Int) -> Void // Callback for checkbox changes
   // @State private var navigateToWeightEntry: Bool = false
    // @State private var localCount: Int = 0
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
                        NavigationLink(destination: TwentyOneDetailView(dataCountTypeItem: item)) {
                            // NavigationLink(destination: TwentyOneDetailView(dataCountTypeItem: item)) {
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
                        // StreakView(streak: viewModel.tracker?.itemsDict[item]?.datacount_streak ?? 0)
                        StreakView(streak: streakCount)
                        Spacer()
                        ContiguousCheckboxView(
                            n: item.goalServings,
                            x: $checkCount,
                           // direction: .leftToRight,
                            onChange: { newCount in
                                guard !isUpdating else { return}
                                isUpdating = true
                                checkCount = newCount
                                if item == .tweakWeightTwice {
                                    isNavigatingToWeight = true
                                    //navigationPath.append(date.startOfDay)
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
                            onTap: item == .tweakWeightTwice ? {
                                print("🟢 onTap called for weight on \(date.datestampSid)")
                                // navigationPath.append(date.startOfDay) } : nil
                                isNavigatingToWeight = true} : nil
                        )
                    }
                }
            }
            .padding(10)
            .shadowboxed()
            
            .navigationDestination(for: DataCountType.self) { item in
                TwentyOneDetailView(dataCountTypeItem: item)
            }
            
            .navigationDestination(for: Date.self) { date in
                WeightEntryView(initialDate: date.startOfDay)
                    .onDisappear {  // Clear path when disappearing (back navigation)
                                            navigationPath = NavigationPath()
                                  }
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
                        
                    }
                    streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                    onCheck(checkCount)  //Notify parent to refresh sum
                }
            }
//            .onChange(of: navigateToWeightEntry) { _, isActive in
//                if !isActive && item == .tweakWeightTwice {
//                    Task {
//                        // After returning from WeightEntryView (where weights were saved via savePendingWeights())
//                        let localTracker = viewModel.tracker(for: date)
//                        let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
//                        let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
//                        let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
//                        checkCount = newCount
//                        // onCheck(newCount) // Notify parent to refresh sum
//                        streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
//                        onCheck(checkCount)
//                        print("🟢 •Refresh• Returned from WeightEntryView, derived count for \(date.datestampSid): \(newCount)")
//                    }
//                }
//            }
            
            .onChange(of: isNavigatingToWeight) { _, newValue in
                            if newValue && navigationPath.count == 0 {  // Only append if not already navigating
                                navigationPath.append(date.startOfDay)
                            } else if !newValue {
                                // Optional: Force clear if needed, but back button should handle pop
                            }
                        }
            
            .onChange(of: navigationPath) { oldPath, newPath in  // New: Monitor path for return
                if newPath.count == 0 && oldPath.count > 0 && item == .tweakWeightTwice {
                    isNavigatingToWeight = false  // Reset the flag here on return
                    Task {
                        let localTracker = viewModel.tracker(for: date)
                        let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
                        let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
                        let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                        checkCount = newCount
                        streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                        onCheck(newCount)
                        print("🟢 •Refresh• Returned from WeightEntryView, derived count for \(date.datestampSid): \(newCount)")
                    }
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: .sqlDBUpdated)) { notification in
                guard let updatedDate = notification.object as? Date,
                      Calendar.current.isDate(updatedDate, inSameDayAs: date) else { return }
                
                Task {
                    let localTracker = viewModel.tracker(for: date)
                    if item == .tweakWeightTwice {
                        let amWeight = localTracker.weightAM?.dataweight_kg ?? 0
                        let pmWeight = localTracker.weightPM?.dataweight_kg ?? 0
                        let newCount = (amWeight > 0 ? 1 : 0) + (pmWeight > 0 ? 1 : 0)
                        checkCount = newCount
                        print("🟢 •Receive• Derived weight count for \(date.datestampSid): \(newCount)")
                    } else {
                        checkCount = viewModel.getCount(for: item, date: date)
                    }
                    streakCount = localTracker.itemsDict[item]?.datacount_streak ?? 0
                    onCheck(checkCount)
                    
                }
            }
            
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
