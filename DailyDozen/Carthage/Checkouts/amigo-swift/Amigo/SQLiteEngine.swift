//
//  SQLiteEngine.swift
//  Amigo
//
//  Created by Adam Venturella on 7/2/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import FMDB



public class SQLiteEngine: NSObject, Engine{
    public let fetchLastRowIdAfterInsert = true
    public let _compiler = SQLiteCompiler()
    public var db: FMDatabaseQueue
    public let path: String?

    let echo: Bool
    var savepoints = [String]()

    public var compiler: Compiler{
        return _compiler
    }

    public init(_ path: String?, echo: Bool = false){
        self.path = path
        self.echo = echo

        if path == ":memory:" || path == nil {
            db = FMDatabaseQueue(path: nil)
        } else{
            db = FMDatabaseQueue(path: path)
        }
    }

    public func createBatchOperation(session: AmigoSession) -> AmigoBatchOperation{
        return SQLiteBatchOperation(session: session)
    }


    public func beginTransaction(){
        var inTransaction: Bool = false
        db.inDatabase{ inTransaction = $0.inTransaction() }

        if inTransaction {
            let savepoint = "amigo.sqllite.\(savepoints.count)"
            savepoints.append(savepoint)

            if self.echo{
                self.echo("SAVEPOINT", params: [savepoint])
            }

            db.inDatabase{
                do{
                    try $0.startSavePointWithName(savepoint)
                } catch _ {
                    debugPrint("failed to start savepoint: \(savepoint)")
                }
            }
        } else {
            if self.echo{
                self.echo("BEGIN TRANSACTION", params: nil)
            }

            db.inDatabase{$0.beginTransaction()}
        }
    }

    public func commitTransaction(){

        if savepoints.count > 0{
            let savepoint = savepoints.removeLast()
            db.inDatabase{
                do {
                    try $0.releaseSavePointWithName(savepoint)
                } catch _ {
                    debugPrint("unable to release savepoint: \(savepoint)")
                }
            }

        } else {

            if self.echo{
                self.echo("COMMIT TRANSACTION", params: nil)
            }
            db.inDatabase{$0.commit()}
        }
    }

    public func rollback(){
        if savepoints.count > 0{
            let savepoint = savepoints.removeLast()

            if self.echo{
                self.echo("ROLLBACK TO SAVEPOINT", params: [savepoint])
            }

            db.inDatabase{
                do {
                    try $0.rollbackToSavePointWithName(savepoint)
                } catch _ {
                    debugPrint("unable to rollback to savepoint: \(savepoint)")
                }

            }
        } else {

            if self.echo{
                self.echo("ROLLBACK TRANSACTION", params: nil)
            }
            db.inDatabase{$0.rollback()}
        }
    }

    public func lastrowid() -> Int{
        
        let result = execute("SELECT last_insert_rowid();"){ (results: FMResultSet) -> Int in
            results.next()

            let index = Int(results.intForColumnIndex(0))
            results.close()
            return index
        }

        return result
    }

    func echo(sql: String, params:[AnyObject]! = nil){
        print("------------------")
        print("[PARAMS] \(params)")
        print("[SQL] \(sql)")
        print("------------------")
    }

    public func execute<Input, Output>(sql: String, params: [AnyObject]! = nil, mapper: Input -> Output) -> Output{
        var output: Output?

        db.inDatabase{ db in

            if self.echo{
                self.echo(sql, params: params)
            }

            let input = db.executeQuery(sql, withArgumentsInArray: params) as! Input
            output = mapper(input)
        }
        
        return output!
    }


    public func execute(sql: String){
        db.inDatabase{ db in

            if self.echo{
                self.echo(sql)
            }

            db.executeStatements(sql)
        }
    }

    public func execute(sql: String, params: [AnyObject]! = nil){

        db.inDatabase{ db in

            if self.echo{
                self.echo(sql, params: params)
            }

            db.executeUpdate(sql, withArgumentsInArray: params)
        }

    }

}
