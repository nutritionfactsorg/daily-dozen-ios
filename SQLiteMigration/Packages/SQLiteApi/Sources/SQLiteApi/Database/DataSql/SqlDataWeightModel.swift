//
//  SqlDataWeightModel.swift
//  SQLiteApi/DataSql
//

import Foundation
import SQLiteFramework

/// Handles Create Read Update Delete (CRUD) for one or more SqlDataCountRecord.
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
