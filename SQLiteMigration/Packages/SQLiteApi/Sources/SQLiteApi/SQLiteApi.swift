//
// SQLiteApi.swift
// SQLiteApi
//

import Foundation
import SQLiteFramework

/// NOTE: `deinit` can only be implemented in a class
public class SQLiteApi {
    // Phase 1 initialization
    public let dailydozenDb: SQLiteDatabase
    public var dataCount: DataCount1Model!
    
    public init(dbUrl: URL) {
        // Phase 1 initialization
        self.dailydozenDb = SQLiteDatabase(url: dbUrl)
        
        // Phase 2 
        // `api` is `unowned` in following instances.
        self.dataCount = DataCount1Model(api: self)
        
        // Phase 3
        let openedOk: Bool = dailydozenDb.open()
        if !openedOk {
            // :NYI: add error message to log
            print(":ERROR: database open error")
        }
        
        // 
        dataCount.createTable()
    }
    
    /// Close opened databases.
    deinit {
        let _ = dailydozenDb.close() // :NYI: handle return result
    }
}


