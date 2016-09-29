//
//  SQLiteEngine+Schema.swift
//  Amigo
//
//  Created by Adam Venturella on 7/6/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import FMDB


extension SQLiteEngine{

    public func generateSchema(meta: MetaData) -> String{
        let tables = meta.sortedTables.map{
            compiler.compile(CreateTable($0))
        }

        return tables.joinWithSeparator("\n")
    }

    public func createAll(sql: String){
        
        db.inTransaction { (db, rollback) -> Void in

            if self.echo{
                self.echo(sql)
            }

            // needs to be executeStatements, 
            // AKA Multiple SQL Commands
            db.executeStatements(sql)
        }
    }
}