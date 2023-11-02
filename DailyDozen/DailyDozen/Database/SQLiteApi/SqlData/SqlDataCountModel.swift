//
//  SqlDataCountModel.swift
//  SQLiteApi/DataSql
//

import Foundation

/// Handles Create Read Update Delete (CRUD) for one or more SqlDataCountRecord.
public struct SqlDataCountModel {
    
    public unowned let api: SQLiteApi
    public init(api: SQLiteApi) {
        self.api = api
    }
    
    /// INSERT one row record into database.
    public func create(_ r: SqlDataCountRecord) {
        var sqlItemA = "INSERT INTO datacount_table("
        var sqlItemB = "VALUES ("
        
        sqlItemA.append(" datacount_date_psid,")
        sqlItemB.append(" '\(r.datacount_date_psid)',")

        sqlItemA.append(" datacount_kind_pfnid,")
        sqlItemB.append(" \(r.datacount_kind_pfnid),")

        sqlItemA.append(" datacount_count,")
        sqlItemB.append(" \(r.datacount_count),")

        sqlItemA.append(" datacount_streak")
        sqlItemB.append(" \(r.datacount_streak)")
        
        sqlItemA.append(" ) ")
        sqlItemB.append(" );")

        let query = SQLiteQuery(sql: sqlItemA + sqlItemB, db: api.dailydozenDb)
        if query.getStatus().type != .noError {
            print("FAIL: ItemModel create(_ item: ItemRecord))")
        }
    }
    
    /// same as updateOrCreate()
    public func createOrUpdate(_ r: SqlDataCountRecord) {
        var sql = "SELECT count(*) FROM datacount_table "
        sql.append("WHERE datacount_date_psid='\(r.datacount_date_psid)' ")
        sql.append("AND datacount_kind_pfnid=\(r.datacount_kind_pfnid);")
        
        let query = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        
        if let result = query.getResult() {
            guard let count = result.getRowData(rowIdx: 0)[0] as? Int 
            else { return }
            if count > 0 {
                update(r)
            } else {
                create(r)
            }
        }
    }
    
    /// returns 1 record from database if present
    public func readOne(date: Date, countType: DataCountType) -> SqlDataCountRecord? {
        let dateSid = date.datestampSid
        let kindNid = countType.nid
        return readOne(date: dateSid, kind: kindNid)
    }
    
    /// returns 1 record from database if present
    public func readOne(date: String, kind: Int) -> SqlDataCountRecord? {
        var sql = "SELECT * FROM item_table WHERE "
        sql += "datacount_date_psid='\(date)' AND "
        sql += "datacount_kind_pfnid='\(kind)' ;"
        
        //TBD_Log.verbose(": ItemModel readOne() sql=\(sql)")
        
        let query: SQLiteQuery = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        if let result = query.getResult() {
            if result.data.count > 1 {
                print("ERROR: item_puid NOT UNIQUE")
                return nil
            }
            
            if let row = result.data.first {
                let record = SqlDataCountRecord(row: row, api: api)
                return record
            }
        }
        return nil
    }
    
    // see: http://sqlite.org/lang_update.html
    public func update(_ new: SqlDataCountRecord) {
        guard let old = readOne(date: new.datacount_date_psid, kind: new.datacount_kind_pfnid)
            else { return }
        
        if let sql = updateSql(new: new, old: old) {
            let _: SQLiteQuery = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        }
    }
    
    fileprivate func updateSql(new: SqlDataCountRecord, old: SqlDataCountRecord) -> String? {
        let r = new

        var sql = "UPDATE datacount_table "
        sql.append("SET datacount_count='\(r.datacount_count)', ")
        sql.append("datacount_streak='\(r.datacount_streak)' ")
        sql.append("WHERE datacount_date_psid='\(r.datacount_date_psid)' ")
        sql.append("AND datacount_kind_pfnid='\(r.datacount_kind_pfnid)' ")
        
        return sql
    }
    
    /// same as createOrUpdate
    public func updateOrCreate(_ r: SqlDataCountRecord) {
        createOrUpdate(r)
    }
    
    public func delete(_ r: SqlDataCountRecord) {
        var sql = "DELETE FROM datacount_table "
        sql.append("WHERE datacount_date_psid='\(r.datacount_date_psid)' ")
        sql.append("AND datacount_kind_pfnid=\(r.datacount_kind_pfnid);")
        
        let query = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        
        #if DEBUG
        if let result = query.getResult() {
            let s = """
            \(result.columnNames.count)
            \(result.toStringTsv())
            """
            logit.verbose(s)
        } else { 
            logit.verbose("DELETE: move along, nothing to see here.")
        }
        #endif
    }
    
    // MARK: - Table
    
    public func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS "datacount_table" (
            datacount_date_psid  TEXT,
            datacount_kind_pfnid INTEGER,
            datacount_count      INTEGER,
            datacount_streak     INTEGER,
            PRIMARY KEY("datacount_date_psid", "datacount_kind_pfnid")
        );
        """
        
        logit.verbose("• sql\n\(sql)")
        let query = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        logit.verbose("query \(query.getStatus().toString())")
    }
    
}
