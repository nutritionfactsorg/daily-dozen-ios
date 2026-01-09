//
//  SQLiteDatabaseActor.swift
//  SQLiteFramework
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable identifier_name
// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length

enum DatabaseError: Error {
    case invalidURL
    case openFailed(String)
    case tableCreationFailed
    case cleanupFailed
}

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

import SQLite3
import Foundation
import SwiftUI

@globalActor
actor SqliteDatabaseActor {
    static let shared = SqliteDatabaseActor()
    private var db: OpaquePointer?
    private let dbURL: URL?
    private var isInitialized: Bool = false // Add to track setup
    private let fm = FileManager.default
    
    private init() {
        let databaseDir = URL
            .libraryDirectory
            .appending(component: "Database", directoryHint: .isDirectory)

        self.dbURL = databaseDir
            .appending(component: "NutritionFacts_v4.sqlite3", directoryHint: .notDirectory)
    }
    
    // MARK: - Public API: Always call this first in every DB function
    func ensureInitialized() async throws {
        if isInitialized, db != nil { return }
        try await setup()
    }
    
    // MARK: - DEBUGGING
    
    //For debugging
    func printSchema() {
        let sql = "PRAGMA table_info(dataweight_table);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            print("TABLE SCHEMA for dataweight_table:")
            while sqlite3_step(stmt) == SQLITE_ROW {
                let cid = sqlite3_column_int(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let type = String(cString: sqlite3_column_text(stmt, 2))
                let notnull = sqlite3_column_int(stmt, 3)
                let dflt = sqlite3_column_text(stmt, 4).map { String(cString: $0) } ?? "nil"
                let pk = sqlite3_column_int(stmt, 5)
                print("  [\(cid)] \(name) \(type) notnull=\(notnull) default='\(dflt)' pk=\(pk)")
            }
            sqlite3_finalize(stmt)
        } else {
            print("TABLE dataweight_table NOT FOUND")
        }
    }
    //debug dataweight_table
    func dumpAllRows() {
        let sql = "SELECT * FROM dataweight_table;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            print("ALL ROWS in dataweight_table:")
            while sqlite3_step(stmt) == SQLITE_ROW {
                let psid = String(cString: sqlite3_column_text(stmt, 0))
                let ampm = sqlite3_column_int(stmt, 1)
                let kg = sqlite3_column_double(stmt, 2)
                let time = String(cString: sqlite3_column_text(stmt, 3))
                print("  ROW: psid='\(psid)', ampm=\(ampm), kg=\(kg), time='\(time)'")
            }
            sqlite3_finalize(stmt)
        }
    }
    // MARK: - Setup
    
    func setup() async throws {
        guard !isInitialized else { return }
        await close()
        guard let dbURL = dbURL else { throw DatabaseError.invalidURL }
        print("🟢 •DB• Opening database at \(dbURL.path)")
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else {
            let error = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.openFailed(error)
            // return
        }
        
        let createWeightTable = """
        CREATE TABLE IF NOT EXISTS dataweight_table (
            dataweight_date_psid TEXT NOT NULL CHECK(dataweight_date_psid GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
            dataweight_ampm_pnid INTEGER NOT NULL CHECK(dataweight_ampm_pnid IN (0, 1)),
            dataweight_kg REAL NOT NULL,
            dataweight_time TEXT NOT NULL CHECK(dataweight_time GLOB '[0-2][0-9]:[0-5][0-9]'),
            PRIMARY KEY (dataweight_date_psid, dataweight_ampm_pnid)
        );
        """
        let createCountTable = """
        CREATE TABLE IF NOT EXISTS datacount_table (
            datacount_date_psid TEXT NOT NULL CHECK(datacount_date_psid GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
            datacount_kind_pfnid INTEGER NOT NULL,
            datacount_count INTEGER NOT NULL CHECK(datacount_count >= 0),
            datacount_streak INTEGER NOT NULL CHECK(datacount_streak >= 0),
            PRIMARY KEY (datacount_date_psid, datacount_kind_pfnid)
        );
        """
        if !execute(query: createWeightTable) || !execute(query: createCountTable) {
            print(":ERROR: Failed to create tables")
        }
        
        let cleanWeightQuery = """
        DELETE FROM dataweight_table WHERE dataweight_date_psid IS NULL OR dataweight_date_psid = ''
        OR typeof(dataweight_date_psid) != 'text' OR dataweight_time IS NULL OR dataweight_time = ''
        OR typeof(dataweight_time) != 'text';
        """
        let cleanCountQuery = """
        DELETE FROM datacount_table WHERE datacount_date_psid IS NULL OR datacount_date_psid = ''
        OR typeof(datacount_date_psid) != 'text';
        """
        if !execute(query: cleanWeightQuery) || !execute(query: cleanCountQuery) {
            print(":ERROR: Failed to clean invalid records")
        }
        
        isInitialized = true
        print("🟢 •DB• Database initialized at \(dbURL.path)")
        // await dumpDatabase()   use for debugging only
        
        let schemaSql = "PRAGMA table_info(dataweight_table);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, schemaSql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(stmt, 1))
                print("COLUMN: \(name)")
            }
            sqlite3_finalize(stmt)
        }
    }
    
    func reloadDatabaseIfNeeded() async throws {
        // Always close + reopen when the file on disk changed
        await close()
        try await setup()
    }
    
    // MARK: - Weight Operations
    
    func fetchWeightRecords(forDate date: String) async -> [SqlDataWeightRecord] { // Make async
        do {
            try await ensureInitialized()
        } catch {
            print(":ERROR: 🔴 •DB• fetchWeightRecords: Failed to setup database: \(error)")
            return []
        }
        guard !date.isEmpty, Date(datestampSid: date) != nil else {
            print(":ERROR: Invalid date for fetchWeightRecords: \(date)")
            return []
        }
        
        var records: [SqlDataWeightRecord] = []
        let query = """
        SELECT dataweight_date_psid, dataweight_ampm_pnid, dataweight_kg, dataweight_time
        FROM dataweight_table WHERE dataweight_date_psid = ?;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK,
              sqlite3_bind_text(stmt, 1, date.cString(using: .utf8), -1, SQLITE_TRANSIENT) == SQLITE_OK else {
            print(":ERROR: Prepare/bind failed for fetchWeightRecords: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_finalize(stmt)
            return []
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let row: [Any?] = [
                sqlite3_column_text(stmt, 0).map { String(cString: $0) },
                Int(sqlite3_column_int(stmt, 1)),
                sqlite3_column_double(stmt, 2),
                sqlite3_column_text(stmt, 3).map { String(cString: $0) }
            ]
            if let record = SqlDataWeightRecord(row: row) {
                records.append(record)
            } else {
                print(":ERROR: Invalid weight record for date: \(date), row: \(row)")
            }
        }
        sqlite3_finalize(stmt)
        // print("🟢 •DB• Fetched \(records.count) weight records for \(date)")
        return records
    }
    
    func saveWeight(record: SqlDataWeightRecord, oldDatePsid: String?, oldAmpm: Int?) async -> Bool {
        
        do {
            try await ensureInitialized()
        } catch {
            print(":ERROR: DB unavailable in saveWeight: \(error)")
            return false
        }
        
        guard Date(datestampSid: record.dataweight_date_psid) != nil,
              [0, 1].contains(record.dataweight_ampm_pnid),
              record.dataweight_kg >= 0,
              record.dataweight_time.matches("^[0-2][0-9]:[0-5][0-9]$") else {
            print(":ERROR: Invalid record: \(record.idString), kg=\(record.dataweight_kg), time=\(record.dataweight_time)")
            return false
        }
        
        sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil)
        
        if let oldDatePsid, let oldAmpm, !oldDatePsid.isEmpty, Date(datestampSid: oldDatePsid) != nil {
            let deleteQuery = "DELETE FROM dataweight_table WHERE dataweight_date_psid = ? AND dataweight_ampm_pnid = ?;"
            var stmt: OpaquePointer?
            guard sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) == SQLITE_OK else {
                print(":ERROR: Delete prepare failed: \(String(cString: sqlite3_errmsg(db)))")
                sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
                return false
            }
            
            let trimmedOldPsid = oldDatePsid.trimmingCharacters(in: .whitespacesAndNewlines)
            _ = trimmedOldPsid.withCString { sqlite3_bind_text(stmt, 1, $0, -1, SQLITE_TRANSIENT) }
            sqlite3_bind_int(stmt, 2, Int32(oldAmpm))
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                print(":ERROR: Delete step failed: \(String(cString: sqlite3_errmsg(db)))")
                sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
                sqlite3_finalize(stmt)
                return false
            }
            sqlite3_finalize(stmt)
        }
        
        let insertQuery = "INSERT INTO dataweight_table (dataweight_date_psid, dataweight_ampm_pnid, dataweight_kg, dataweight_time) VALUES (?, ?, ?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK else {
            print(":ERROR: Insert prepare failed: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
            return false
        }
        
        let psid = record.dataweight_date_psid.trimmingCharacters(in: .whitespacesAndNewlines)
        _ = psid.withCString { sqlite3_bind_text(stmt, 1, $0, -1, SQLITE_TRANSIENT) }
        sqlite3_bind_int(stmt, 2, Int32(record.dataweight_ampm_pnid))
        sqlite3_bind_double(stmt, 3, record.dataweight_kg)
        _ = record.dataweight_time.withCString { sqlite3_bind_text(stmt, 4, $0, -1, SQLITE_TRANSIENT) }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print(":ERROR: Insert step failed: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
            sqlite3_finalize(stmt)
            return false
        }
        sqlite3_finalize(stmt)
        
        sqlite3_exec(db, "COMMIT;", nil, nil, nil)
        print("🟢 •DB• Saved weight for \(record.idString): \(record.dataweight_kg) kg")
        return true
    }
    
    // MARK: - DELETE WEIGHT
    
    func deleteWeight(datePsid: String, ampm: Int) async -> Bool {
        guard let db = db else { return false }
        print("🟢 •DB• Database at \(String(describing: dbURL?.path))")
        
        // SELECT for debugging (optional — remove if not needed)
        let selectSql = "SELECT * FROM dataweight_table WHERE dataweight_date_psid = ? AND dataweight_ampm_pnid = ?;"
        var selectStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, selectSql, -1, &selectStmt, nil) == SQLITE_OK {
            _ = datePsid.withCString { cString in
                sqlite3_bind_text(selectStmt, 1, cString, -1, unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self))
            }
            sqlite3_bind_int(selectStmt, 2, Int32(ampm))
            if sqlite3_step(selectStmt) == SQLITE_ROW {
                let psid = String(cString: sqlite3_column_text(selectStmt, 0))
                let ampm_val = sqlite3_column_int(selectStmt, 1)
                let kg = sqlite3_column_double(selectStmt, 2)
                let time = String(cString: sqlite3_column_text(selectStmt, 3))
                print("FOUND ROW: psid='\(psid)', ampm=\(ampm_val), kg=\(kg), time='\(time)'")
            } else {
                print("NO ROW FOUND with psid='\(datePsid)', ampm=\(ampm)")
            }
            sqlite3_finalize(selectStmt)
        } else {
            print("•DB• Select prepare error: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        // DELETE
        var stmt: OpaquePointer?
        let sql = "DELETE FROM dataweight_table WHERE dataweight_date_psid = ? AND dataweight_ampm_pnid = ?;"
        print("•DB• Deleting weight for datePsid=\(datePsid), ampm=\(ampm)")
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            _ = datePsid.withCString { cString in
                sqlite3_bind_text(stmt, 1, cString, -1, unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self))
            }
            sqlite3_bind_int(stmt, 2, Int32(ampm))
            if sqlite3_step(stmt) == SQLITE_DONE {
                let changes = sqlite3_changes(db)
                print("•DB• Rows deleted: \(changes)")
                sqlite3_finalize(stmt)
                return changes > 0
            } else {
                print("•DB• Step error: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("•DB• Prepare error: \(String(cString: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(stmt)
        return false
    }
    // MARK: - Count Operations
    
    func fetchCountRecords(forDate date: String) async -> [SqlDataCountRecord] { // Make async
        do {
            try await ensureInitialized()    // ← one line fixes everything
        } catch {
            print(":ERROR: fetchCountRecords: DB not available: \(error)")
            return []
        }
        guard !date.isEmpty, Date(datestampSid: date) != nil else {
            print(":ERROR: Invalid date for fetchCountRecords: \(date)")
            return []
        }
        
        var records: [SqlDataCountRecord] = []
        let query = """
        SELECT datacount_date_psid, datacount_kind_pfnid, datacount_count, datacount_streak
        FROM datacount_table WHERE datacount_date_psid = ?;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK,
              sqlite3_bind_text(stmt, 1, date.cString(using: .utf8), -1, SQLITE_TRANSIENT) == SQLITE_OK else {
            print(":ERROR: Prepare/bind failed for fetchCountRecords: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_finalize(stmt)
            return []
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let row: [Any?] = [
                sqlite3_column_text(stmt, 0).map { String(cString: $0) },
                Int(sqlite3_column_int(stmt, 1)),
                Int(sqlite3_column_int(stmt, 2)),
                Int(sqlite3_column_int(stmt, 3))
            ]
            if let record = SqlDataCountRecord(row: row) {
                records.append(record)
            } else {
                print(":ERROR: Invalid count record for date: \(date), row: \(row)")
            }
        }
        sqlite3_finalize(stmt)
        // print("🟢 •DB• Fetched \(records.count) count records for \(date)")
        return records
    }
    
    func saveCount(record: SqlDataCountRecord, oldDatePsid: String?, oldTypeNid: Int?) async -> Bool {
        do {
            try await ensureInitialized()    // ← one line fixes everything
        } catch {
            print(":ERROR: saveCount: DB not available: \(error)")
            return false
        }
        guard Date(datestampSid: record.datacount_date_psid) != nil,
              record.datacount_count >= 0,
              record.datacount_streak >= 0 else {
            print(":ERROR: Invalid count record: date=\(record.datacount_date_psid), type=\(record.datacount_kind_pfnid), count=\(record.datacount_count)")
            return false
        }
        
        sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil)
        
        if let oldDatePsid, let oldTypeNid, !oldDatePsid.isEmpty, Date(datestampSid: oldDatePsid) != nil {
            let deleteQuery = "DELETE FROM datacount_table WHERE datacount_date_psid = ? AND datacount_kind_pfnid = ?;"
            var stmt: OpaquePointer?
            guard sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) == SQLITE_OK,
                  sqlite3_bind_text(stmt, 1, oldDatePsid.cString(using: .utf8), -1, SQLITE_TRANSIENT) == SQLITE_OK,
                  sqlite3_bind_int(stmt, 2, Int32(oldTypeNid)) == SQLITE_OK,
                  sqlite3_step(stmt) == SQLITE_DONE else {
                print(":ERROR: Delete failed: \(String(cString: sqlite3_errmsg(db)))")
                sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
                sqlite3_finalize(stmt)
                return false
            }
            sqlite3_finalize(stmt)
        }
        
        let insertQuery = "INSERT INTO datacount_table (datacount_date_psid, datacount_kind_pfnid, datacount_count, datacount_streak) VALUES (?, ?, ?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK,
              sqlite3_bind_text(stmt, 1, record.datacount_date_psid.cString(using: .utf8), -1, SQLITE_TRANSIENT) == SQLITE_OK,
              sqlite3_bind_int(stmt, 2, Int32(record.datacount_kind_pfnid)) == SQLITE_OK,
              sqlite3_bind_int(stmt, 3, Int32(record.datacount_count)) == SQLITE_OK,
              sqlite3_bind_int(stmt, 4, Int32(record.datacount_streak)) == SQLITE_OK,
              sqlite3_step(stmt) == SQLITE_DONE else {
            print(":ERROR: Insert failed: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
            sqlite3_finalize(stmt)
            return false
        }
        sqlite3_finalize(stmt)
        
        sqlite3_exec(db, "COMMIT;", nil, nil, nil)
        // print("🟢 •DB• Saved count for \(record.datacount_date_psid), type=\(record.datacount_kind_pfnid)")
        return true
    }
    
    // MARK: - Date Navigation
    
    func fetchDistinctDates() async -> [String] {
        //Note: useful for reading thread info
        //let caller = Thread.callStackSymbols.prefix(10).joined(separator: "\n")
        //print("🚨 fetchDistinctDates() called from:\n\(caller)\n")
        do {
            try await ensureInitialized()
        } catch {
            print(":ERROR: 🔴 •DB• fetchDistinctDates: \(error)")
            return []
        }
        let query = """
        SELECT DISTINCT dataweight_date_psid FROM dataweight_table
        WHERE dataweight_date_psid GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
        UNION
        SELECT DISTINCT datacount_date_psid FROM datacount_table
        WHERE datacount_date_psid GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
        ORDER BY dataweight_date_psid DESC;
        """
        var dates: [String] = []
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            print(":ERROR: Prepare failed for fetchDistinctDates: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_finalize(stmt)
            return []
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let date = sqlite3_column_text(stmt, 0).map({ String(cString: $0) }),
               Date(datestampSid: date) != nil {
                dates.append(date)
            }
        }
        sqlite3_finalize(stmt)
        // print("🟢 •DB• Fetched \(dates.count) distinct dates: \(dates)")
        print("🟢 •DB• Fetched \(dates.count)")
        return dates
    }
    
    // MARK: - Utilities
    
    private func execute(query: String) -> Bool {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK,
              sqlite3_step(stmt) == SQLITE_DONE else {
            print("Execute failed: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_finalize(stmt)
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }
    
    func fetchDailyTracker(forDate date: Date) async -> SqlDailyTracker {
        let normalizedDate = date.startOfDay
        let datestampSid = date.datestampSid
        let weightRecords = await fetchWeightRecords(forDate: datestampSid)
        let countRecords = await fetchCountRecords(forDate: datestampSid)
        
        var itemsDict: [DataCountType: SqlDataCountRecord] = [:]
        for dataCountType in DataCountType.allCases {
            itemsDict[dataCountType] =  SqlDataCountRecord(date: normalizedDate, countType: dataCountType)
        }
        
        for record in countRecords {
            if let countType = DataCountType(nid: record.datacount_kind_pfnid) {
                itemsDict[countType] = record
            }
        }
        
        var weightAM: SqlDataWeightRecord?
        var weightPM: SqlDataWeightRecord?
        for record in weightRecords {
            if record.dataweight_ampm_pnid == 0 {
                weightAM = record
            } else if record.dataweight_ampm_pnid == 1 {
                weightPM = record
            }
        }
        
        let tracker = SqlDailyTracker(
            date: normalizedDate,
            itemsDict: itemsDict,
            weightAM: weightAM,
            weightPM: weightPM
        )
        // print("🟢 •DB• Fetched tracker for \(datestampSid): AM=\(tracker.weightAM?.dataweight_kg ?? 0) kg, PM=\(tracker.weightPM?.dataweight_kg ?? 0) kg, counts=\(tracker.itemsDict.count)")
        return tracker
    }
    
    func fetchTrackers() async -> [SqlDailyTracker] {
        let dates = await fetchDistinctDates()
        var tasks: [Task<SqlDailyTracker, Never>] = []
        for dateStr in dates {
            if let date = Date(datestampSid: dateStr) {
                tasks.append(Task {
                    await self.fetchDailyTracker(forDate: date)
                })
            }
        }
        var trackers: [SqlDailyTracker] = []
        for task in tasks {
            trackers.append(await task.value)
        }
        return trackers.sorted { $0.date > $1.date }
    }
    
    @MainActor
    func fetchTrackers(forMonth date: Date) async -> [SqlDailyTracker] {
        do {
            try await ensureInitialized()    // ← one line fixes everything
        } catch {
            print(":ERROR: 🔴 •DB• fetchTrackers(forMonth): \(error)")
            return []
        }
        
        //        guard isInitialized else {
        //            print(":ERROR: Database not initialized")
        //            return []
        //        }
        let calendar = Calendar(identifier: .gregorian)
        let monthStart = calendar.startOfMonth(for: date)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        let distinctDates = await fetchDistinctDates()
        let filteredDates = distinctDates
            .compactMap { Date(datestampSid: $0) }
            .filter { $0 >= monthStart && $0 < nextMonth }
            .map { $0.startOfDay }
        
        var trackers: [SqlDailyTracker] = []
        for date in filteredDates {
            let tracker = await fetchDailyTracker(forDate: date)
            if tracker.weightAM != nil || tracker.weightPM != nil || !tracker.itemsDict.isEmpty {
                trackers.append(tracker)
            }
        }
        
        print("🟢 •DB• Fetched \(trackers.count) trackers for month \(date.datestampSid): \(trackers.map { "\($0.date.datestampSid): AM=\($0.weightAM?.dataweight_kg ?? 0) kg, PM=\($0.weightPM?.dataweight_kg ?? 0) kg" })")
        return trackers.sorted(by: { $0.date < $1.date })
    }
    
    func dumpDatabase() async {
#if DEBUG
        do {
            try await ensureInitialized()    // ← one line fixes everything
        } catch {
            print(":ERROR: DB not available: \(error)")
        }
        // print("Dumping dataweight_table:")
        let weightQuery = "SELECT dataweight_date_psid, dataweight_ampm_pnid, dataweight_kg, dataweight_time FROM dataweight_table ORDER BY dataweight_date_psid, dataweight_ampm_pnid;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, weightQuery, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let date = sqlite3_column_text(stmt, 0).map { String(cString: $0) } ?? ""
                let ampm = Int(sqlite3_column_int(stmt, 1))
                let kg = sqlite3_column_double(stmt, 2)
                let time = sqlite3_column_text(stmt, 3).map { String(cString: $0) } ?? ""
                print("Weight: date=\(date), ampm=\(ampm), kg=\(kg), time=\(time)")
            }
            sqlite3_finalize(stmt)
        } else {
            print(":ERROR: Failed to dump dataweight_table: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        // print("Dumping datacount_table:")
        let countQuery = "SELECT datacount_date_psid, datacount_kind_pfnid, datacount_count, datacount_streak FROM datacount_table ORDER BY datacount_date_psid, datacount_kind_pfnid;"
        if sqlite3_prepare_v2(db, countQuery, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let date = sqlite3_column_text(stmt, 0).map { String(cString: $0) } ?? ""
                let typeNid = Int(sqlite3_column_int(stmt, 1))
                let count = Int(sqlite3_column_int(stmt, 2))
                let streak = Int(sqlite3_column_int(stmt, 3))
                print("Count: date=\(date), type=\(typeNid), count=\(count), streak=\(streak)")
            }
            sqlite3_finalize(stmt)
        } else {
            print(":ERROR: Failed to dump datacount_table: \(String(cString: sqlite3_errmsg(db)))")
        }
#endif
    }
    
    func close() async {
        guard let currentDb = db else { return }
        
        let result = sqlite3_close(currentDb)
        if result == SQLITE_OK {
            print("Database closed cleanly")
        } else {
            // Note: after a failed close, SQLite docs say you should call sqlite3_close again
            // but in practice this almost never happens unless you have unfinalized statements.
            print(":ERROR: sqlite3_close returned \(result), msg: \(String(cString: sqlite3_errmsg(currentDb)))")
        }
        
        db = nil
        isInitialized = false
    }
    
    //    deinit {
    //        if let db = db {
    //            sqlite3_close(db)
    //        }
    //    }
    
    // MARK: - Fetch All Trackers
    
    func fetchAllTrackers() async -> [SqlDailyTracker] {
        do {
            try await ensureInitialized()
        } catch {
            print(":ERROR: 🔴 •DB• fetchAllTrackers: Failed to setup database: \(error)")
            return []
        }
        let rows = await fetchRows(query: "SELECT datacount_date_psid, datacount_kind_pfnid, datacount_count, datacount_streak FROM datacount_table")
        var trackers: [String: [DataCountType: SqlDataCountRecord]] = [:]
        
        for row in rows {
            guard let record = SqlDataCountRecord(row: row),
                  Date(datestampSid: record.datacount_date_psid) != nil,
                  let countType = DataCountType(nid: record.datacount_kind_pfnid) else {
                print("fetchAllTrackers: Skipping invalid row: \(row)")
                continue
            }
            
            let dateKey = record.datacount_date_psid
            trackers[dateKey, default: [:]][countType] = record  //  use default
        }
        
        var tasks: [Task<SqlDailyTracker, Never>] = []
        for dateKey in trackers.keys {
            if let date = Date(datestampSid: dateKey) {
                tasks.append(Task {
                    await self.fetchDailyTracker(forDate: date)
                })
            }
        }
        
        var result: [SqlDailyTracker] = []
        for task in tasks {
            result.append(await task.value)
        }
        return result.sorted { $0.date < $1.date }
    }
    
    private func fetchRows(query: String) async -> [[Any?]] {
        do {
            try await ensureInitialized()    // ← one line fixes everything
        } catch {
            print(":ERROR: DB not available in fetchRows: \(error)")
            return []
        }
        
        var rows: [[Any?]] = []
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let row: [Any?] = [
                    sqlite3_column_text(stmt, 0).map { String(cString: $0) },
                    Int(sqlite3_column_int(stmt, 1)),
                    Int(sqlite3_column_int(stmt, 2)),
                    Int(sqlite3_column_int(stmt, 3))
                ]
                rows.append(row)
            }
        } else {
            print(":ERROR: Query failed: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(stmt)
        print("fetchRows: Fetched \(rows.count) rows for query: \(query)")
        return rows
    }
    
    func resetDatabaseCompletely() async throws {
        guard let dbURL = dbURL else { throw DatabaseError.invalidURL }
        
        // Close the connection properly
        await close()
        
        // Delete the files, handling errors
        do {
            try fm.removeItem(at: dbURL)
            print("🗑️ Deleted main DB file: \(dbURL.path)")
        } catch {
            print("❌ Failed to delete main DB: \(error.localizedDescription)")
            throw error // Propagate to caller for handling
        }
        
        let shmURL = dbURL.appendingPathExtension("shm")
        let walURL = dbURL.appendingPathExtension("wal")
        
        if fm.fileExists(atPath: shmURL.path) {
            do {
                try fm.removeItem(at: shmURL)
                print("🗑️ Deleted SHM file")
            } catch {
                print("❌ Failed to delete SHM: \(error.localizedDescription)")
            }
        }
        
        if fm.fileExists(atPath: walURL.path) {
            do {
                try fm.removeItem(at: walURL)
                print("🗑️ Deleted WAL file")
            } catch {
                print("❌ Failed to delete WAL: \(error.localizedDescription)")
            }
        }
        
        // Reset state
        isInitialized = false
        // preparedStatements.removeAll()
        
        // Re-setup
        try await setup()
    }
}
