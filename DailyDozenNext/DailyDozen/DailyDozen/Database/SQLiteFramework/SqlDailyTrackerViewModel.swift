//
//  SqlDailyTrackerViewModel.swift
//  SQLiteFramework
//
//  Copyright © 2023-2025 NutritionFacts.org. All rights reserved.
//
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
    private var cachedDistinctDateStrings: [String]?
    private var hasPreloadedServingsData = false
    @Published var refreshID = UUID()          // for refreshing after clearing db
    
    init() {
        Task {
            do {
                try await dbActor.setup()
                await MainActor.run {
                    // print("🟢 •VM• SqlDailyTrackerViewModel: Database initialized")
                }
                // :TRACE: Optional: Uncomment to load & print current month's trackers on init
                //await loadTrackers(forMonth: Date())
                // for debug these two awaits
                // await SqliteDatabaseActor.shared.printSchema()
                // await SqliteDatabaseActor.shared.dumpAllRows()
            } catch {
                await MainActor.run {
                    self.error = "Database initialization failed: \(error)"
                    print("🔴 •VM• SqlDailyTrackerViewModel: Database initialization failed: \(error)")
                }
            }
        }
    }
    
    // Added: Convenience lookup from array (replaces old mockDB.first(where:))
    func tracker(for date: Date) -> SqlDailyTracker {
        let calendar = DateUtilities.gregorianCalendar
        let normalized = calendar.startOfDay(for: date)
        if let existing = trackers.first(where: { calendar.isDate($0.date, inSameDayAs: normalized) }) {
            return existing
        }
        
        // Create full default synchronously (createItemsDict is fast — just loop)
        var defaultDict: [DataCountType: SqlDataCountRecord] = [:]
        for type in DataCountType.allCases {
            defaultDict[type] = SqlDataCountRecord(date: normalized, countType: type, count: 0, streak: 0)
        }
        
        let temp = SqlDailyTracker(date: normalized, itemsDict: defaultDict)
        //trackers.append(temp)
        
        Task { await loadTracker(forDate: normalized) }  // Async fill real data
        return temp
        
    }
    
    // Helper to update/replace in array (used after mutations/saves)
    func updateTrackerInArray(_ updatedTracker: SqlDailyTracker) {
        let calendar = DateUtilities.gregorianCalendar
        if let index = trackers.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: updatedTracker.date) }) {
            trackers[index] = updatedTracker
        } else {
            trackers.append(updatedTracker)
        }
        NotificationCenter.default.post(name: .sqlDBUpdated, object: nil)
    }
    
    // Added: Replaces old updateMockDB; saves full tracker (weights + counts) to DB
    func updateDatabase(with tracker: SqlDailyTracker) async {
        print("updateDatabase called — weightAM: \(tracker.weightAM?.dataweight_kg ?? -1), weightPM: \(tracker.weightPM?.dataweight_kg ?? -1)")
        
        print("Updating DB for date \(tracker.date.formatted(date: .numeric, time: .omitted)): AM kg = \(tracker.weightAM?.dataweight_kg ?? -1), PM kg = \(tracker.weightPM?.dataweight_kg ?? -1)")
        
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
        NotificationCenter.default.post(name: .sqlDBUpdated, object: nil)
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
        let updatedTracker = tracker(for: normalized)
        let unitsType = UnitsType(rawValue: unitType.rawValue) ?? .metric
        
        // Handle AM
        var amWeightStr = ""
        var amTime = Date()
       // print("•DEBUG• AM weightAM exists? \(updatedTracker.weightAM?.dataweight_kg ?? 0)")
        if let amRecord = updatedTracker.weightAM, amRecord.dataweight_kg > 0 {
            // DB exists: Use DB, sync to HK
            amWeightStr = await UnitsUtility.regionalWeight(fromKg: amRecord.dataweight_kg, toUnits: unitsType, toDecimalDigits: 1) ?? ""
            amTime = Date(datestampHHmm: amRecord.dataweight_time, referenceDate: date) ?? Date()
            do {
                try await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .am, kg: amRecord.dataweight_kg, time: amTime, tracker: updatedTracker)
                print("•Load• Synced DB to HK for AM: \(amRecord.dataweight_kg) kg")
            } catch {
                print("•Load• AM sync put error: \(error.localizedDescription)")
            }
        }
//        else {
//            // No DB: Pull from HK for display (user decision)
//            let (timeStr, weightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: normalized, ampm: .am)
//            if !weightStr.isEmpty {
//                amWeightStr = weightStr
//                amTime = Date(datestampHHmm: timeStr, referenceDate: date) ?? Date()
//                print("•Load• Pulled HK for AM (no DB): \(weightStr) at \(timeStr)")
//            }
//        }
        
        // Handle PM (similar)
        var pmWeightStr = ""
        var pmTime = Date()
        print("•DEBUG• PM weightAM exists? \(updatedTracker.weightPM?.dataweight_kg ?? 0)")
        if let pmRecord = updatedTracker.weightPM, pmRecord.dataweight_kg > 0 {
            pmWeightStr = await UnitsUtility.regionalWeight(fromKg: pmRecord.dataweight_kg, toUnits: unitsType, toDecimalDigits: 1) ?? ""
            pmTime = Date(datestampHHmm: pmRecord.dataweight_time, referenceDate: date) ?? Date()
            do {
                try await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .pm, kg: pmRecord.dataweight_kg, time: pmTime, tracker: updatedTracker)
                print("•Load• Synced DB to HK for PM: \(pmRecord.dataweight_kg) kg")
            } catch {
                print("•Load• PM sync put error: \(error.localizedDescription)")
            }
        }
//        else {
//            let (timeStr, weightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: normalized, ampm: .pm)
//            if !weightStr.isEmpty {
//                pmWeightStr = weightStr
//                pmTime = Date(datestampHHmm: timeStr, referenceDate: date) ?? Date()
//                print("•Load• Pulled HK for PM (no DB): \(weightStr) at \(timeStr)")
//            }
//        }
        
        print("Loaded weights for \(key): AM \(amWeightStr), PM \(pmWeightStr), AM Time \(amTime.datestampHHmm), PM Time \(pmTime.datestampHHmm)")
        return WeightEntryData(amWeight: amWeightStr, pmWeight: pmWeightStr, amTime: amTime, pmTime: pmTime)
    }
    
    // *** Added: Save weight with HealthKit sync ***
    
    func saveWeight(for date: Date, amWeight: Double?, pmWeight: Double?, amTime: Date?, pmTime: Date?) async {
        let normalized = DateUtilities.gregorianCalendar.startOfDay(for: date)
        var updatedTracker = tracker(for: normalized)
        let unitType = UnitType.fromUserDefaults()
        var hasChanges = false
        
        // AM
        if let amWeight = amWeight, let amTime = amTime {
            if amWeight > 0 {
                let kg = unitType == .imperial ? amWeight / 2.204623 : amWeight
                let timeHHmm = amTime.datestampHHmm  // ← Safe
                
                let record = SqlDataWeightRecord(
                    date: normalized,
                    weightType: .am,
                    kg: kg,
                    timeHHmm: timeHHmm
                )
                
                updatedTracker.weightAM = record
                _ = await dbActor.saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: record.dataweight_ampm_pnid)
                
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .am, kg: kg, time: amTime, tracker: updatedTracker)
                    hasChanges = true
                } catch {
                    print("•Save• AM put error: \(error.localizedDescription)")
                }
            } else {
                if updatedTracker.weightAM != nil {
                    await deleteWeight(for: normalized, weightType: .am)
                }
                do {
                    try await HealthSynchronizer.shared.syncWeightClear(date: normalized, ampm: .am)
                    hasChanges = true
                } catch {
                    print("•Save• PM clear error: \(error.localizedDescription)")
                }
            }
        }
        
        // PM
        if let pmWeight = pmWeight, let pmTime = pmTime {
            if pmWeight > 0 {
                let kg = unitType == .imperial ? pmWeight / 2.204623 : pmWeight
                let timeHHmm = pmTime.datestampHHmm  // ← Safe
                
                let record = SqlDataWeightRecord(
                    date: normalized,
                    weightType: .pm,
                    kg: kg,
                    timeHHmm: timeHHmm
                )
                
                updatedTracker.weightPM = record
                _ = await dbActor.saveWeight(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: record.dataweight_ampm_pnid)
                
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .pm, kg: kg, time: pmTime, tracker: updatedTracker)
                    hasChanges = true
                } catch {
                    print("•Save• PM put error: \(error.localizedDescription)")
                }
            } else {
                if updatedTracker.weightPM != nil {
                    await deleteWeight(for: normalized, weightType: .pm)
                }
                do {
                    try await HealthSynchronizer.shared.syncWeightClear(date: normalized, ampm: .pm)
                    hasChanges = true
                } catch {
                    print("•Save• PM clear error: \(error.localizedDescription)")
                }
            }
        }
        
        if hasChanges {
            // ONLY SAVE TO DB ONCE
            updateTrackerInArray(updatedTracker)
            
            // SYNC TO HK
//            if let am = updatedTracker.weightAM {
//                try? await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .am, kg: am.dataweight_kg, time: amTime ?? normalized, tracker: updatedTracker)
//            }
//            if let pm = updatedTracker.weightPM {
//                try? await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .pm, kg: pm.dataweight_kg, time: pmTime ?? normalized, tracker: updatedTracker)
//            }
            
            let derivedCount = (updatedTracker.weightAM != nil ? 1 : 0) + (updatedTracker.weightPM != nil ? 1 : 0)
            await setCountAndUpdateStreak(for: .tweakWeightTwice, count: derivedCount, date: normalized)
            
            //added to prevent multiple calls/loading.  TBDz remove if doesn't work.
            await invalidateWeightDatesCache()
        }
    }
    
    func deleteWeight(for date: Date, weightType: DataWeightType) async {
        let normalized = DateUtilities.gregorianCalendar.startOfDay(for: date)  // ← CRITICAL
        let dateStr: String = normalized.datestampSid  // Now guaranteed Gregorian
        let ampmPnid = weightType == .am ? 0 : 1
        //let prefix = "\(dateStr) \(ampmPnid)"
        //  print("DELETE •VM• Prefix: '\(prefix)'")
        print("🟢 deleteWeight  \(dateStr) , ampmPnid: \(ampmPnid)")
        let success = await dbActor.deleteWeight(datePsid: dateStr, ampm: ampmPnid)
        await clearPendingWeight(for: normalized, weightType: weightType)
        if success {
            print("Deleted \(weightType.typeKey) weight from DB")
            var tracker = self.tracker(for: normalized)
            if weightType == .am { tracker.weightAM = nil } else {
                tracker.weightPM = nil
            }
            updateTrackerInArray(tracker)
            notifyDBUpdated(for: normalized)
            
            // Also clear HK
            try? await HealthSynchronizer.shared.syncWeightClear(date: normalized, ampm: weightType)
        } else {
            print("Failed to delete - but pending cleared will not resave")
        }
    }
    
    // *** Added: Update pending weights ***
    
    func updatePendingWeights(for date: Date, amWeight: String, pmWeight: String, amTime: Date, pmTime: Date) async {
        
//        let caller = Thread.callStackSymbols.prefix(10).joined(separator: "\n")
//        print("updatePendingWeights() called from:\n\(caller)\n")
        
        let key = date.datestampSid
        
        // Get current pending (if any)
        let current = pendingWeights[key]
        
        // Merge: use new value if provided (non-empty for weights), otherwise keep existing
        let mergedAMWeight = !amWeight.isEmpty ? amWeight : (current?.amWeight ?? "")
        let mergedPMWeight = !pmWeight.isEmpty ? pmWeight : (current?.pmWeight ?? "")
        let mergedAMTime = amWeight.isEmpty ? (current?.amTime ?? amTime) : amTime
        let mergedPMTime = pmWeight.isEmpty ? (current?.pmTime ?? pmTime) : pmTime
        
        // Remove if both weights empty
        if mergedAMWeight.isEmpty && mergedPMWeight.isEmpty {
            pendingWeights.removeValue(forKey: key)
            print("•Pending• Removed entry for \(key) (both empty after merge)")
        } else {
            pendingWeights[key] = PendingWeight(
                amWeight: mergedAMWeight,
                pmWeight: mergedPMWeight,
                amTime: mergedAMTime,
                pmTime: mergedPMTime
            )
            print("•Pending• Merged for \(key): AM='\(mergedAMWeight)', PM='\(mergedPMWeight)'")
        }
    }
    
    func clearPendingWeight(for date: Date, weightType: DataWeightType) async {
        let key = date.datestampSid
        guard var pending = pendingWeights[key] else { return }
        
        if weightType == .am {
            pending.amWeight = ""
            pending.amTime = Date()
        } else {
            pending.pmWeight = ""
            pending.pmTime = Date()
        }
        
        // Remove if both empty now
        if pending.amWeight.isEmpty && pending.pmWeight.isEmpty {
            pendingWeights.removeValue(forKey: key)
            print("•Pending• Cleared \(weightType.typeKey) and removed entry for \(key)")
            print("•Pending• Removed entry for \(key) after clear \(weightType.typeKey)")
        } else {
            pendingWeights[key] = pending
            print("•Pending• Cleared \(weightType.typeKey) for \(key): AM='\(pending.amWeight)', PM='\(pending.pmWeight)'")
            print("•Pending• Updated for \(key) after clear \(weightType.typeKey): AM='\(pendingWeights[key]?.amWeight ?? "")', PM='\(pendingWeights[key]?.pmWeight ?? "")'")
        }
    }
    
    // *** Added: Save pending weights ***
    func savePendingWeights() async {
        for (dateSid, weights) in pendingWeights {
            let amValue = Double(weights.amWeight.filter { !$0.isWhitespace }) ?? 0
            let pmValue = Double(weights.pmWeight.filter { !$0.isWhitespace }) ?? 0
            guard let date = Date(datestampSid: dateSid) else { continue }
            
            // Skip if value <=0 or time is distantPast (cleared marker)
            if amValue > 0 && weights.amTime > Date.distantPast {
                await saveWeight(for: date, amWeight: amValue, pmWeight: nil, amTime: weights.amTime, pmTime: nil)
            }
            if pmValue > 0 && weights.pmTime > Date.distantPast {
                await saveWeight(for: date, amWeight: nil, pmWeight: pmValue, amTime: nil, pmTime: weights.pmTime)
            }
        }
        pendingWeights.removeAll()
    }
    
    func loadTracker(forDate date: Date, isSilent: Bool = false) async {
        let calendar = DateUtilities.gregorianCalendar
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Early exit if already cached
        if trackers.contains(where: { calendar.isDate($0.date, inSameDayAs: normalizedDate) }) {
            return
        }
        
        isLoading = true
        
        // 1. Start with FULL default dict (all types, count=0)
        var fullItemsDict = await SqlDailyTracker.createItemsDict(for: normalizedDate)
        
        // 2. Fetch only the REAL records from DB
        let fetchedTracker = await dbActor.fetchDailyTracker(forDate: normalizedDate)
        
        // 3. Overwrite defaults with real data
        for (type, record) in fetchedTracker.itemsDict {
            fullItemsDict[type] = record
        }
        
        // 4. Build final tracker
        let finalTracker = SqlDailyTracker(
            date: normalizedDate,
            itemsDict: fullItemsDict,
            weightAM: fetchedTracker.weightAM,
            weightPM: fetchedTracker.weightPM
        )
        
        // 5. Cache and notify
        updateTrackerInArray(finalTracker)
        isLoading = false
        
        if !isSilent {
            await MainActor.run {
                NotificationCenter.default.post(name: .sqlDBUpdated, object: normalizedDate)
            }
        }
    }
    
    func loadTrackersForMonth(_ monthDate: Date, silent: Bool = true) async {
        let trackers = await dbActor.fetchTrackers(forMonth: monthDate)
        for tracker in trackers {
            updateTrackerInArray(tracker) // this already posts notification — but only if data actually changed
        }
        
        // ONLY post notification if silent == false
        if !silent {
            NotificationCenter.default.post(name: .sqlDBUpdated, object: nil)
        }
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
        let fetchedTrackers = await dbActor.fetchAllTrackers()
        return fetchedTrackers
    }
    
    var availableWeightMonths: [Date] {
        get async {
            let strings = await getDistinctDateStrings()  // Now cached!
            let cal = Calendar(identifier: .gregorian)
            let months = strings.compactMap { str -> Date? in
                guard let d = Date(datestampSid: str) else { return nil }
                return cal.date(from: cal.dateComponents([.year, .month], from: d))
            }
            return Array(Set(months)).sorted(by: >)
        }
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
        notifyDBUpdated(for: normalizedDate)
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
    static let mockDBTrigger = NotificationCenter.Publisher(center: .default, name: .sqlDBUpdated, object: nil)
}

// MARK: - Test Data Generation
extension SqlDailyTrackerViewModel {
    func generateHistoryTestData(days: Int) async throws {
        // print("    🟢 •GEN• baseWeight 65.0 kg, 143.0 lbs")
        print("GENERATE CALLED WITH DAYS = \(days)   <——————— LOOK HERE")
        let calendar = Calendar.current
        let today = Date()
        
        // Start from today at midnight
        var dateComponents = DateComponents(
            calendar: calendar,
            year: today.year, month: today.month, day: today.day,
            hour: 0, minute: 0, second: 0
        )
        var date = calendar.date(from: dateComponents)!
        
        // *** SMART: Check existing data ***
        let existingDates = await dbActor.fetchDistinctDates()
        let existingCount = existingDates.count
        print("    🟢 •GEN• Found \(existingCount) existing days")
        print("    🟢 •GEN• Existing dates range: \(existingDates.min() ?? "") to \(existingDates.max() ?? "")")
        
        let weightBase: Double = 65.0
        let weightAmplitude: Double = 2.0
        let weightCycleStep = (2 * Double.pi) / (30 * 2)
        
        let nToLog = 5
        print("    🟢 •GEN• Will generate \(days) days (skipping \(existingCount) existing)")
        
        var generatedCount = 0
        
        for i in 0..<days {
            let normalizedDate = calendar.startOfDay(for: date)
            let dateSid = normalizedDate.datestampSid
            
            // *** SKIP if already exists ***
            if existingDates.contains(dateSid) {
                print("    🟢 •GEN• Skipping existing: \(dateSid)")
                dateComponents = DateComponents(day: -1)
                date = calendar.date(byAdding: dateComponents, to: date)!
                continue
            }
            
            // --- COUNT RECORDS ---
            for countType in DataCountType.allCases {
                let countRecord = SqlDataCountRecord(
                    date: normalizedDate,
                    countType: countType,
                    count: 1,
                    streak: 0
                )
                _ = await saveCount(
                    record: countRecord,
                    oldDatePsid: countRecord.datacount_date_psid,
                    oldTypeNid: countType.nid
                )
            }
            
            // --- WEIGHT RECORDS ---
            let stepByAM = DateComponents(
                hour: Int.random(in: 7...8),
                minute: Int.random(in: 1...59)
            )
            let dateAM = calendar.date(byAdding: stepByAM, to: date)!
            
            let stepByPM = DateComponents(
                hour: Int.random(in: 21...23),
                minute: Int.random(in: 1...59)
            )
            let datePM = calendar.date(byAdding: stepByPM, to: date)!
            
            let x = Double(i)
            let weightAM = weightBase + weightAmplitude * sin(x * weightCycleStep)
            let weightPM = weightBase - weightAmplitude * sin(x * weightCycleStep)
            
            let amRecord = SqlDataWeightRecord(
                date: normalizedDate,
                weightType: .am,
                kg: weightAM,
                timeHHmm: dateAM.datestampHHmm
            )
            let pmRecord = SqlDataWeightRecord(
                date: normalizedDate,
                weightType: .pm,
                kg: weightPM,
                timeHHmm: datePM.datestampHHmm
            )
            
            _ = await saveWeight(record: amRecord, oldDatePsid: amRecord.dataweight_date_psid, oldAmpm: 0)
            _ = await saveWeight(record: pmRecord, oldDatePsid: pmRecord.dataweight_date_psid, oldAmpm: 1)
            
            // Log first few NEW entries
            if generatedCount < nToLog {
                let weightAmStr = String(format: "%.2f", weightAM)
                let weightPmStr = String(format: "%.2f", weightPM)
                print("        \(dateSid) [am] \(dateAM.datestampHHmm) \(weightAmStr)kg [pm] \(datePM.datestampHHmm) \(weightPmStr)kg")
            }
            // generatedDates.append(normalizedDate)
            generatedCount += 1
            dateComponents = DateComponents(day: -1)
            date = calendar.date(byAdding: dateComponents, to: date)!
        }
        
        // Refresh local cache
        await loadTrackersForTest(forMonth: Date())
        //print("    🟢 •GEN• COMPLETED: \(generatedCount) NEW days + \(existingCount) existing = \(generatedCount + existingCount) total")
        
        print("    GEN• SWIPE NOW — DATA IS LIVE!")
    }
    
    private func notifyDBUpdated(for date: Date) {
        Task { @MainActor in
            NotificationCenter.default.post(name: .sqlDBUpdated, object: date)
        }
    }  //private fuc
    
    func loadTrackersForTest(forMonth date: Date) async {
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
    
}

// MARK: - ensureDateIsInRange
extension SqlDailyTrackerViewModel {
    
    func ensureDateIsInRange(
        _ targetDate: Date,
        dateRange: inout [Date],
        currentIndex: inout Int,
        thenSelectIt: Bool = true
    ) {
        let calendar = Calendar.current
        let dayDate = calendar.startOfDay(for: targetDate)
        let today = calendar.startOfDay(for: Date())
        let finalDate = dayDate > today ? today : dayDate
        
        // First-time initialization
        if dateRange.isEmpty {
            dateRange = (-89...0).map { calendar.date(byAdding: .day, value: $0, to: today)! }
            currentIndex = dateRange.count - 1
            return
        }
        
        guard let earliest = dateRange.first, let latest = dateRange.last else { return }
        
        // Already in range?
        if finalDate >= earliest && finalDate <= latest {
            if thenSelectIt,
               let idx = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: finalDate) }) {
                currentIndex = idx
            }
            return
        }
        
        // Extend backward
        if finalDate < earliest {
            let daysToAdd = calendar.dateComponents([.day], from: finalDate, to: earliest).day!
            let newDates = (1...daysToAdd).reversed().map {
                calendar.date(byAdding: .day, value: -$0, to: earliest)!
            }
            dateRange.insert(contentsOf: newDates, at: 0)
            currentIndex += daysToAdd
        }
        // Extend forward (toward today, never past)
        else if finalDate > latest && finalDate <= today {
            let daysToAdd = calendar.dateComponents([.day], from: latest, to: finalDate).day!
            let newDates = (1...daysToAdd).map {
                calendar.date(byAdding: .day, value: $0, to: latest)!
            }
            dateRange.append(contentsOf: newDates)
        }
        
        // Final selection
        if thenSelectIt,
           let idx = dateRange.firstIndex(where: { calendar.isDate($0, inSameDayAs: finalDate) }) {
            currentIndex = idx
        }
    }
}

extension SqlDailyTrackerViewModel {
    
    /// Single source of truth — used by both preload and availableWeightMonths
    private func getDistinctDateStrings() async -> [String] {
        //        let caller = Thread.callStackSymbols.prefix(10).joined(separator: "\n")
        //        print("getDistinctDateStrings() called from:\n\(caller)\n")
        
        if let cached = cachedDistinctDateStrings {
            print("DB• Using cached distinct dates (\(cached.count)) — HIT")
            return cached
        }
        
        let dates = await dbActor.fetchDistinctDates()
        cachedDistinctDateStrings = dates
        print("DB• Fetched \(dates.count) distinct dates from DB — MISS")
        return dates
    }
    
    func invalidateWeightDatesCache() async {
        cachedDistinctDateStrings = nil
        print("Weight dates cache invalidated")
    }
    
    //for Weights
    func preloadAllDataForYearChart() async {
        let allDateStrings = await getDistinctDateStrings()
        let allDates = allDateStrings.compactMap { Date(datestampSid: $0) }
        
        guard !allDates.isEmpty else { return }
        
        let missingDates = allDates.filter { newDate in
            !trackers.contains { Calendar.current.isDate($0.date, inSameDayAs: newDate) }
        }
        
        print("YearChart: Preloading \(missingDates.count) missing days")
        
        for date in missingDates {
            await loadTracker(forDate: date, isSilent: true)
        }
        
        print("YearChart: All data loaded — \(trackers.count) days")
    }
}

extension SqlDailyTrackerViewModel {
    func preloadAllDataForServingsIfNeeded() async {
        guard !hasPreloadedServingsData else { return }
        hasPreloadedServingsData = true
        
        await preloadAllDataForYearChart()  // ← reuses your existing perfect preload
        print("ServingsHistory: All data preloaded from shared ViewModel")
    }
}

extension SqlDailyTrackerViewModel {
    
    func clearSQLFile() async {
        
        do {
            try await dbActor.resetDatabaseCompletely() // Use 'try' within the 'do' block
            
        } catch {
            // Handle the error here
            print("An error occurred clearing db: \(error.localizedDescription)")
            // You can update a @State property here to show a SwiftUI alert
        }
        
        await MainActor.run {
            self.refreshID = UUID()        // forces every view to re-run its body
            self.trackers = []              // optional: immediately show empty state
            // or just call loadData() again
            Task { await self.loadData() }
        }
        // need something like await preloadAllDataForYearChart()
    }
    
    func loadData() async {
        let newTrackers = await fetchAllTrackers()
        await MainActor.run {
            self.trackers = newTrackers
        }
    }
}
// MARK: - GenerateStreak Test Data
extension SqlDailyTrackerViewModel {
    
    /// Generate test data for streak visualization in SQLite database
    ///
    /// Creates the same streak patterns as the old Realm version:
    /// - 14-day streaks @ full goal
    /// - 7-day streaks
    /// - 2-day streaks
    /// - 100-day max streaks
    /// - Special cases with zeros to force 2-day and 7-day streaks
    func generateStreakTestData() async {
        let today = Date()
        let calendar = DateUtilities.gregorianCalendar
        let maxStreakDays = 100
        
        // Helper to set count on a specific date (updates streak automatically)
        func setCount(on date: Date, type: DataCountType, count: Int) async {
            await setCountAndUpdateStreak(for: type, count: count, date: date)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 2-day streak: Other Fruits @3
        // ────────────────────────────────────────────────────────────────
        for i in 0..<2 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .dozeFruitsOther, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 7-day streak: Berries @1
        // ────────────────────────────────────────────────────────────────
        for i in 0..<7 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .dozeBerries, count: 1)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 14-day streak: Beans @3
        // ────────────────────────────────────────────────────────────────
        for i in 0..<14 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .dozeBeans, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 100-day streaks @ full goal
        // ────────────────────────────────────────────────────────────────
        // Herbs & Spices @1
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .dozeSpices, count: 1)
        }
        
        // Whole Grains @3
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .dozeWholeGrains, count: 3)
        }
        
        // Beverages @6 (assuming goal is 6)
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .dozeBeverages, count: 6)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 14 days Water @3 (simple streak)
        // ────────────────────────────────────────────────────────────────
        for i in 0..<14 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .tweakMealWater, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // Negative Calorie (tweakMealNegCal) → forced 7-day streak with zeros
        // ────────────────────────────────────────────────────────────────
        // First fill 15 days with 3, then zero every 4th day (i % 4 == 3)
        for i in (0..<15).reversed() {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            let count = (i % 4 == 3) ? 0 : 3
            await setCount(on: date, type: .tweakMealNegCal, count: count)
        }
        // Then fix two days to complete a 7-day streak
        for i in [3, 11] {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .tweakMealNegCal, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // Incorporate Vinegar (tweakMealVinegar) → forced 2-day streak with zeros
        // ────────────────────────────────────────────────────────────────
        // First fill 14 days with 3
        for i in (0..<14).reversed() {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .tweakMealVinegar, count: 3)
        }
        // Then zero every third day to break into 2-day streaks
        for i in [2, 5, 8, 11, 14] {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .tweakMealVinegar, count: 0)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 100-day tweaks @ full goal
        // ────────────────────────────────────────────────────────────────
        // Nutritional Yeast @1
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .tweakDailyNutriYeast, count: 1)
        }
        
        // Cumin @2
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .tweakDailyCumin, count: 2)
        }
        
        // Green Tea @3
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, type: .tweakDailyGreenTea, count: 3)
        }
        
        // Optional: refresh UI / local cache if needed
        await loadTrackersForTest(forMonth: today)
    }
}
