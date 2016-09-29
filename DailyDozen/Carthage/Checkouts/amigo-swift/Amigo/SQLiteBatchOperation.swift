//
//  SQLiteBatchOperation.swift
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation


public class SQLiteBatchOperation: AmigoBatchOperation{

    let session: AmigoSession
    var insertCache = [String: [String]]()
    var upsertCache = [String: [String]]()
    var updateCache = [String: [String]]()
    var deleteCache = [String: [String]]()
    var deleteThroughCache = [String: [String]]()
    var insertThroughCache = [String: [String]]()
    var upsertThroughCache = [String: [String]]()

    var statements = ""

    public required init(session: AmigoSession){
        self.session = session
    }

    public func add<T: AmigoModel>(obj: T) {
       add(obj, upsert: false)
    }

    public func add<T: AmigoModel>(obj: [T]) {
        obj.forEach{
            add($0, upsert: false)
        }
    }

    public func add<T: AmigoModel>(obj: [T], upsert isUpsert: Bool = false) {
        obj.forEach{
            add($0, upsert: isUpsert)
        }
    }

    public func add<T: AmigoModel>(obj: T, upsert isUpsert: Bool = false) {
        let action = session.addAction(obj)
        let model = obj.amigoModel

        if action == .Insert || isUpsert {
            if let relationship = model.throughModelRelationship{
                addThroughModel(obj, relationship: relationship, upsert: isUpsert)
            } else {
                statements = statements + buildInsert(obj, upsert: isUpsert) + "\n"
            }
        } else {

            // deny an update for a model without a primary key
            guard let _ = obj.amigoModel.primaryKey.modelValue(obj) else {
                return
            }

            statements = statements + buildUpdate(obj) + "\n"
        }
    }

    public func addThroughModel<T: AmigoModel>(obj: T, relationship: ManyToMany, upsert isUpsert: Bool = false){
        let model = obj.amigoModel
        let left = relationship.left
        let right = relationship.right

        var leftKey: String!
        var rightKey: String!

        model.foreignKeys.forEach{ (key: String, c: Column) -> Void in
            guard let fk = c.foreignKey else {
                return
            }

            if fk.relatedColumn == left.primaryKey{
                leftKey = key
            }

            if fk.relatedColumn == right.primaryKey{
                rightKey = key
            }
        }

        // this will save the 2 foreign keys as well.
        // if we have to do this then the associationTable
        // will get it's inserts as well. This effectively
        // defeats the batching, but such is life, we don't have
        // enough info to proceed so we have to do it.
        // 
        // Batching with ThoughModels is only effective if 
        // you have all the keys. For example if you are
        // syncing with a remote server and that server is
        // providing you all of the primary keys for the 
        // models involved.
        if model.primaryKey.modelValue(obj) == nil{
            session.add(obj, upsert: isUpsert)
            return
        }

        if obj.valueForKeyPath("\(leftKey).\(left.primaryKey!.label)") == nil{
            if let leftModel = obj.valueForKeyPath("\(leftKey)") as? AmigoModel {
                session.add(leftModel, upsert: isUpsert)
            }
        }

        if obj.valueForKeyPath("\(rightKey).\(right.primaryKey!.label)") == nil{
            if let rightModel = obj.valueForKeyPath("\(rightKey)") as? AmigoModel {
                session.add(rightModel, upsert: isUpsert)
            }
        }

        // if we don't have these parms, we don't proceed
        guard let leftParam = left.primaryKey!.serialize(obj.valueForKeyPath("\(leftKey).\(left.primaryKey!.label)")),
              let rightParam = right.primaryKey!.serialize(obj.valueForKeyPath("\(rightKey).\(right.primaryKey!.label)")),
              let throughParam = model.primaryKey!.serialize(model.primaryKey.modelValue(obj)) else {
            return
        }

        // insert the ThroughModel
        statements = statements + buildInsert(obj, upsert: isUpsert) + "\n"

        let params = [leftParam, rightParam, throughParam]
        let sql = buildInsertThough(obj, relationship: relationship, params: params, upsert: false)

        // insert the data into the proper association table
        statements = statements + sql + "\n"
    }

    public func delete<T: AmigoModel>(obj: [T]){
        obj.forEach(delete)
    }

    public func delete<T: AmigoModel>(obj: T){
        // deny an delete for a model without a primary key
        guard let _ = obj.amigoModel.primaryKey.modelValue(obj) else {
            return
        }

        statements = statements + buildDelete(obj) + "\n"

        deleteThroughModelRelationship(obj)
    }

    public func deleteThroughModelRelationship<T: AmigoModel>(obj: T){
        let model = obj.amigoModel

        guard let relationship = model.throughModelRelationship,
              let value = model.primaryKey.modelValue(obj) else {
            return
        }

        statements = statements + buildDeleteThroughModel(obj, relationship: relationship, value: value) + "\n"
    }

    public func execute(){
        session.engine.execute(statements)
    }

    func buildUpdate<T: AmigoModel>(obj: T) -> String {
        let model = obj.amigoModel
        let fragments: [String]
        let sqlParams = session.insertParams(obj)
        let params = sqlParams.queryParams + [model.primaryKey.modelValue(obj)!]


        if let parts = updateCache[obj.qualifiedName] {
            fragments = parts
        } else {
            let (sql, _) = session.updateSQL(obj)
            let parts = sql.componentsSeparatedByString("?")

            updateCache[obj.qualifiedName] = parts
            fragments = parts
        }

        let sql = buildSQL(fragments, params: params)
        return sql

    }

    func buildInsert<T: AmigoModel>(value: T, upsert isUpsert: Bool = false) -> String {
        let fragments: [String]
        let values = session.insertParams(value, upsert: isUpsert)
        var cache = isUpsert ? upsertCache : insertCache

        if let parts = cache[value.qualifiedName] {
            fragments = parts
        } else {
            let model = value.amigoModel
            let sql = isUpsert ? session.upsertSQL(model) : session.insertSQL(model)
            let parts = sql.componentsSeparatedByString("?")

            cache[value.qualifiedName] = parts

            if isUpsert{
                upsertCache = cache
            } else {
                insertCache = cache
            }

            fragments = parts
        }

        let sql = buildSQL(fragments, params: values.queryParams)
        return sql
    }

    func buildInsertThough<T: AmigoModel>(obj: T, relationship: ManyToMany, params: [AnyObject], upsert isUpsert: Bool = false) -> String {
        let fragments: [String]
        var cache = isUpsert ? upsertThroughCache : insertThroughCache

        if let parts = cache[obj.qualifiedName] {
            fragments = parts
        } else {
            let sql: String = session.insertThroughModelSQL(obj, relationship: relationship, upsert: isUpsert)
            let parts = sql.componentsSeparatedByString("?")

            cache[obj.qualifiedName] = parts

            if isUpsert{
                upsertThroughCache = cache
            } else {
                insertThroughCache = cache
            }

            fragments = parts
        }

        let sql = buildSQL(fragments, params: params)
        return sql
    }

    func buildDelete<T: AmigoModel>(obj: T) -> String {
        let model = obj.amigoModel
        let fragments: [String]
        let params = [model.primaryKey.serialize(model.primaryKey.modelValue(obj))!]

        if let parts = deleteCache[obj.qualifiedName] {
            fragments = parts
        } else {
            let (sql, _) = session.deleteSQL(obj)
            let parts = sql.componentsSeparatedByString("?")

            deleteCache[obj.qualifiedName] = parts
            fragments = parts
        }

        let sql = buildSQL(fragments, params: params)
        return sql
    }

    func buildDeleteThroughModel<T: AmigoModel>(obj: T, relationship: ManyToMany, value: AnyObject) -> String{
        let model = obj.amigoModel
        let fragments: [String]
        let params = [model.primaryKey!.serialize(model.primaryKey.modelValue(obj))!]

        if let parts = deleteThroughCache[obj.qualifiedName] {
            fragments = parts
        } else {
            let (sql, _) = session.deleteThroughModelSQL(obj, relationship: relationship, value: value)
            let parts = sql.componentsSeparatedByString("?")

            deleteThroughCache[obj.qualifiedName] = parts
            fragments = parts
        }

        let sql = buildSQL(fragments, params: params)
        return sql
    }

    func buildSQL(queryFragments: [String], params: [AnyObject]) -> String{
        var sql = ""
        let escaped = params.map(escape)

        escaped.enumerate().forEach{ index, part in
            sql = sql + queryFragments[index] + part
        }

        sql = sql + queryFragments.last!
        return sql
    }

    func escape(value: AnyObject) -> String{

        if let string = value as? String {
            return SQLiteFormat.escapeWithQuotes(string)
        }

        if let _ = value as? NSNull{
            let result = SQLiteFormat.escapeWithQuotes(nil)
            return result
        }

        if let data = value as? NSData {
            return SQLiteFormat.escapeBlob(data)
        }

        return SQLiteFormat.escapeWithoutQuotes(String(value))
    }
    
    
}