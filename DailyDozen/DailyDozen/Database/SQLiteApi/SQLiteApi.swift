//
// SQLiteApi.swift
// SQLiteApi
//

import Foundation

public enum SQLiteApiError: Error {
    case databaseOpenFailed(String)
    case rowConversionFailed(String)
}

/// NOTE: `deinit` can only be implemented in a class
public class SQLiteApi {
    // Init Phase 1
    public let dailydozenDb: SQLiteDatabase
    // Init Phase 2 
    public var dataCount: SqlDataCountModel!
    public var dataWeight: SqlDataWeightModel!
    
    private var unsavedDailyTracker: SqlDailyTracker?
    
    public init(dbUrl: URL) {
        // Init Phase 1
        self.dailydozenDb = SQLiteDatabase(url: dbUrl)
        
        // Init Phase 2
        // `api` is `unowned` in following instances.
        self.dataCount = SqlDataCountModel(api: self)
        self.dataWeight = SqlDataWeightModel(api: self)
        
        // Init Phase 3
        let openedOk: Bool = dailydozenDb.open()
        if !openedOk {
            let s = ":ERROR: SQLite database open failed \(dbUrl.path)"
            logit.error(s)
            // :???: throw SQLiteApiError.databaseOpenFailed(s)
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
    
    // MARK: - Progress Streak Indicator Management
    
    // Note: The progress streak is a derived value. 
    // The progress streak indicates the number of consecutive days completed
    // for a specific topic.
    
    private func updateStreak(count: Int, date: Date, countType: DataCountType) {
        let itemCompleted = countType.goalServings == count
        if itemCompleted {
            updateStreakCompleted(date: date, countType: countType)
        } else {
            updateStreakIncomplete(date: date, countType: countType)
        }
    }
    
    private func updateStreakCompleted(date: Date, countType: DataCountType) {
        // setup this date
        guard var thisRec = dataCount.readOne(date: date, countType: countType)
        else {
            logit.error("Invalid updateStreakCompleted: \(date.datestampSid) (\(countType.nid)) not retrieved")
            return
        }
        
        // set this day's streak based on previous date
        var prevDay = date.adding(days: -1)
        if let yesterday = dataCount.readOne(date: prevDay, countType: countType) {
            thisRec.datacount_streak = yesterday.datacount_streak + 1
            dataCount.update(thisRec)
        } else {
            thisRec.datacount_streak = 1
            dataCount.update(thisRec)
        }
        
        // check & update next (future) date streak values
        var nextMaxValidStreak = thisRec.datacount_streak + 1
        var nextDay = date.adding(days: 1)
        while var nextRec = dataCount.readOne(date: nextDay, countType: countType) {
            if nextRec.count < countType.goalServings {
                if nextRec.datacount_streak == 0 {
                    // Done. Next day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    logit.error("\(nextRec.idString) count:\(nextRec.count) < goalServings:\(countType.goalServings) with streak:\(nextRec.datacount_streak)")
                    nextRec.datacount_streak = 0
                    dataCount.update(nextRec)
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if nextRec.count == countType.goalServings {
                if nextRec.datacount_streak != nextMaxValidStreak {
                    nextRec.datacount_streak = nextMaxValidStreak // Update
                    dataCount.update(nextRec)
                } else {
                    break // Done.                        
                }
                nextMaxValidStreak += 1
            } else if nextRec.count > countType.goalServings {
                logit.error("\(nextRec.idString) count:\(nextRec.count) > goalServings:\(countType.goalServings)")
                nextRec.datacount_count = countType.goalServings
                nextRec.datacount_streak = nextMaxValidStreak
                dataCount.update(nextRec)
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            nextDay = nextDay.adding(days: 1)
        }
        
        // count to verify this day's streak value.
        prevDay = date.adding(days: -1) // reset
        var streakCount = 1
        while let prevRec = dataCount.readOne(date: prevDay, countType: countType) {
            if prevRec.count == countType.goalServings {
                streakCount += 1                
            } else {
                break
            }
            prevDay = prevDay.adding(days: -1)
        }
        
        if streakCount == thisRec.datacount_streak {
            return // Done. Expected outcome.
        } 
        
        // check & update previous (past) date streak values
        prevDay = date.adding(days: -1) // reset
        var prevMaxValidStreak = thisRec.datacount_streak - 1
        while var prevRec = dataCount.readOne(date: prevDay, countType: countType) {
            if prevRec.count < countType.goalServings {
                if prevRec.datacount_streak == 0 {
                    // Done. Previous day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    logit.error("\(prevRec.idString) count:\(prevRec.count) < goalServings:\(countType.goalServings) with streak:\(prevRec.datacount_streak)")
                    prevRec.datacount_streak = 0
                    dataCount.update(prevRec)
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if prevRec.count == countType.goalServings {
                if prevRec.datacount_streak != prevMaxValidStreak {
                    prevRec.datacount_streak = prevMaxValidStreak
                    dataCount.update(prevRec)
                } else {
                    break // Done.                        
                }
                prevMaxValidStreak -= 1
            } else if prevRec.count > countType.goalServings {
                logit.error("\(prevRec.idString) count:\(prevRec.count) > goalServings:\(countType.goalServings)")
                prevRec.datacount_count = countType.goalServings
                prevRec.datacount_streak = prevMaxValidStreak
                dataCount.update(prevRec)
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            prevDay = prevDay.adding(days: -1)
        }        
    }
    
    private func updateStreakIncomplete(date: Date, countType: DataCountType) {
        guard var thisRec = dataCount.readOne(date: date, countType: countType)
        else {
            logit.error("Invalid updateStreakIncomplete: \(date.datestampSid) (\(countType.nid)) not retrieved")
            return
        }
        // this day's streak is 0
        if thisRec.datacount_streak != 0 {
            thisRec.datacount_streak = 0
            dataCount.update(thisRec)
        }
        
        // check & update next (future) date streak values
        var nextMaxValidStreak = 1
        var nextDay = date.adding(days: 1)
        while var nextRec = dataCount.readOne(date: nextDay, countType: countType) {
            if nextRec.count < countType.goalServings {
                if nextRec.datacount_streak == 0 {
                    // Done. Next day streak not impacted by adjacent past streak update.
                    break   
                } else {                    
                    logit.error("\(nextRec.idString) count:\(nextRec.count) < goalServings:\(countType.goalServings) with streak:\(nextRec.datacount_streak)")
                    if nextRec.datacount_streak != 0 {
                        nextRec.datacount_streak = 0
                        dataCount.update(nextRec)
                    }
                    // Note: checking additional dates stops here. Investigate the error.
                    break
                }
            } else if nextRec.count == countType.goalServings {
                if nextRec.datacount_streak != nextMaxValidStreak {
                    nextRec.datacount_streak = nextMaxValidStreak // update
                    dataCount.update(nextRec)
                } else {
                    break // Done.
                }
                nextMaxValidStreak += 1
            } else if nextRec.count > countType.goalServings {
                logit.error("\(nextRec.idString) count:\(nextRec.count) > goalServings:\(countType.goalServings)")
                nextRec.datacount_count = countType.goalServings
                nextRec.datacount_streak = nextMaxValidStreak
                dataCount.update(nextRec)
                // Note: checking additional dates stops here. Investigate the error.
                break
            }
            
            nextDay = nextDay.adding(days: 1)
        }
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
