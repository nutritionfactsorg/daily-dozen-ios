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
    static let shared = SqlDailyTrackerViewModel()
    
    @Published var tracker: SqlDailyTracker?
    @Published var trackers: [SqlDailyTracker] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var successMessage: String?
    @Published var pendingWeights: [String: PendingWeight] = [:] // *** Added: For pending weight storage ***
    @Published var refreshID = UUID()          // for refreshing after clearing db
    @Published var allWeightDataPoints: [WeightDataPoint] = []
    @Published var availableWeightMonths: [Date] = []
    
    private let dbActor = SqliteDatabaseActor.shared
    private var isSettingCount = false
    private var lastLoadedDate: Date?
    private var cachedDistinctDateStrings: [String]?
    private var hasPreloadedServingsData = false
    
    init() {
        Task {
            do {
                try await dbActor.setup()
                await MainActor.run {
                    // print("•INFO•VM• SqlDailyTrackerViewModel: Database initialized")
                }
                // •TRACE• Optional: Uncomment to load & print current month's trackers on init
                //await loadTrackers(forMonth: Date())
                // for debug these two awaits
                // await SqliteDatabaseActor.shared.printSchema()
                // await SqliteDatabaseActor.shared.dumpAllRows()
            } catch {
                await MainActor.run {
                    self.error = "Database initialization failed: \(error)"
                    print("•ERROR•VM• SqlDailyTrackerViewModel: Database initialization failed: \(error)")
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
        //print("•VERBOSE•DB• updateDatabase called — weightAM: \(tracker.weightAM?.dataweight_kg ?? -1), weightPM: \(tracker.weightPM?.dataweight_kg ?? -1)")
        
        //print("•VERBOSE•DB• Updating DB for date \(tracker.date.formatted(date: .numeric, time: .omitted)): AM kg = \(tracker.weightAM?.dataweight_kg ?? -1), PM kg = \(tracker.weightPM?.dataweight_kg ?? -1)")
        
        if let am = tracker.weightAM {
            _ = await dbActor.saveWeightToDB(record: am, oldDatePsid: am.dataweight_date_psid, oldAmpm: am.dataweight_ampm_pnid)
        }
        
        if let pm = tracker.weightPM {
            _ = await dbActor.saveWeightToDB(record: pm, oldDatePsid: pm.dataweight_date_psid, oldAmpm: pm.dataweight_ampm_pnid)
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
        print("•TRACE• SqlDailyTrackerViewModel loadWeights()")
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
        //else {
        //    // No DB: Pull from HK for display (user decision)
        //    let (timeStr, weightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: normalized, ampm: .am)
        //    if !weightStr.isEmpty {
        //        amWeightStr = weightStr
        //        amTime = Date(datestampHHmm: timeStr, referenceDate: date) ?? Date()
        //        print("•Load• Pulled HK for AM (no DB): \(weightStr) at \(timeStr)")
        //    }
        //}
        
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
        //else {
        //    let (timeStr, weightStr) = await HealthSynchronizer.shared.syncWeightToShow(date: normalized, ampm: .pm)
        //    if !weightStr.isEmpty {
        //        pmWeightStr = weightStr
        //        pmTime = Date(datestampHHmm: timeStr, referenceDate: date) ?? Date()
        //        print("•Load• Pulled HK for PM (no DB): \(weightStr) at \(timeStr)")
        //    }
        //}
        
        print("•TRACE• SqlDailyTrackerViewModel Loaded weights for \(key): AM \(amWeightStr), PM \(pmWeightStr), AM Time \(amTime.datestampHHmm), PM Time \(pmTime.datestampHHmm)")
        return WeightEntryData(amWeight: amWeightStr, pmWeight: pmWeightStr, amTime: amTime, pmTime: pmTime)
    }
    
    // *** Added: Save weight with HealthKit sync ***
    
    func saveWeight(date: Date, amWeight: Double?, pmWeight: Double?, amTime: Date?, pmTime: Date?) async {
        print("•TRACE•SAVE• SqlDailyTrackerViewModel saveWeight()")
        let normalized = DateUtilities.gregorianCalendar.startOfDay(for: date)
        var updatedTracker = tracker(for: normalized)
        let unitType = UnitType.fromUserDefaults()
        //var hasChanges = false  // •HACK•CHECK•
        
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
                _ = await dbActor.saveWeightToDB(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: record.dataweight_ampm_pnid)
                
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .am, kg: kg, time: amTime, tracker: updatedTracker)
                    //hasChanges = true  // •HACK•CHECK•
                } catch {
                    print("•WARN•AUTH•SAVE• SqlDailyTrackerViewModel AM put failed: \(error.localizedDescription)")
                }
            } else {
                if updatedTracker.weightAM != nil {
                    await deleteWeight(for: normalized, weightType: .am)
                }
                do {
                    try await HealthSynchronizer.shared.syncWeightClear(date: normalized, ampm: .am)
                    //hasChanges = true  // •HACK•CHECK•
                } catch {
                    print("•WARN•AUTH•SAVE• PM clear failed: \(error.localizedDescription)")
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
                _ = await dbActor.saveWeightToDB(record: record, oldDatePsid: record.dataweight_date_psid, oldAmpm: record.dataweight_ampm_pnid)
                
                do {
                    try await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .pm, kg: kg, time: pmTime, tracker: updatedTracker)
                    //hasChanges = true
                } catch {
                    print("•WARN•AUTH•SAVE• PM put failed: \(error.localizedDescription)")
                }
            } else {
                if updatedTracker.weightPM != nil {
                    await deleteWeight(for: normalized, weightType: .pm)
                }
                do {
                    try await HealthSynchronizer.shared.syncWeightClear(date: normalized, ampm: .pm)
                    //hasChanges = true
                } catch {
                    print("•WARN•AUTH•SAVE• PM clear failed: \(error.localizedDescription)")
                }
            }
        }
        
        //if hasChanges { •HACK•CHECK• what should actually set hasChanges without HK
        // ONLY SAVE TO DB ONCE
        updateTrackerInArray(updatedTracker)
        
        // SYNC TO HK
        //if let am = updatedTracker.weightAM {
        //    try? await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .am, kg: am.dataweight_kg, time: amTime ?? normalized, tracker: updatedTracker)
        //}
        //if let pm = updatedTracker.weightPM {
        //    try? await HealthSynchronizer.shared.syncWeightPut(date: normalized, ampm: .pm, kg: pm.dataweight_kg, time: pmTime ?? normalized, tracker: updatedTracker)
        //}
        let amCount = updatedTracker.weightAM != nil ? 1 : 0
        let pmCount = updatedTracker.weightPM != nil ? 1 : 0
        let derivedCount = amCount + pmCount
        await setCountAndUpdateStreak(countType: .tweakWeightTwice, count: derivedCount, date: normalized)

        //added to prevent multiple calls/loading.  TBDz remove if doesn't work.
        await invalidateWeightDatesCache()
        //}
    }
    
    func deleteWeight(for date: Date, weightType: DataWeightType) async {
        let normalized = DateUtilities.gregorianCalendar.startOfDay(for: date)  // ← CRITICAL
        let dateStr: String = normalized.datestampSid  // Now guaranteed Gregorian
        let ampmPnid = weightType == .am ? 0 : 1
        //let prefix = "\(dateStr) \(ampmPnid)"
        //  print("DELETE •VM• Prefix: '\(prefix)'")
        print("deleteWeight  \(dateStr) , ampmPnid: \(ampmPnid)")
        let success = await dbActor.deleteWeight(datePsid: dateStr, ampm: ampmPnid)
        await clearPendingWeight(for: normalized, weightType: weightType)
        if success {
            print("Deleted \(weightType.typeKey) weight from DB")
            var tracker = self.tracker(for: normalized)
            if weightType == .am { tracker.weightAM = nil } else {
                tracker.weightPM = nil
            }
            updateTrackerInArray(tracker)
            
            let derivedCount = (tracker.weightAM != nil ? 1 : 0) + (tracker.weightPM != nil ? 1 : 0)
            print("•DERIVED•DELETE• Updating .tweakWeightTwice derived count to \(derivedCount) for \(normalized.datestampSid)")
            await setCountAndUpdateStreak(countType: .tweakWeightTwice, count: derivedCount, date: normalized)
            await invalidateWeightDatesCache()
            
            notifyDBUpdated(for: normalized)
            
            // Also clear HK
            try? await HealthSynchronizer.shared.syncWeightClear(date: normalized, ampm: weightType)
        } else {
            print("Failed to delete - but pending cleared will not resave")
        }
    }
    
    // *** Added: Update pending weights ***
    
    func updatePendingWeights(for date: Date, amWeight: String, pmWeight: String, amTime: Date, pmTime: Date) async {
        
        //let caller = Thread.callStackSymbols.prefix(10).joined(separator: "\n")
        //print("updatePendingWeights() called from:\n\(caller)\n")
        
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
            //let amValue = Double(weights.amWeight.filter { !$0.isWhitespace }) ?? 0
            //let pmValue = Double(weights.pmWeight.filter { !$0.isWhitespace }) ?? 0
            let amValue = weights.amWeight.toWeightDouble() ?? 0
            let pmValue = weights.pmWeight.toWeightDouble() ?? 0
            guard let date = Date(datestampSid: dateSid) else { continue }
            
            // Skip if value <=0 or time is distantPast (cleared marker)
            if amValue > 0 && weights.amTime > Date.distantPast {
                await saveWeight(date: date, amWeight: amValue, pmWeight: nil, amTime: weights.amTime, pmTime: nil)
            }
            if pmValue > 0 && weights.pmTime > Date.distantPast {
                await saveWeight(date: date, amWeight: nil, pmWeight: pmValue, amTime: nil, pmTime: weights.pmTime)
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
    
    /// Note: used by `generateHistoryTestData`
    private func saveWeightForTest(record: SqlDataWeightRecord, oldDatePsid: String?, oldAmpm: Int?) async {
        let success = await dbActor.saveWeightToDB(record: record, oldDatePsid: oldDatePsid, oldAmpm: oldAmpm)
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
    
    func getCount(countType: DataCountType, date: Date) -> Int {
        tracker(for: date).itemsDict[countType]?.datacount_count ?? 0
    }
    
    func setCount(countType: DataCountType, count: Int, date: Date) async {
        let calendar = DateUtilities.gregorianCalendar
        let normalized = calendar.startOfDay(for: date)
        var mutableTracker = tracker(for: normalized)  // Gets or creates/caches
        await mutableTracker.setCount(typeKey: countType, count: count)
        if let updatedRecord = mutableTracker.itemsDict[countType] {
            let success = await dbActor.saveCount(
                record: updatedRecord,
                oldDatePsid: updatedRecord.datacount_date_psid,
                oldTypeNid: countType.nid
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
    
    //func setWeight(weightType: DataWeightType, kg: Double) async {
    //    guard kg > 0, kg < 500, let tracker = tracker else {
    //        error = "Please enter a valid weight (0 < weight < 500 kg)"
    //        return
    //    }
    //    var mutableTracker = tracker
    //    let timeHHmm = weightType == .am ? (mutableTracker.weightAM?.dataweight_time ?? Date().datestampHHmm) : (mutableTracker.weightPM?.dataweight_time ?? Date().datestampHHmm)
    //    let newRecord = SqlDataWeightRecord(
    //        date: mutableTracker.date,
    //        weightType: weightType,
    //        kg: kg,
    //        timeHHmm: timeHHmm
    //    )
    //    if weightType == .am {
    //        mutableTracker.weightAM = newRecord
    //    } else {
    //        mutableTracker.weightPM = newRecord
    //    }
    //    self.tracker = mutableTracker
    //    await saveWeight(
    //        record: newRecord,
    //        oldDatePsid: newRecord.pidKeys.datestampSid,
    //        oldAmpm: weightType == .am ? 0 : 1
    //    )
    //}
    
    func fetchTrackers(forMonth date: Date) async -> [SqlDailyTracker] {
        let trackers = await dbActor.fetchTrackers(forMonth: date)
        print("•INFO•VM• Fetched \(trackers.count) trackers for month \(date.datestampSid): \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg, PM=\($0.weightPM?.dataweight_kg ?? 0) kg" })")
        return trackers
    }
    
    func fetchTrackers() async -> [SqlDailyTracker] {
        let trackers = await dbActor.fetchTrackers()
        print("•INFO•VM• Fetched \(trackers.count) trackers: \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg, PM=\($0.weightPM?.dataweight_kg ?? 0) kg" })")
        return trackers
    }
    
    func fetchAllTrackers() async -> [SqlDailyTracker] {
        let fetchedTrackers = await dbActor.fetchAllTrackers()
        return fetchedTrackers
    }
    
    //var availableWeightMonths: [Date] {
    //    get async {
    //        let strings = await getDistinctDateStrings()  // Now cached!
    //        let cal = Calendar(identifier: .gregorian)
    //        let months = strings.compactMap { str -> Date? in
    //            guard let d = Date(datestampSid: str) else { return nil }
    //            return cal.date(from: cal.dateComponents([.year, .month], from: d))
    //        }
    //        return Array(Set(months)).sorted(by: >)
    //    }
    //}
}

extension SqlDailyTrackerViewModel {
    /// •STREAK•V21•OPTION• NOT YET USED aka "`setCount`"
    func setCountCalc(countType: DataCountType, count: Int, date: Date) async {
        isSettingCount = true
        let normalized = DateUtilities.gregorianCalendar.startOfDay(for: date)
        var updatedTracker = tracker(for: normalized)
        
        let record = SqlDataCountRecord(
            date: normalized,
            countType: countType,
            count: count,
            streak: 0  // Ignored now, but keep for schema compat
        )
        
        updatedTracker.itemsDict[countType] = record
        _ = await dbActor.saveCount(
            record: record,
            oldDatePsid: record.datacount_date_psid,
            oldTypeNid: countType.nid
        )
        
        updateTrackerInArray(updatedTracker)
        isSettingCount = false
    }
    
    func setCountAndUpdateStreak(countType: DataCountType, count: Int, date: Date) async {
        let calendar = DateUtilities.gregorianCalendar
        let normalizedDate = calendar.startOfDay(for: date)
        // Update the count
        await setCount(countType: countType, count: count, date: normalizedDate)
        notifyDBUpdated(for: normalizedDate)
    }
    
    /// •STREAK•V21•DIRECT•
    func currentStreak(countType: DataCountType, on referenceDate: Date) async -> Int {
        return await dbActor.computeStreak(countType: countType, fromDate: referenceDate)
    }
}

// MARK: - Test Data Generation
extension SqlDailyTrackerViewModel {
    func generateHistoryTestData(days: Int) async throws {
        // print("•INFO•GEN• baseWeight 65.0 kg, 143.0 lbs")
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
        print("•INFO•GEN• Found \(existingCount) existing days")
        print("•INFO•GEN• Existing dates range: \(existingDates.min() ?? "") to \(existingDates.max() ?? "")")
        
        let weightBase: Double = 65.0
        let weightAmplitude: Double = 2.0
        let weightCycleStep = (2 * Double.pi) / (30 * 2)
        
        let nToLog = 5
        print("•INFO•GEN• Will generate \(days) days (skipping \(existingCount) existing)")
        
        var generatedCount = 0
        var generatedMonths: Set<Date> = []  // Collect unique start-of-month dates for generated days
        
        for i in 0..<days {
            let normalizedDate = calendar.startOfDay(for: date)
            let dateSid = normalizedDate.datestampSid
            
            // *** SKIP if already exists ***
            if existingDates.contains(dateSid) {
                print("•INFO•GEN• Skipping existing: \(dateSid)")
                dateComponents = DateComponents(day: -1)
                date = calendar.date(byAdding: dateComponents, to: date)!
                continue
            }
            
            // --- COUNT RECORDS ---
            for countType in DataCountType.allCases {
                let countValue = (countType == .tweakWeightTwice) ? 2 : 1
                let countRecord = SqlDataCountRecord(
                    date: normalizedDate,
                    countType: countType,
                    count: countValue,
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
            
            _ = await saveWeightForTest(record: amRecord, oldDatePsid: amRecord.dataweight_date_psid, oldAmpm: 0)
            _ = await saveWeightForTest(record: pmRecord, oldDatePsid: pmRecord.dataweight_date_psid, oldAmpm: 1)
            
            let monthComponents = DateComponents(year: normalizedDate.year, month: normalizedDate.month, day: 1)
            if let monthStart = calendar.date(from: monthComponents) {
                generatedMonths.insert(monthStart)
            }
            
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
        
        // Refresh local cache for all generated months
        for month in generatedMonths.sorted() {
            await loadTrackersForTest(forMonth: month)
        }
        
        // Also load current month if not already included
        let currentMonthComponents = DateComponents(year: today.year, month: today.month, day: 1)
        if let currentMonthStart = calendar.date(from: currentMonthComponents), !generatedMonths.contains(currentMonthStart) {
            await loadTrackersForTest(forMonth: currentMonthStart)
        }
        
        print("•INFO•GEN• SWIPE NOW — DATA IS LIVE!")
    }
    
    private func notifyDBUpdated(for date: Date) {
        print("•INFO•VM•DB• notifyDBUpdated() for '\(date.datestampSid) \(date.datestampHHmm)'")
        Task { @MainActor in
            print("•INFO•VM•DB• notifyDBUpdated() Task Notification @MainActor")
            NotificationCenter.default.post(name: .sqlDBUpdated, object: date)
        }
    }
    
    func loadTrackersForTest(forMonth date: Date) async {
        let calendar = DateUtilities.gregorianCalendar
        let fetched = await dbActor.fetchTrackers(forMonth: date)
        await MainActor.run {
            // Merge without duplicates
            for newTracker in fetched {
                trackers = trackers.filter { !calendar.isDate($0.date, inSameDayAs: newTracker.date) } + [newTracker]
            }
            print("•INFO•VM• Loaded \(fetched.count) trackers for month \(date.datestampSid)")
        }
    }
    
}

// MARK: - ensureDateIsInRange
extension SqlDailyTrackerViewModel {
    
    func ensureDateIsInRange(
        _ targetDate: Date,
        dateRange: inout [Date],
        currentIndex: inout Int,
        thenSelectIt: Bool // = true
    ) {
        let calendar = Calendar.current
        let dayDate = calendar.startOfDay(for: targetDate)
        let today = calendar.startOfDay(for: Date())
        let finalDate = dayDate > today ? today : dayDate
        
        // First-time initialization
        if dateRange.isEmpty {
            // Initialize with 90 days ending at min(today, finalDate + some buffer), but ensure finalDate is included
            let initDaysBefore = 44  // Roughly half of 90, adjust as needed
            let initDaysAfter = 45
            var startDate = calendar.date(byAdding: .day, value: -initDaysBefore, to: finalDate)!
            var endDate = calendar.date(byAdding: .day, value: initDaysAfter, to: finalDate)!
            
            // Cap end at today
            if endDate > today {
                endDate = today
            }
            // If start is after end (unlikely), adjust
            if startDate > endDate {
                startDate = endDate
            }
            
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            let totalDays = (components.day ?? 0) + 1  // Inclusive
            dateRange = (0..<totalDays).map { calendar.date(byAdding: .day, value: $0, to: startDate)! }
            
            // No early return — proceed to selection below
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
            currentIndex += daysToAdd  // Adjust index since inserting at front
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
    @MainActor
    func preloadAllDataForYearChart() async {
        let allDateStrings = await getDistinctDateStrings()
        let allDates = allDateStrings.compactMap { Date(datestampSid: $0) }
        
        guard !allDates.isEmpty else {
            
            trackers = []
            allWeightDataPoints = []
            availableWeightMonths = []
            return
        }
        
        let missingDates = allDates.filter { newDate in
            !trackers.contains { Calendar.current.isDate($0.date, inSameDayAs: newDate) }
        }
        
        print("YearChart: Preloading \(missingDates.count) missing days")
        
        for date in missingDates {
            await loadTracker(forDate: date, isSilent: true)
        }
        
        trackers.sort { $0.date < $1.date }
        
        print("YearChart: All data loaded — \(trackers.count) days")
        
        // Compute available months (for navigation)
        let calendar = Calendar(identifier: .gregorian)
        let monthsSet = Set(trackers.compactMap { tracker in
            calendar.date(from: calendar.dateComponents([.year, .month], from: tracker.date))
        })
        availableWeightMonths = Array(monthsSet).sorted(by: >)  // newest first
        
        // Precompute all chart data points
        let unitType = UnitType.fromUserDefaults()
        var points: [WeightDataPoint] = []
        points.reserveCapacity(trackers.count * 2)
        
        for tracker in trackers {
            if let amKg = tracker.weightAM?.dataweight_kg, amKg > 0 {
                let weight = unitType == .metric ? amKg : tracker.weightAM!.lbs
                points.append(WeightDataPoint(date: tracker.date, weight: weight, weightType: .am))
            }
            if let pmKg = tracker.weightPM?.dataweight_kg, pmKg > 0 {
                let weight = unitType == .metric ? pmKg : tracker.weightPM!.lbs
                points.append(WeightDataPoint(date: tracker.date, weight: weight, weightType: .pm))
            }
        }
        
        allWeightDataPoints = points
        print("YearChart: Precomputed \(points.count) weight data points")
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
        func setCount(on date: Date, countType: DataCountType, count: Int) async {
            await setCountAndUpdateStreak(countType: countType, count: count, date: date)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 2-day streak: Other Fruits @3
        // ────────────────────────────────────────────────────────────────
        for i in 0..<2 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .dozeFruitsOther, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 7-day streak: Berries @1
        // ────────────────────────────────────────────────────────────────
        for i in 0..<7 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .dozeBerries, count: 1)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 14-day streak: Beans @3
        // ────────────────────────────────────────────────────────────────
        for i in 0..<14 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .dozeBeans, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 100-day streaks @ full goal
        // ────────────────────────────────────────────────────────────────
        // Herbs & Spices @1
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .dozeSpices, count: 1)
        }
        
        // Whole Grains @3
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .dozeWholeGrains, count: 3)
        }
        
        // Beverages @6 (assuming goal is 6)
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .dozeBeverages, count: 6)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 14 days Water @3 (simple streak)
        // ────────────────────────────────────────────────────────────────
        for i in 0..<14 {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .tweakMealWater, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // Negative Calorie (tweakMealNegCal) → forced 7-day streak with zeros
        // ────────────────────────────────────────────────────────────────
        // First fill 15 days with 3, then zero every 4th day (i % 4 == 3)
        for i in (0..<15).reversed() {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            let count = (i % 4 == 3) ? 0 : 3
            await setCount(on: date, countType: .tweakMealNegCal, count: count)
        }
        // Then fix two days to complete a 7-day streak
        for i in [3, 11] {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .tweakMealNegCal, count: 3)
        }
        
        // ────────────────────────────────────────────────────────────────
        // Incorporate Vinegar (tweakMealVinegar) → forced 2-day streak with zeros
        // ────────────────────────────────────────────────────────────────
        // First fill 14 days with 3
        for i in (0..<14).reversed() {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .tweakMealVinegar, count: 3)
        }
        // Then zero every third day to break into 2-day streaks
        for i in [2, 5, 8, 11, 14] {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .tweakMealVinegar, count: 0)
        }
        
        // ────────────────────────────────────────────────────────────────
        // 100-day tweaks @ full goal
        // ────────────────────────────────────────────────────────────────
        // Nutritional Yeast @1
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .tweakDailyNutriYeast, count: 1)
        }
        
        // Cumin @2
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .tweakDailyCumin, count: 2)
        }
        
        // Green Tea @3
        for i in 0..<maxStreakDays {
            let date = calendar.startOfDay(for: today.adding(days: -i))
            await setCount(on: date, countType: .tweakDailyGreenTea, count: 3)
        }
        
        // Optional: refresh UI / local cache if needed
        await loadTrackersForTest(forMonth: today)
    }
}
