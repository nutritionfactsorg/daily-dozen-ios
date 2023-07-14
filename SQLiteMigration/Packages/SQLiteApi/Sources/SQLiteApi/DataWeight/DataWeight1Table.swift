//
//  DataWeight1Table.swift
//  SQLiteApi/DataWeight
//

import Foundation
import SQLiteFramework

public struct DataWeight1Table {
    
    public unowned let api: SQLiteApi
    public init(api: SQLiteApi) {
        self.api = api
    }
    
    public func create() {
        let sql = """
        CREATE TABLE IF NOT EXISTS "NFData1WeightTbl" (
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
