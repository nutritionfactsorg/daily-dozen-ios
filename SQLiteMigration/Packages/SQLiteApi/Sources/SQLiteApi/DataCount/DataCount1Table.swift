//
//  DataCount1Table.swift
//  
//

import Foundation
import SQLiteFramework

public struct DataCount1Table {
    
    public unowned let api: SQLiteApi
    public init(api: SQLiteApi) {
        self.api = api
    }
    
    public func create() {
        let sql = """
        CREATE TABLE IF NOT EXISTS "NFData1CountTbl" (
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
