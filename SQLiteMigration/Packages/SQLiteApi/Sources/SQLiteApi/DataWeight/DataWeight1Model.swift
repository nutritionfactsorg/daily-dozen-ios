//
//  DataWeight1Model.swift
//  SQLiteApi/DataWeight
//

import Foundation
import SQLiteFramework

/// Handles Create Read Update Delete (CRUD) for one or more DataCount1Record.
public struct DataWeight1Model {
    
    public unowned let api: SQLiteApi
    public init(api: SQLiteApi) {
        self.api = api
    }
    
    /// INSERT one row record into database.
    public func create(_ r: DataWeight1Record) {
        var sqlItemA = "INSERT INTO dataweight_1_table("
        var sqlItemB = "VALUES ("
        
        sqlItemA.append(" dataweight_pid,")
        sqlItemB.append(" \(r.dataweight_pid),")

        sqlItemA.append(" dataweight_kg,")
        sqlItemB.append(" \(r.dataweight_kg),")

        sqlItemA.append(" dataweight_time,")
        sqlItemB.append(" \(r.dataweight_time),")
        
        sqlItemA.append(" ) ")
        sqlItemB.append(" );")

        let query = SQLiteQuery(sql: sqlItemA + sqlItemB, db: api.dailydozenDb)
        if query.getStatus().type != .noError {
            print("FAIL: DataWeight1Model create(_ item: DataWeight1Record))")
        }
    }
    
    
    // MARK: - Table
    
    public func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS "dataweight_1_table" (
            dataweight_pid  TEXT,
            dataweight_kg   REAL,
            dataweight_time TEST,
            PRIMARY KEY("dataweight_pid")
        );
        """
        
        print("• sql\n\(sql)")
        let query = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        print("query \(query.getStatus().toString())")
    }
    
}
