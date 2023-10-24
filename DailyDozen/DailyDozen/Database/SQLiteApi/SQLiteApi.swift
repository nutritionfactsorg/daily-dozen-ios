//
// SQLiteApi.swift
// SQLiteApi
//

import Foundation

/// NOTE: `deinit` can only be implemented in a class
public class SQLiteApi {
    // Phase 1 initialization
    public let dailydozenDb: SQLiteDatabase
    public var dataCount: SqlDataCountModel!
    public var dataWeight: SqlDataWeightModel!
    
    private var unsavedDailyTracker: SqlDailyTracker?
    
    public init(dbUrl: URL) {
        // Phase 1 initialization
        self.dailydozenDb = SQLiteDatabase(url: dbUrl)
        
        // Phase 2 
        // `api` is `unowned` in following instances.
        self.dataCount = SqlDataCountModel(api: self)
        self.dataWeight = SqlDataWeightModel(api: self)
        
        // Phase 3
        let openedOk: Bool = dailydozenDb.open()
        if !openedOk {
            // :NYI: add error message to log
            print(":ERROR: database open error")
        }
        
        // 
        dataCount.createTable()
        dataWeight.createTable()
    }
    
    /// Close opened databases.
    deinit {
        _ = dailydozenDb.close() // :NYI: handle return result
    }
    
    func getDailyTrackers(activity: ActivityProgress? = nil) -> [SqlDailyTracker] {
        // Daily Dozen & Tweaks Counters
        activity?.setProgress(ratio: 0.0, text: "0/3")

        // Weight History
        activity?.setProgress(ratio: 0.33, text: "1/3")
        
        return []
    }
    
    func saveDailyTracker() {
        guard let tracker = unsavedDailyTracker else {
            //logit.debug(
            //    "RealmProvider saveDailyTracker unsavedDailyTracker is nil"
            //)
            return
        }
        saveDailyTracker(tracker: tracker)
    }
    
    func saveDailyTracker(tracker: SqlDailyTracker) {
        //
    }
    
    // MARK: - Transaction Support
    
    public func transactionBegin() {
        let sql = "BEGIN TRANSACTION;"
        let query = SQLiteQuery(sql: sql, db: dailydozenDb)
        if query.getStatus().type != .noError {
            print("FAIL: SqlDataWeightModel create(_ item: SqlDataWeightRecord))")
        }
    }
    
    public func transactionCommit() {
        let sql = "COMMIT TRANSACTION;"
        let query = SQLiteQuery(sql: sql, db: dailydozenDb)
        if query.getStatus().type != .noError {
            print("FAIL: SqlDataWeightModel create(_ item: SqlDataWeightRecord))")
        }
    }
}
