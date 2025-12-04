//
//  Untitled.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
//   TBDz is this used?

// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

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
    private let dbActor = SqliteDatabaseActor.shared
    private var isSettingCount = false
    private var lastLoadedDate: Date?
    static let shared = SqlDailyTrackerViewModel()
    
    init() {
     //  print("🟢 •VM• Creating SqlDailyTrackerViewModel instance:")
      // print("🟢 •VM• Creating instance at: \(Thread.callStackSymbols[1])")  // Logs caller
                Task {
                    do {
                        try await dbActor.setup()
                        await MainActor.run {
                          // print("🟢 •VM• SqlDailyTrackerViewModel: Database initialized")
                        }
                        // Optional: Uncomment to load current month's trackers on init
                        // await loadTrackers(forMonth: Date())
                    } catch {
                        await MainActor.run {
                            self.error = "Database initialization failed: \(error)"
                            print("🔴 •VM• SqlDailyTrackerViewModel: Database initialization failed: \(error)")
                        }
                    }
                }
        }
    
//    init() {
//            Task { await dbActor.setup() } // Add explicit setup
//            Task { await loadTracker(forDate: Date().startOfDay) }
//        }
    
    // Added: Convenience lookup from array (replaces old mockDB.first(where:))
    func tracker(for date: Date) -> SqlDailyTracker {
        let calendar = DateUtilities.gregorianCalendar
        let normalized = calendar.startOfDay(for: date)
        if let existing = trackers.first(where: { calendar.isDate($0.date, inSameDayAs: normalized) }) {
           // print("🟢 •Tracker• Returning for \(normalized.datestampSid): existing=true, countSum=\(existing.itemsDict.values.reduce(0) { $0 + ($1.datacount_count) })")
            return existing
        }
       
        let newTracker = SqlDailyTracker(date: normalized)
        trackers.append(newTracker)  // Cache empty for now; load will replace if needed
      //  print("🟢 •Tracker• Returning for \(normalized.datestampSid): existing=false, new countSum=\(newTracker.itemsDict.values.reduce(0) { $0 + ($1.datacount_count) })")
        return newTracker
    }
    
    // Added: Optional method to load trackers for a month into the array -- TBDz if needed
        func loadTrackers(forMonth date: Date) async {
            let calendar = DateUtilities.gregorianCalendar
            let fetched = await dbActor.fetchTrackers(forMonth: date)
            await MainActor.run {
                // Merge without duplicates
                for newTracker in fetched {
                    trackers = trackers.filter { !calendar.isDate($0.date, inSameDayAs: newTracker.date) } + [newTracker]
                }
                print("🟢 •VM• Loaded \(fetched.count) trackers for month \(date.datestampSid)")
            }
        }
    
    // Helper to update/replace in array (used after mutations/saves)
     private func updateTrackerInArray(_ updatedTracker: SqlDailyTracker) {
            let calendar = DateUtilities.gregorianCalendar
            if let index = trackers.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: updatedTracker.date) }) {
                trackers[index] = updatedTracker
            } else {
                trackers.append(updatedTracker)
            }
            NotificationCenter.default.post(name: .mockDBUpdated, object: nil)
        }
    
    // Added: Replaces old updateMockDB; saves full tracker (weights + counts) to DB
        func updateDatabase(with tracker: SqlDailyTracker) async {
            if let am = tracker.weightAM {
                _ = await dbActor.saveWeight(record: am, oldDatePsid: am.dataweight_date_psid, oldAmpm: am.dataweight_ampm_pnid)
            }
            if let pm = tracker.weightPM {
                _ = await dbActor.saveWeight(record: pm, oldDatePsid: pm.dataweight_date_psid, oldAmpm: pm.dataweight_ampm_pnid)
            }
            for (type, record) in tracker.itemsDict {
                _ = await dbActor.saveCount(record: record, oldDatePsid: record.datacount_date_psid, oldTypeNid: type.nid)
            }
            // Update local array
            trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: tracker.date) } + [tracker]
            if Calendar.current.isDate(self.tracker?.date ?? Date.distantPast, inSameDayAs: tracker.date) {
                self.tracker = tracker
            }
            NotificationCenter.default.post(name: .mockDBUpdated, object: nil)
        }
    
   func getTrackerOrCreate(for date: Date) async -> SqlDailyTracker {
            if let existingTracker = tracker {
                return existingTracker
            }
       return await SqlDailyTracker(date: date)  // Synchronous
        }

    // *** Added: From WeightEntryViewModel ***
    func loadWeights(for date: Date, unitType: UnitType) async -> WeightEntryData {
        let key = date.datestampSid
        let normalized = DateUtilities.gregorianCalendar.startOfDay(for: date)
        await loadTracker(forDate: normalized)
        var updatedTracker = tracker(for: normalized)
         
        
        var hasChanges = false

        // Load AM weight from HealthKit if not set
        if updatedTracker.weightAM?.dataweight_kg ?? 0 == 0 { // *** Changed: Optional chaining ***
            let (amTimeStr, amWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .am)
            if !amWeightStr.isEmpty, let kg = Double(amWeightStr), kg > 0 {
                updatedTracker.weightAM = SqlDataWeightRecord(
                    date: normalized,
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
        if updatedTracker.weightPM?.dataweight_kg ?? 0 == 0 { // *** Changed: Optional chaining ***
            let (pmTimeStr, pmWeightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: date, ampm: .pm)
            if !pmWeightStr.isEmpty, let kg = Double(pmWeightStr), kg > 0 {
                updatedTracker.weightPM = SqlDataWeightRecord(
                    date: normalized,
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
        if hasChanges && (updatedTracker.weightAM?.dataweight_kg ?? 0 > 0 || updatedTracker.weightPM?.dataweight_kg ?? 0 > 0 || !updatedTracker.itemsDict.isEmpty) {
            if let amRecord = updatedTracker.weightAM {
                _ = await dbActor.saveWeight(record: amRecord, oldDatePsid: amRecord.dataweight_date_psid, oldAmpm: 0)
            }
            if let pmRecord = updatedTracker.weightPM {
             _ = await dbActor.saveWeight(record: pmRecord, oldDatePsid: pmRecord.dataweight_date_psid, oldAmpm: 1)
                        }
                    
            updateTrackerInArray(updatedTracker)  // Update array cache, no self.tracker
            
            print("•Load• Persisted tracker to database for \(key)")
        }

        let amRecord = updatedTracker.weightAM
        let pmRecord = updatedTracker.weightPM

        let amWeight = await amRecord?.dataweight_kg ?? 0 > 0 ?
            UnitsUtility.regionalWeight(fromKg: amRecord!.dataweight_kg, toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric, toDecimalDigits: 1) ?? "" : ""
        let pmWeight = await pmRecord?.dataweight_kg ?? 0 > 0 ?
            UnitsUtility.regionalWeight(fromKg: pmRecord!.dataweight_kg, toUnits: UnitsType(rawValue: unitType.rawValue) ?? .metric, toDecimalDigits: 1) ?? "" : ""

        let amTime = amRecord?.dataweight_time.isEmpty ?? true ? Date() :
            Date(datestampHHmm: amRecord!.dataweight_time, referenceDate: date) ?? Date()
        let pmTime = pmRecord?.dataweight_time.isEmpty ?? true ? Date() :
            Date(datestampHHmm: pmRecord!.dataweight_time, referenceDate: date) ?? Date()

        print("Loaded weights for \(key): AM \(amWeight), PM \(pmWeight), AM Time \(amTime.datestampHHmm), PM Time \(pmTime.datestampHHmm)")
        return WeightEntryData(amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
    }

    // *** Added: Save weight with HealthKit sync ***
    func saveWeight(for date: Date, amWeight: Double?, pmWeight: Double?, amTime: Date?, pmTime: Date?) async {
       // let dateSid = date.datestampSid
        
        let normalized = Calendar.current.startOfDay(for: date)  //TBDz does this need to be Gregorian?
       // var updatedTracker = await getTrackerOrCreate(for: date.startOfDay)
        var updatedTracker = tracker(for: normalized)
        let unitType = UnitType.fromUserDefaults()

        print("Saving AM: \(String(describing: amWeight)), PM: \(String(describing: pmWeight)), Unit: \(unitType.rawValue), AM Time: \(amTime?.formatted(date: .omitted, time: .shortened) ?? "nil"), PM Time: \(pmTime?.formatted(date: .omitted, time: .shortened) ?? "nil")")

        var hasChanges = false
        if let amWeight = amWeight, let amTime = amTime, amWeight >= 0 {
            print("🟢 •Save• unitType=\(unitType.rawValue), input am=\(amWeight ?? 0), pm=\(pmWeight ?? 0)")
            let kg = unitType == .imperial ? amWeight / 2.204623 : amWeight
            print("🟢 •Save• Calculated kgAM=\(kg)")
            let record = SqlDataWeightRecord(date: date, weightType: .am, kg: kg, timeHHmm: amTime.datestampHHmm)
            updatedTracker.weightAM = record
           // await saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: 0)
            _ = await dbActor.saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: 0)
            if kg > 0, let amTimeDate = Date(datestampHHmm: record.dataweight_time, referenceDate: date) {
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .am, kg: kg, time: amTimeDate, tracker: updatedTracker)
                    print("•Sync• AM sync completed for \(date.datestampSid): \(kg) kg (\(kg * 2.204623) lbs)")
                } catch {
                    print("•Sync• AM sync error for \(date.datestampSid): \(error.localizedDescription)")
                }
            }
            hasChanges = true
        }
        if let pmWeight = pmWeight, let pmTime = pmTime, pmWeight >= 0 {
            print("🟢 •Save• unitType=\(unitType.rawValue), input am=\(amWeight ?? 0), pm=\(pmWeight ?? 0)")
            let kg = unitType == .imperial ? pmWeight / 2.204623 : pmWeight // Fixed: Use pmWeight
            print("🟢 •Save• Calculated kgPM=\(kg)")
            let record = SqlDataWeightRecord(date: date, weightType: .pm, kg: kg, timeHHmm: pmTime.datestampHHmm)
            updatedTracker.weightPM = record
           // await saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: 1)
            _ = await dbActor.saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: 1)
            if kg > 0, let pmTimeDate = Date(datestampHHmm: record.dataweight_time, referenceDate: date) {
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: date, ampm: .pm, kg: kg, time: pmTimeDate, tracker: updatedTracker)
                    print("•Sync• PM sync completed for \(date.datestampSid): \(kg) kg (\(kg * 2.204623) lbs)")
                } catch {
                    print("•Sync• PM sync error for \(date.datestampSid): \(error.localizedDescription)")
                }
            }
            hasChanges = true
        }
        
        if hasChanges {
            print(updatedTracker.itemsDict.values.reduce(0) { $0 + $1.datacount_count })
            let derivedCount = ((updatedTracker.weightAM?.dataweight_kg ?? 0 > 0 ? 1 : 0) +
                                (updatedTracker.weightPM?.dataweight_kg ?? 0 > 0 ? 1 : 0))
            await setCountAndUpdateStreak(for: .tweakWeightTwice, count: derivedCount, date: normalized)
            updateTrackerInArray(updatedTracker)  // Ensure cached
            print("🟢 •Save• Derived and saved count/streak for tweakWeightTwice on \(normalized.datestampSid): \(derivedCount)")
            print(updatedTracker.itemsDict.values.reduce(0) { $0 + $1.datacount_count })
            
        }
//            self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: date) } + [updatedTracker]
//            NotificationCenter.default.post(name: .mockDBUpdated, object: nil) // Ensure notification  TBDz not sure if needed?
//            print("•Save• Tracker updated for \(dateSid)")
//        } else {
//            print("•Save• No changes to save for \(dateSid)")
//        }
    }

    // *** Added: Update pending weights ***
    func updatePendingWeights(for date: Date, amWeight: String, pmWeight: String, amTime: Date, pmTime: Date) async {
        
        let key = date.datestampSid
        let existing = pendingWeights[key] ?? PendingWeight(amWeight: "", pmWeight: "", amTime: Date(), pmTime: Date())
        let newAMWeight = amWeight.isEmpty ? existing.amWeight : amWeight
        let newPMWeight = pmWeight.isEmpty ? existing.pmWeight : pmWeight
        let newAMTime = amWeight.isEmpty ? existing.amTime : amTime
        let newPMTime = pmWeight.isEmpty ? existing.pmTime : pmTime
        
        if !newAMWeight.isEmpty || !newPMWeight.isEmpty {
            pendingWeights[key] = PendingWeight(amWeight: newAMWeight, pmWeight: newPMWeight, amTime: newAMTime, pmTime: newPMTime)
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
        let calendar = DateUtilities.gregorianCalendar
        let normalizedDate = calendar.startOfDay(for: date)
//        guard !isLoading, lastLoadedDate == nil || !Calendar.current.isDate(lastLoadedDate!, inSameDayAs: normalizedDate) else {
//            return
//        }
//        isLoading = true
//        error = nil
//        tracker = await dbActor.fetchDailyTracker(forDate: normalizedDate)
//        lastLoadedDate = date
//        isLoading = false
        if trackers.contains(where: { calendar.isDate($0.date, inSameDayAs: normalizedDate) }) { return }  // Already cached
        isLoading = true
        let fetched = await dbActor.fetchDailyTracker(forDate: normalizedDate)
        //trackers.append(fetched)
        updateTrackerInArray(fetched)  // Use replace helper instead of append
            print("🟢 •Load• Updated trackers.count: \(trackers.count), sum for \(normalizedDate.datestampSid): \(tracker(for: normalizedDate).itemsDict.values.reduce(0) { $0 + $1.datacount_count })")
        print("🟢 •Load• Cached trackers.count after append: \(trackers.count)")
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

//    func getCount(for item: DataCountType, date: Date = Date()) -> Int {
//        tracker(for: date.startOfDay).itemsDict[type]?.datacount_count ?? 0
//    }
    
    func getCount(for type: DataCountType, date: Date) -> Int {
        tracker(for: date).itemsDict[type]?.datacount_count ?? 0
    }

    func setCount(for type: DataCountType, count: Int, date: Date) async {
        let calendar = DateUtilities.gregorianCalendar
        let normalized = calendar.startOfDay(for: date)
        var mutableTracker = tracker(for: normalized)  // Gets or creates/caches
                await mutableTracker.setCount(typeKey: type, count: count)
                if let updatedRecord = mutableTracker.itemsDict[type] {
                    let success = await dbActor.saveCount(
                        record: updatedRecord,
                        oldDatePsid: updatedRecord.datacount_date_psid,
                        oldTypeNid: type.nid
                    )
                    if success {
                        updateTrackerInArray(mutableTracker)
                    } else {
                        error = "Failed to save count"
                    }
                }
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

    func fetchAllTrackers() async -> [SqlDailyTracker] {
        let trackers = await dbActor.fetchAllTrackers()
        print("SqlDailyTrackerViewModel fetchAllTrackers: \(trackers.map { "\($0.date.datestampSid): dozeBeans=\($0.itemsDict[.dozeBeans]?.datacount_count ?? 0), otherVitaminB12=\($0.itemsDict[.otherVitaminB12]?.datacount_count ?? 0)" })")
        print("🟢 •VM• Fetched all \(trackers.count) trackers: \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg, PM=\($0.weightPM?.dataweight_kg ?? 0) kg" })")
               return trackers
    }
}

extension SqlDailyTrackerViewModel {
    func setCountAndUpdateStreak(for item: DataCountType, count: Int, date: Date) async {
        let calendar = DateUtilities.gregorianCalendar
        let normalizedDate = calendar.startOfDay(for: date)
        // Update the count
        await setCount(for: item, count: count, date: normalizedDate)
        
        // Update streak
        let db = SqliteDatabaseActor.shared
        let isCompleted = count >= item.goalServings
        print("🟢 •VM• setCountAndUpdateStreak for \(item.typeKey) on \(normalizedDate.datestampSid): count=\(count), goal=\(item.goalServings), isCompleted=\(isCompleted)")
        if isCompleted {
            await updateStreakCompleted(for: item, date: normalizedDate, db: db)
        } else {
            await updateStreakIncomplete(for: item, date: normalizedDate, db: db)
        }
    }
    
    private func updateStreakCompleted(for item: DataCountType, date: Date, db: SqliteDatabaseActor) async {
        // Fetch current day's tracker
        let normalizedDate = date.startOfDay
        var thisTracker = await db.fetchDailyTracker(forDate: normalizedDate)
        guard var thisRecord = thisTracker.itemsDict[item] else {
            print("🔴 •VM• No record for \(item.typeKey) on \(normalizedDate.datestampSid)")
            return
        }
        
        // Ensure count doesn't exceed goalServings
        if thisRecord.datacount_count > item.goalServings {
            thisRecord.datacount_count = item.goalServings
        }
        
        // Calculate streak based on previous day
        var prevDay = normalizedDate.adding(days: -1)
        let prevTracker = await db.fetchDailyTracker(forDate: prevDay.startOfDay)
        if let prevRecord = prevTracker.itemsDict[item], prevRecord.datacount_count >= item.goalServings {
            thisRecord.datacount_streak = prevRecord.datacount_streak + 1
        } else {
            thisRecord.datacount_streak = 1
        }
        
        print("🟢 •VM• Calculated streak for \(item.typeKey) on \(normalizedDate.datestampSid): \(thisRecord.datacount_streak)")
        
        // Update current day's record
        thisTracker.itemsDict[item] = thisRecord
        let saveSuccess = await db.saveCount( // Explicitly call db.saveCount
            record: thisRecord,
            oldDatePsid: thisRecord.idKeys?.datestampSid,
            oldTypeNid: item.nid
        )
        if !saveSuccess {
            print("🔴 •VM• Failed to save streak for \(item.typeKey) on \(normalizedDate.datestampSid)")
            return
        }
        if Calendar.current.isDate(thisTracker.date, inSameDayAs: normalizedDate) {
            self.tracker = thisTracker
            self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) } + [thisTracker]
        }
        
        // Update future days' streaks
        var nextMaxValidStreak = thisRecord.datacount_streak + 1
        var nextDay = normalizedDate.adding(days: 1)
        while true {
            let nextTracker = await db.fetchDailyTracker(forDate: nextDay.startOfDay)
            guard let nextRecord = nextTracker.itemsDict[item] else {
                break
            }
            if nextRecord.datacount_count < item.goalServings {
                if nextRecord.datacount_streak != 0 {
                    print("🔴 •VM• Fixing streak for \(item.typeKey) on \(nextDay.datestampSid): count=\(nextRecord.datacount_count) < \(item.goalServings), resetting streak")
                    var updatedTracker = nextTracker
                    updatedTracker.itemsDict[item]?.datacount_streak = 0
                    let saveSuccess = await db.saveCount( // Explicitly call db.saveCount
                        record: updatedTracker.itemsDict[item]!,
                        oldDatePsid: nextRecord.idKeys?.datestampSid,
                        oldTypeNid: item.nid
                    )
                    if !saveSuccess {
                        print("🔴 •VM• Failed to save streak for \(item.typeKey) on \(nextDay.datestampSid)")
                        break
                    }
                    if Calendar.current.isDate(updatedTracker.date, inSameDayAs: normalizedDate.startOfDay) {
                        self.tracker = updatedTracker
                    }
                    self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: nextDay) } + [updatedTracker]
                }
                break
            } else if nextRecord.datacount_count >= item.goalServings {
                if nextRecord.datacount_streak != nextMaxValidStreak {
                    print("🟢 •VM• Updating streak for \(item.typeKey) on \(nextDay.datestampSid): \(nextMaxValidStreak)")
                    var updatedTracker = nextTracker
                    updatedTracker.itemsDict[item]?.datacount_streak = nextMaxValidStreak
                    if updatedTracker.itemsDict[item]?.datacount_count ?? 0 > item.goalServings {
                        updatedTracker.itemsDict[item]?.datacount_count = item.goalServings
                    }
                    let saveSuccess = await db.saveCount( // Explicitly call db.saveCount
                        record: updatedTracker.itemsDict[item]!,
                        oldDatePsid: nextRecord.idKeys?.datestampSid,
                        oldTypeNid: item.nid
                    )
                    if !saveSuccess {
                        print("🔴 •VM• Failed to save streak for \(item.typeKey) on \(nextDay.datestampSid)")
                        break
                    }
                    if Calendar.current.isDate(updatedTracker.date, inSameDayAs: normalizedDate) {
                        self.tracker = updatedTracker
                    }
                    self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: nextDay) } + [updatedTracker]
                } else {
                    break
                }
                nextMaxValidStreak += 1
            }
            nextDay = nextDay.adding(days: 1)
        }
        
        // Verify streak by counting backward (limited to 30 days)
        var streakCount = 1
        var daysChecked = 0
        let maxDaysToCheck = 30
        prevDay = normalizedDate.adding(days: -1)
        while daysChecked < maxDaysToCheck {
            let prevTracker = await db.fetchDailyTracker(forDate: prevDay.startOfDay)
            guard let prevRecord = prevTracker.itemsDict[item], prevRecord.datacount_count >= item.goalServings else {
                break
            }
            streakCount += 1
            daysChecked += 1
            prevDay = prevDay.adding(days: -1)
        }
        
        if streakCount != thisRecord.datacount_streak {
            print("🟢 •VM• Adjusting streak for \(item.typeKey) on \(normalizedDate.datestampSid): from \(thisRecord.datacount_streak) to \(streakCount)")
            thisRecord.datacount_streak = streakCount
            thisTracker.itemsDict[item] = thisRecord
            let saveSuccess = await db.saveCount( // Explicitly call db.saveCount
                record: thisRecord,
                oldDatePsid: thisRecord.idKeys?.datestampSid,
                oldTypeNid: item.nid
            )
            if !saveSuccess {
                print("🔴 •VM• Failed to save streak for \(item.typeKey) on \(normalizedDate.datestampSid)")
                return
            }
            if Calendar.current.isDate(thisTracker.date, inSameDayAs: normalizedDate) {
                self.tracker = thisTracker
            }
            self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) } + [thisTracker]
        }
    }
    
    private func updateStreakIncomplete(for item: DataCountType, date: Date, db: SqliteDatabaseActor) async {
        // Fetch current day's tracker
        let normalizedDate = date.startOfDay
        var thisTracker = await db.fetchDailyTracker(forDate: normalizedDate)
        guard var thisRecord = thisTracker.itemsDict[item] else {
            print("🔴 •VM• No record for \(item.typeKey) on \(normalizedDate.datestampSid)")
            return
        }
        
        // Set current day's streak to 0
        thisRecord.datacount_streak = 0
        thisTracker.itemsDict[item] = thisRecord
        let saveSuccess = await db.saveCount( // Explicitly call db.saveCount
            record: thisRecord,
            oldDatePsid: thisRecord.idKeys?.datestampSid,
            oldTypeNid: item.nid
        )
        if !saveSuccess {
            print("🔴 •VM• Failed to save streak for \(item.typeKey) on \(normalizedDate.datestampSid)")
            return
        }
        print("🟢 •VM• Reset streak for \(item.typeKey) on \(normalizedDate.datestampSid): 0")
        if Calendar.current.isDate(thisTracker.date, inSameDayAs: normalizedDate) {
            self.tracker = thisTracker
        }
        self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) } + [thisTracker]
        
        // Update future days' streaks
        var nextMaxValidStreak = 1
        var nextDay = normalizedDate.adding(days: 1)
        while true {
            let nextTracker = await db.fetchDailyTracker(forDate: nextDay.startOfDay)
            guard let nextRecord = nextTracker.itemsDict[item] else {
                break
            }
            if nextRecord.datacount_count < item.goalServings {
                if nextRecord.datacount_streak != 0 {
                    print("🔴 •VM• Fixing streak for \(item.typeKey) on \(nextDay.datestampSid): count=\(nextRecord.datacount_count) < \(item.goalServings), resetting streak")
                    var updatedTracker = nextTracker
                    updatedTracker.itemsDict[item]?.datacount_streak = 0
                    let saveSuccess = await db.saveCount( // Explicitly call db.saveCount
                        record: updatedTracker.itemsDict[item]!,
                        oldDatePsid: nextRecord.idKeys?.datestampSid,
                        oldTypeNid: item.nid
                    )
                    if !saveSuccess {
                        print("🔴 •VM• Failed to save streak for \(item.typeKey) on \(nextDay.datestampSid)")
                        break
                    }
                    if Calendar.current.isDate(updatedTracker.date, inSameDayAs: normalizedDate) {
                        self.tracker = updatedTracker
                    }
                    self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: nextDay) } + [updatedTracker]
                }
                break
            } else if nextRecord.datacount_count >= item.goalServings {
                if nextRecord.datacount_streak != nextMaxValidStreak {
                    print("🟢 •VM• Updating streak for \(item.typeKey) on \(nextDay.datestampSid): \(nextMaxValidStreak)")
                    var updatedTracker = nextTracker
                    updatedTracker.itemsDict[item]?.datacount_streak = nextMaxValidStreak
                    if updatedTracker.itemsDict[item]?.datacount_count ?? 0 > item.goalServings {
                        updatedTracker.itemsDict[item]?.datacount_count = item.goalServings
                    }
                    let saveSuccess = await db.saveCount( // Explicitly call db.saveCount
                        record: updatedTracker.itemsDict[item]!,
                        oldDatePsid: nextRecord.idKeys?.datestampSid,
                        oldTypeNid: item.nid
                    )
                    if !saveSuccess {
                        print("🔴 •VM• Failed to save streak for \(item.typeKey) on \(nextDay.datestampSid)")
                        break
                    }
                    if Calendar.current.isDate(updatedTracker.date, inSameDayAs: normalizedDate) {
                        self.tracker = updatedTracker
                    }
                    self.trackers = trackers.filter { !Calendar.current.isDate($0.date, inSameDayAs: nextDay) } + [updatedTracker]
                } else {
                    break
                }
                nextMaxValidStreak += 1
            }
            nextDay = nextDay.adding(days: 1)
        }
    }
    
}

extension SqlDailyTrackerViewModel {
    static let mockDBTrigger = NotificationCenter.Publisher(center: .default, name: .mockDBUpdated, object: nil)
}

//for testing streaks
//extension SqlDailyTrackerViewModel {
//    func resetStreaks(for item: DataCountType, date: Date) async {
//        let db = SqliteDatabaseActor()
//        await db.resetStreaks(for: item, date: date)
//        await loadTracker(forDate: date)
//    }
//}
