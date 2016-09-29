//
//  SQLiteEngine+Master.swift
//  Amigo
//
//  Created by Adam Venturella on 7/22/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import FMDB

public struct SQLiteMasterRow : CustomStringConvertible{
    let type: String
    let name : String
    let tableName: String
    let rootpage: Int
    let sql: String

    public var description: String{
        return "\(self.dynamicType)(\(tableName))"
    }
}

extension SQLiteEngine{
    public func master() -> [SQLiteMasterRow]{

        return execute("SELECT * FROM sqlite_master ORDER BY name"){ (result:FMResultSet) -> [SQLiteMasterRow] in
            var rows = [SQLiteMasterRow]()

            while result.next(){
                let row = SQLiteMasterRow(
                    type: result.stringForColumn("type"),
                    name: result.stringForColumn("name"),
                    tableName: result.stringForColumn("tbl_name"),
                    rootpage: Int(result.intForColumn("rootpage")),
                    sql: result.stringForColumn("sql")
                )

                rows.append(row)
            }
            return rows
        }
    }

    public func masterTables() -> [SQLiteMasterRow]{

        return execute("SELECT * FROM sqlite_master WHERE type='table' ORDER BY name"){ (result:FMResultSet) -> [SQLiteMasterRow] in
            var rows = [SQLiteMasterRow]()

            while result.next(){
                let row = SQLiteMasterRow(
                    type: result.stringForColumn("type"),
                    name: result.stringForColumn("name"),
                    tableName: result.stringForColumn("tbl_name"),
                    rootpage: Int(result.intForColumn("rootpage")),
                    sql: result.stringForColumn("sql")
                )

                rows.append(row)
            }

            return rows
        }
    }

    public func masterTable(label: String) -> SQLiteMasterRow?{

        return execute("SELECT * FROM sqlite_master WHERE type='table' AND name=? ORDER BY name", params: [label]){ (result:FMResultSet) -> SQLiteMasterRow? in
            var rows = [SQLiteMasterRow]()

            while result.next(){
                let row = SQLiteMasterRow(
                    type: result.stringForColumn("type"),
                    name: result.stringForColumn("name"),
                    tableName: result.stringForColumn("tbl_name"),
                    rootpage: Int(result.intForColumn("rootpage")),
                    sql: result.stringForColumn("sql")
                )

                rows.append(row)
            }

            return rows.first
        }
    }
}