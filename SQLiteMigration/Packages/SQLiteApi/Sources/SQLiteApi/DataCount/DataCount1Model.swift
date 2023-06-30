//
//  DataCount1Model.swift
//  SQLiteApi
//

import Foundation
import SQLiteFramework

/// Handles Create Read Update Delete (CRUD) for one or more DataCount1Record.
public struct DataCount1Model {
    
    public unowned let api: SQLiteApi
    public init(api: SQLiteApi) {
        self.api = api
    }
    
    /// INSERT one row record into database.
    public func create(_ r: DataCount1Record) {
        var sqlItemA = "INSERT INTO data_count_1_table("
        var sqlItemB = "VALUES ("
        
        sqlItemA.append(" datacount_date_psid,")
        sqlItemB.append(" \(r.datacount_date_psid),")

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
    
    
    // MARK: - Table
    
    public func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS "data_count_1_table" (
            datacount_date_psid  TEXT,
            datacount_kind_pfnid INTEGER,
            datacount_count      INTEGER,
            datacount_streak     INTEGER,
            PRIMARY KEY("datacount_date_psid", "datacount_kind_pfnid")
        );
        """
        
        print("• sql\n\(sql)")
        let query = SQLiteQuery(sql: sql, db: api.dailydozenDb)
        print("query \(query.getStatus().toString())")
    }
    
}
