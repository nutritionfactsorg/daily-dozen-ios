//
//  SqlDataWeightModel.swift
//  SQLiteApi/DataSql
//

import Foundation

/// Handles Create Read Update Delete (CRUD) for one or more SqlDataWeightRecord.
public struct SqlDataWeightModel {
    
    public unowned let api: SQLiteApi
    public init(api: SQLiteApi) {
        self.api = api
    }
    
    /// INSERT one row record into database.
    public func create(_ r: SqlDataWeightRecord) {
        var sqlItemA = "INSERT INTO dataweight_table("
        var sqlItemB = "VALUES ("
        
        sqlItemA.append(" dataweight_date_psid,")
        sqlItemB.append(" '\(r.dataweight_date_psid)',")

        sqlItemA.append(" dataweight_ampm_pnid,")
        sqlItemB.append(" \(r.dataweight_ampm_pnid),")

        sqlItemA.append(" dataweight_kg,")
        sqlItemB.append(" \(r.dataweight_kg),")

        sqlItemA.append(" dataweight_time")
        sqlItemB.append(" '\(r.dataweight_time)'")
        
        sqlItemA.append(" ) ")
        sqlItemB.append(" );")

        let query = SQLiteQuery(sql: sqlItemA + sqlItemB, db: api.dailydozenDb)
        if query.getStatus().type != .noError {
            print("FAIL: SqlDataWeightModel create(_ item: SqlDataWeightRecord))")
        }
    }
    
    /// same as updateOrCreate()
    public func createOrUpdate(_ r: SqlDataWeightRecord) {
        var sql = "SELECT count(*) FROM dataweight_table "
        sql.append("WHERE dataweight_date_psid='\(r.dataweight_date_psid)' ")
        sql.append("AND dataweight_ampm_pnid=\(r.dataweight_ampm_pnid);")
        
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
    public func readOne(date: String, kind: Int) -> SqlDataWeightRecord? {
        var sql = "SELECT * FROM item_table WHERE "
        sql += "dataweight_date_psid='\(date)' AND "
        sql += "dataweight_kind_pfnid='\(kind)' ;"
        
        //TBD_Log.verbose(": ItemModel readOne() sql=\(sql)")
        
        let query: SQLiteQuery = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        if let result = query.getResult() {
            if result.data.count > 1 {
                print("ERROR: item_puid NOT UNIQUE")
                return nil
            }
            
            if let row = result.data.first {
                let record = SqlDataWeightRecord(row: row, api: api)
                return record
            }
        }
        return nil
    }
    
    // see: http://sqlite.org/lang_update.html
    public func update(_ new: SqlDataWeightRecord) {
        guard let old = readOne(date: new.dataweight_date_psid, kind: new.dataweight_ampm_pnid)
            else { return }
        
        if let sql = updateSql(new: new, old: old) {
            let _: SQLiteQuery = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        }
    }
    
    fileprivate func updateSql(new: SqlDataWeightRecord, old: SqlDataWeightRecord) -> String? {
        let r = new

        var sql = "UPDATE dataweight_table "
        sql.append("SET dataweight_kg='\(r.dataweight_kg)', ")
        sql.append("dataweight_time='\(r.dataweight_time)' ")
        sql.append("WHERE dataweight_date_psid='\(r.dataweight_date_psid)' ")
        sql.append("AND dataweight_ampm_pnid='\(r.dataweight_ampm_pnid)' ")
        
        return sql
    }
    
    /// same as createOrUpdate
    public func updateOrCreate(_ r: SqlDataWeightRecord) {
        createOrUpdate(r)
    }
    
    public func delete(_ r: SqlDataWeightRecord) {
        var sql = "DELETE FROM dataweight_table "
        sql.append("WHERE dataweight_date_psid='\(r.dataweight_date_psid)' ")
        sql.append("AND dataweight_ampm_pnid=\(r.dataweight_ampm_pnid);")
        
        let query = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        
        #if DEBUG
        if let result = query.getResult() {
            let s = """
            \(result.columnNames.count)
            \(result.toStringTsv())
            """
            logit.debug(s)
        } else {
            logit.debug("DELETE: move along, nothing to see here.")
        }
        #endif
    }
    
    // MARK: - Table
    
    public func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS "dataweight_table" (
            dataweight_date_psid TEXT,
            dataweight_ampm_pnid INTEGER,
            dataweight_kg        REAL,
            dataweight_time      TEXT,
            PRIMARY KEY("dataweight_date_psid", "dataweight_ampm_pnid")
        );
        """
        
        print("• sql\n\(sql)")
        let query = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        print("query \(query.getStatus().toString())")
    }
    
}
