//
//  SQLiteEngine+Transactions.swift
//  Amigo
//
//  Created by Adam Venturella on 7/19/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import FMDB
import CoreData

extension SQLiteEngine{
    

//    public func add<T: AmigoModel>(obj: T, model: ORMModel){
//        let insert = model.table.insert()
//        let sql = compiler.compile(insert)
//        var automaticPrimaryKey = false
//
//        var values = [AnyObject]()
//
//        for each in model.table.sortedColumns{
//            if each.primaryKey && each.type == .Integer64AttributeType{
//                automaticPrimaryKey = true
//                continue
//            }
//
//            let value: AnyObject?
//
//
//            if let column = each.foreignKey{
//                print("++++ WHEN SAVING FOREIGN KEYS +++ -> SQLiteEngine+Transactions -> add()")
//                continue
//            } else {
//                value = obj.valueForKey(each.label)
//            }
//
//            values.append(value!)
//        }
//
//        db.inDatabase { (db) -> Void in
//            db.executeUpdate(sql, withArgumentsInArray: values)
//
//            if automaticPrimaryKey {
//                let result = db.executeQuery("SELECT last_insert_rowid();", withArgumentsInArray: nil)
//                result.next()
//                obj.setValue(result.objectForColumnIndex(0), forKey: model.primaryKey.label)
//                result.close()
//            }
//        }
//    }
//
//    public func delete<T: AmigoModel>(obj: T, model: ORMModel){
//        let id = model.primaryKey.label
//        let value = obj.valueForKey(id)
//        let delete = model.table.delete().filter("\(id) = \(value)")
//        //compiler.compile(<#T##expression: NSPredicate##NSPredicate#>, model: <#T##ORMModel#>, models: <#T##[String : ORMModel]#>)
//        //let sql = compiler.compile(delete)
////        var automaticPrimaryKey = false
////
////        var values = [AnyObject]()
////
////        for each in model.table.sortedColumns{
////            if each.primaryKey && each.type == .Integer64AttributeType{
////                automaticPrimaryKey = true
////                continue
////            }
////
////            let value: AnyObject?
////
////
////            if let column = each.foreignKey{
////                continue
////            } else {
////                value = obj.valueForKey(each.label)
////            }
////
////            values.append(value!)
////        }
////
////        db.inDatabase { (db) -> Void in
////            db.executeUpdate(sql, withArgumentsInArray: values)
////        }
//    }

}