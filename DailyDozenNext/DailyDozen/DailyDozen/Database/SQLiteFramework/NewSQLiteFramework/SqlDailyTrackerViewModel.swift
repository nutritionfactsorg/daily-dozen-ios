//
//  Untitled.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
//   TBDz is this used?
struct PendingWeight {
    var amWeight: String
    var pmWeight: String
    var amTime: Date
    var pmTime: Date
}

import SwiftUI

@MainActor
class SqlDailyTrackerViewModel: ObservableObject {
    @Published var tracker: SqlDailyTracker?
    @Published var trackers: [SqlDailyTracker] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var successMessage: String?
    @Published var pendingWeights: [String: PendingWeight] = [:] // *** Added: For pending weight storage ***
    private let dbActor: SqliteDatabaseActor
    private var isSettingCount = false
    private var lastLoadedDate: Date?
    
    init() {
            self.dbActor = SqliteDatabaseActor()
            Task { @MainActor in
                do {
                    try await dbActor.setup()
                    print("🟢 •VM• SqlDailyTrackerViewModel: Database initialized")
                } catch {
                    print("🔴 •VM• SqlDailyTrackerViewModel: Database initialization failed: \(error)")
                }
            }
        }
    
//    init() {
//            Task { await dbActor.setup() } // Add explicit setup
//            Task { await loadTracker(forDate: Date().startOfDay) }
//        }

    // *** Added: From WeightEntryViewModel ***
    func loadWeights(for date: Date, unitType: UnitType) async -> WeightEntryData {
        let key = date.datestampSid
        await loadTracker(forDate: date)
        var tracker = tracker ?? SqlDailyTracker(date: date.startOfDay)
        var hasChanges = false

        // Load AM weight from HealthKit if not set
        if tracker.weightAM?.dataweight_kg ?? 0 == 0 { // *** Changed: Optional chaining ***
            let (amTimeStr, amWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .am)
            if !amWeightStr.isEmpty, let kg = Double(amWeightStr), kg > 0 {
                tracker.weightAM = SqlDataWeightRecord(
                    date: date,
                    weightType: .am,
                    kg: kg,
                    timeHHmm: amTimeStr
                )
                hasChanges = true
                print("•Load• Updated AM weight from HealthKit: \(kg) kg for \(key)")
            } else {
                print("•Load• No AM weight data for \(key)")
            }
        }
        // Load PM weight from HealthKit if not set
        if tracker.weightPM?.dataweight_kg ?? 0 == 0 { // *** Changed: Optional chaining ***
            let (pmTimeStr, pmWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .pm)
            if !pmWeightStr.isEmpty, let kg = Double(pmWeightStr), kg > 0 {
                tracker.weightPM = SqlDataWeightRecord(
                    date: date,
                    weightType: .pm,
                    kg: kg,
                    timeHHmm: pmTimeStr
                )
                hasChanges = true
                print("•Load• Updated PM weight from HealthKit: \(kg) kg for \(key)")
            } else {
                print("•Load• No PM weight data for \(key)")
            }
        }

        // Save to database if changed
        if hasChanges && (tracker.weightAM?.dataweight_kg ?? 0 > 0 || tracker.weightPM?.dataweight_kg ?? 0 > 0 || !tracker.itemsDict.isEmpty) {
            await saveWeight(
                record: tracker.weightAM ?? SqlDataWeightRecord(date: date, weightType: .am, kg: 0, timeHHmm: ""),
                oldDatePsid: tracker.weightAM?.dataweight_date_psid,
                oldAmpm: tracker.weightAM?.dataweight_ampm_pnid
            )
            await saveWeight(
                record: tracker.weightPM ?? SqlDataWeightRecord(date: date, weightType: .pm, kg: 0, timeHHmm: ""),
                oldDatePsid: tracker.weightPM?.dataweight_date_psid,
                oldAmpm: tracker.weightPM?.dataweight_ampm_pnid
            )
            self.tracker = tracker
            trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: date) } + [tracker]
            print("•Load• Persisted tracker to database for \(key)")
        }

        let amRecord = tracker.weightAM
        let pmRecord = tracker.weightPM

        let amWeight = amRecord?.dataweight_kg ?? 0 > 0 ?
            UnitsUtility.regionalWeight(fromKg: amRecord!.dataweight_kg, toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric, toDecimalDigits: 1) ?? "" : ""
        let pmWeight = pmRecord?.dataweight_kg ?? 0 > 0 ?
            UnitsUtility.regionalWeight(fromKg: pmRecord!.dataweight_kg, toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric, toDecimalDigits: 1) ?? "" : ""

        let amTime = amRecord?.dataweight_time.isEmpty ?? true ? Date() :
            Date(datestampHHmm: amRecord!.dataweight_time, referenceDate: date) ?? Date()
        let pmTime = pmRecord?.dataweight_time.isEmpty ?? true ? Date() :
            Date(datestampHHmm: pmRecord!.dataweight_time, referenceDate: date) ?? Date()

        print("Loaded weights for \(date.datestampSid): AM \(amWeight), PM \(pmWeight), AM Time \(amTime.datestampHHmm), PM Time \(pmTime.datestampHHmm)")
        return WeightEntryData(amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
    }

    // *** Added: Save weight with HealthKit sync ***
    func saveWeight(for date: Date, amWeight: Double?, pmWeight: Double?, amTime: Date?, pmTime: Date?) async {
        let dateSid = date.datestampSid
        var tracker = tracker ?? SqlDailyTracker(date: date)
        let unitType = UnitType.fromUserDefaults()

        print("Saving AM: \(String(describing: amWeight)), PM: \(String(describing: pmWeight)), Unit: \(unitType.rawValue), AM Time: \(amTime?.formatted(date: .omitted, time: .shortened) ?? "nil"), PM Time: \(pmTime?.formatted(date: .omitted, time: .shortened) ?? "nil")")

        var hasChanges = false
        if let amWeight = amWeight, let amTime = amTime, amWeight >= 0 {
            let kg = unitType == .imperial ? amWeight / 2.204623 : amWeight
            let record = SqlDataWeightRecord(date: date, weightType: .am, kg: kg, timeHHmm: amTime.datestampHHmm)
            tracker.weightAM = record
            await saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: 0)
            if kg > 0, let amTimeDate = Date(datestampHHmm: record.dataweight_time, referenceDate: date) {
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .am, kg: kg, time: amTimeDate, tracker: tracker)
                    print("•Sync• AM sync completed for \(date.datestampSid): \(kg) kg (\(kg * 2.204623) lbs)")
                } catch {
                    print("•Sync• AM sync error for \(date.datestampSid): \(error.localizedDescription)")
                }
            }
            hasChanges = true
        }
        if let pmWeight = pmWeight, let pmTime = pmTime, pmWeight >= 0 {
            let kg = unitType == .imperial ? pmWeight / 2.204623 : pmWeight // Fixed: Use pmWeight
            let record = SqlDataWeightRecord(date: date, weightType: .pm, kg: kg, timeHHmm: pmTime.datestampHHmm)
            tracker.weightPM = record
            await saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: 1)
            if kg > 0, let pmTimeDate = Date(datestampHHmm: record.dataweight_time, referenceDate: date) {
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .pm, kg: kg, time: pmTimeDate, tracker: tracker)
                    print("•Sync• PM sync completed for \(date.datestampSid): \(kg) kg (\(kg * 2.204623) lbs)")
                } catch {
                    print("•Sync• PM sync error for \(date.datestampSid): \(error.localizedDescription)")
                }
            }
            hasChanges = true
        }

        if hasChanges {
            self.tracker = tracker
            trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: date) } + [tracker]
            NotificationCenter.default.post(name: .mockDBUpdated, object: nil) // Ensure notification  TBDz not sure if needed?
            print("•Save• Tracker updated for \(dateSid)")
        } else {
            print("•Save• No changes to save for \(dateSid)")
        }
    }

    // *** Added: Update pending weights ***
    func updatePendingWeights(for date: Date, amWeight: String, pmWeight: String, amTime: Date, pmTime: Date) async {
        if !amWeight.isEmpty || !pmWeight.isEmpty {
            pendingWeights[date.datestampSid] = PendingWeight(
                amWeight: amWeight,
                pmWeight: pmWeight,
                amTime: amTime,
                pmTime: pmTime
            )
        } else {
            pendingWeights.removeValue(forKey: date.datestampSid)
        }
    }

    // *** Added: Save pending weights ***
    func savePendingWeights() async {
       // print("savePendingWeights called with: \(pendingWeights.map { ($0.key, $0.value.amWeight, $0.value.pmWeight) })")
        for (dateSid, weights) in pendingWeights {
            let amValue = Double(weights.amWeight.filter { !$0.isWhitespace })
            let pmValue = Double(weights.pmWeight.filter { !$0.isWhitespace })
            print("Processing \(dateSid): AM \(String(describing: amValue)), PM \(String(describing: pmValue))")
            if amValue != nil || pmValue != nil {
                guard let date = Date(datestampSid: dateSid) else {
                    print("Invalid dateSid: \(dateSid), skipping save")
                    continue
                }
                await saveWeight(
                    for: date,
                    amWeight: amValue,
                    pmWeight: pmValue,
                    amTime: weights.amTime,
                    pmTime: weights.pmTime
                )
                print("Called saveWeight for \(dateSid)")
            } else {
                print("No valid weights for \(dateSid), skipping")
            }
        }
        pendingWeights.removeAll()
    }

    func loadTracker(forDate date: Date) async {
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
            guard !isSettingCount else {
                print("🟢 •DB• Skipped setCount for \(type.headingDisplay) on \(date.datestampSid): already setting count")
                return
            }
            isSettingCount = true
            
            if tracker == nil || !Calendar.current.isDate(tracker!.date, inSameDayAs: date) {
                await loadTracker(forDate: date)
            }
            
            guard let currentTracker = tracker else {
                isSettingCount = false
                error = "No tracker available for \(type.headingDisplay) on \(date.datestampSid)"
                print("🔴 •DB• No tracker for \(type.headingDisplay) on \(date.datestampSid)")
                return
            }
            
            if currentTracker.itemsDict[type]?.datacount_count == count {
                isSettingCount = false
                print("🟢 •DB• Skipped setCount for \(type.headingDisplay) on \(date.datestampSid): count unchanged (\(count))")
                return
            }
            
            var mutableTracker = currentTracker
            mutableTracker.setCount(typeKey: type, count: count)
            if let updatedRecord = mutableTracker.itemsDict[type] {
                print("🟢 •DB• Saving count for \(type.headingDisplay) on \(date.datestampSid): count=\(count), idKeys=\(updatedRecord.idKeys?.datestampSid ?? "nil"), typeNid=\(type.nid)")
                let success = await dbActor.saveCount(
                    record: updatedRecord,
                    oldDatePsid: updatedRecord.idKeys?.datestampSid,
                    oldTypeNid: type.nid
                )
                if success {
                    tracker = mutableTracker
                    successMessage = "Count saved for \(type.nid)"
                    print("🟢 •DB• Count saved for \(type.headingDisplay) on \(date.datestampSid): \(count)")
                } else {
                    error = "Failed to save count for \(type.nid)"
                    print("🔴 •DB• Failed to save count for \(type.headingDisplay) on \(date.datestampSid)")
                }
            } else {
                error = "No record created for \(type.nid)"
                print("🔴 •DB• No record created for \(type.headingDisplay) on \(date.datestampSid)")
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
        let trackers = await dbActor.fetchTrackers(forMonth: date)
        print("🟢 •VM• Fetched \(trackers.count) trackers for month \(date.datestampSid): \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg, PM=\($0.weightPM?.dataweight_kg ?? 0) kg" })")
        return trackers
    }

    func fetchTrackers() async -> [SqlDailyTracker] {
        let trackers = await dbActor.fetchTrackers()
        print("🟢 •VM• Fetched \(trackers.count) trackers: \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg, PM=\($0.weightPM?.dataweight_kg ?? 0) kg" })")
        return trackers
    }

    func fetchAllTrackers() async -> [SqlDailyTracker]{
        let trackers = await dbActor.fetchAllTrackers()
        print("SqlDailyTrackerViewModel fetchAllTrackers: \(trackers.map { "\($0.date.datestampSid): dozeBeans=\($0.itemsDict[.dozeBeans]?.datacount_count ?? 0), otherVitaminB12=\($0.itemsDict[.otherVitaminB12]?.datacount_count ?? 0)" })")
        print("🟢 •VM• Fetched all \(trackers.count) trackers: \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg, PM=\($0.weightPM?.dataweight_kg ?? 0) kg" })")
               return trackers
    }
}
