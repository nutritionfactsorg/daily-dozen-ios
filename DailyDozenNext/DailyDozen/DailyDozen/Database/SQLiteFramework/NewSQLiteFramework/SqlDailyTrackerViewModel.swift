//
//  Untitled.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

@MainActor
class SqlDailyTrackerViewModel: ObservableObject {
    @Published var tracker: SqlDailyTracker?
    @Published var trackers: [SqlDailyTracker] = [] 
    @Published var isLoading = false
    @Published var error: String?
    @Published var successMessage: String?
    private let dbActor = SqliteDatabaseActor()
    private var isSettingCount = false
    private var lastLoadedDate: Date? // Track last loaded date
    
    func loadTracker(forDate date: Date) async {
        // Only load if date has changed or tracker is nil
        guard !isLoading, lastLoadedDate == nil || !Calendar.current.isDate(lastLoadedDate!, inSameDayAs: date) else {
            return
        }
        isLoading = true
        error = nil
        tracker = await dbActor.fetchDailyTracker(forDate: date)
        lastLoadedDate = date
        isLoading = false
    }
    
    func saveWeight(record: SqlDataWeightRecord, oldDatePsid: String?, oldAmpm: Int?) async {
        let success = await dbActor.saveWeight(record: record, oldDatePsid: oldDatePsid, oldAmpm: oldAmpm)
        if success {
            let datestampSid = record.pidKeys.datestampSid
            if let date = Date(datestampSid: datestampSid) {
                await loadTracker(forDate: date)
            } else {
                error = "Invalid datestampSid: \(datestampSid)"
            }
        } else {
            error = "Failed to save weight for \(record.idString)"
        }
    }
    
    func saveCount(record: SqlDataCountRecord, oldDatePsid: String?, oldTypeNid: Int?) async {
        let success = await dbActor.saveCount(record: record, oldDatePsid: oldDatePsid, oldTypeNid: oldTypeNid)
        if success {
            successMessage = "Count saved successfully for \(record.datacount_kind_pfnid)"
        } else {
            error = "Failed to save count for \(record.idString)"
        }
    }
    
    func getCount(for type: DataCountType) -> Int {
        tracker?.itemsDict[type]?.datacount_count ?? 0
    }
    
    func setCount(for type: DataCountType, count: Int, date: Date) async {
        guard !isSettingCount else { return }
        isSettingCount = true
        
        if tracker == nil || !Calendar.current.isDate(tracker!.date, inSameDayAs: date) {
            await loadTracker(forDate: date)
        }
        
        guard let currentTracker = tracker, currentTracker.itemsDict[type]?.datacount_count != count else {
            isSettingCount = false
            return
        }
        
        var mutableTracker = currentTracker
        mutableTracker.setCount(typeKey: type, count: count)
        if let updatedRecord = mutableTracker.itemsDict[type] {
            let success = await dbActor.saveCount(
                record: updatedRecord,
                oldDatePsid: updatedRecord.idKeys?.datestampSid,
                oldTypeNid: type.nid
            )
            if success {
                tracker = mutableTracker
                successMessage = "Count saved for \(type.nid)"
            } else {
                error = "Failed to save count for \(type.nid)"
            }
        } else {
            error = "No record created for \(type.nid)"
        }
        isSettingCount = false
    }
    
    func getWeight(for weightType: DataWeightType) -> Double {
        switch weightType {
        case .am:
            return tracker?.weightAM?.dataweight_kg ?? 0.0
        case .pm:
            return tracker?.weightPM?.dataweight_kg ?? 0.0
        }
    }
    
    func setWeight(for weightType: DataWeightType, kg: Double) async {
        guard kg > 0, kg < 500, let tracker = tracker else {
            error = "Please enter a valid weight (0 < weight < 500 kg)"
            return
        }
        var mutableTracker = tracker
        let timeHHmm = weightType == .am ? (mutableTracker.weightAM?.dataweight_time ?? Date().datestampHHmm) : (mutableTracker.weightPM?.dataweight_time ?? Date().datestampHHmm)
        let newRecord = SqlDataWeightRecord(
            date: mutableTracker.date,
            weightType: weightType,
            kg: kg,
            timeHHmm: timeHHmm
        )
        if weightType == .am {
            mutableTracker.weightAM = newRecord
        } else {
            mutableTracker.weightPM = newRecord
        }
        self.tracker = mutableTracker
        await saveWeight(
            record: newRecord,
            oldDatePsid: newRecord.pidKeys.datestampSid,
            oldAmpm: weightType == .am ? 0 : 1
        )
    }
    
    func fetchTrackers(forMonth date: Date) async -> [SqlDailyTracker] {
        await dbActor.fetchTrackers(forMonth: date)
    }
    
    func fetchTrackers() async -> [SqlDailyTracker] {
        await dbActor.fetchTrackers()
    }
    
    func fetchAllTrackers() async {
            trackers = await dbActor.fetchAllTrackers()
            print("SqlDailyTrackerViewModel fetchAllTrackers: \(trackers.map { "\($0.date.datestampSid): dozeBeans=\($0.itemsDict[.dozeBeans]?.datacount_count ?? 0), otherVitaminB12=\($0.itemsDict[.otherVitaminB12]?.datacount_count ?? 0)" })")
        }
}
