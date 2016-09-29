//
//  QuerySet.swift
//  Amigo
//
//  Created by Adam Venturella on 6/29/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public class QuerySet<T: AmigoModel>: AmigoConfigured{

    public let config: AmigoConfiguration
    public let model: ORMModel

    public var maybePredicate: NSPredicate?

    var _related = [String]()
    var _values = [String]()
    var _using : AmigoModel?
    var _relationship: String?
    var _limit: Int?
    var _offset: Int?
    var _orderBy = [OrderBy]()


    init(model: ORMModel, config: AmigoConfiguration){
        self.config = config
        self.model = model
    }

    public func selectRelated(values: String...) -> QuerySet<T>{
        _related = values
        return self
    }

    public func relationship(value: String) -> QuerySet<T>{
        _relationship = value
        return self
    }

    public func values(values: String...) -> QuerySet<T>{
        _values = values
        return self
    }

    public func limit(value:Int) -> QuerySet<T>{
        _limit = value
        return self
    }

    public func offset(value:Int) -> QuerySet<T>{
        _offset = value
        return self
    }

    public func orderBy(key: String, ascending: Bool = true) -> QuerySet<T>{
        let order = ascending ? Asc(key) : Desc(key) as OrderBy
        _orderBy.append(order)
        return self
    }

    public func filter(format: String) -> QuerySet<T>{
        maybePredicate = NSPredicate(format: format)
        return self
    }

    public func using<U: AmigoModel>(model: U) -> QuerySet<T>{
        _using = model

        return self
    }

    public func get(primaryKey: AnyObject) -> T?{
        self.filter("\(model.primaryKey.label) = \"\(primaryKey)\"")
        let results = self.all()
        return results.first
    }

    public func all() -> [T]{
        return engine.execute(self)
    }

    public func count() -> Int{
//        var error: NSError?
//        let request = fetchRequest
//        request.returnsObjectsAsFaults = true
//
//        let count = context.countForFetchRequest(fetchRequest, error: &error)
        return 0
    }

    public func compile() -> Select {
        // if we are doing a selectRelated, we need to set all
        // of the columns 1st
        var joins = [Join]()
        var columns : [Column]
        var select: Select
        let explicitColumns: Bool
        let fromTable: Table

        if _values.count == 0 {
            explicitColumns = false
            columns = model.columns
        } else {
            explicitColumns = true
            columns = getExplicitColumns()
        }

        for each in _related{
            if let fkColumn = model.foreignKeys[each]{
                let relatedTable = fkColumn.foreignKey!.relatedColumn.table!
                let join = model.table.join(relatedTable)
                let joinColumns = tableIndex[relatedTable.label]!.columns

                if explicitColumns == false {
                    columns = columns + joinColumns
                }

                joins.append(join)
            }
        }

        // for a many to many we change the table here to the
        // pivot table. and append two joins (select related)
        // to the selectFrom

        if let using = _using,
           let key = _relationship,
           let relatedModel = config.typeIndex[using.dynamicType.description()],
           let relationship = relatedModel.relationships[key] as? ManyToMany{
            /*
                SELECT w.label, m.workout_id, m.id, m.type, m.count, e.label
                FROM workout_exercise AS we
                LEFT JOIN meta AS m ON m.id = we.meta_id
                LEFT JOIN exercise AS e ON e.id = we.exercise_id
                LEFT JOIN workout AS w ON w.id = we.workout_id
                ORDER BY we.workout_id  
            */

            select = Select(columns)
                .selectFrom(relationship.associationTable)

            if let through = relationship.through{
                select.selectFrom(relationship.associationTable.join(through.table))
                fromTable = through.table

            } else {
                let joinTarget = relationship.left == model ?
                    relationship.associationTable.join(relationship.left.table) :
                    relationship.associationTable.join(relationship.right.table)

                select.selectFrom(joinTarget)
                fromTable = relationship.associationTable
            }

        } else {
            fromTable = model.table
            select = Select(columns).selectFrom(model.table)
        }


        if let (filter, params) = compileFilter(fromTable){
            select.filter(filter, params: params)
        }

        select.orderBy(_orderBy.map{ (value: OrderBy) -> OrderBy in
            let parts = value.keyPath.unicodeScalars.split{$0 == "."}.map(String.init)

            if parts.count == 1{
                let name = model.table.c[parts[0]]!.qualifiedLabel!
                return value.dynamicType.init(name)
            } else if parts.count == 2{
                let column = model.table.c[parts[0] + "_id"]!
                let table = column.foreignKey!.relatedColumn.table!
                let name = table.c[parts[1]]!.qualifiedLabel!

                return value.dynamicType.init(name)
            }

            return value.dynamicType.init(value.keyPath)
        })

        if let limit = _limit{
            select.limit(limit)
        }

        if let offset = _offset{
            select.offset(offset)
        }

        if joins.count > 0 {
            select.selectFrom(joins)
        }

        return select
    }

    func compileFilter(fromTable: Table) -> (String, [AnyObject])?{
        var predicate: NSPredicate? = maybePredicate


        if let using = _using, let key = _relationship, let relatedModel = config.typeIndex[using.dynamicType.description()]{
            // there is gonna be a problem here. If 2 libs use "author" the 
            // qualified names will be fine, but the dotted names
            // could have naming conflicts that can't be resolved 
            // without a fully qualified name.
            if let relationship = relatedModel.relationships[key] as? OneToMany {
                let id = using.valueForKey(relatedModel.primaryKey!.label)!
                let relatedTable = fromTable.model!.foreignKeys[relationship.column]!.foreignKey!.relatedTable

                let suffix = relatedTable.primaryKey!.label
                let p = "\(relationship.column)_\(suffix) = \"\(id)\""

                let relationshipPredicate = NSPredicate(format: p)

                if let filterPredicate = predicate{
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, relationshipPredicate])
                } else {
                    predicate = relationshipPredicate
                }
            }

            if let relationship = relatedModel.relationships[key] as? ManyToMany {
                let obj = relationship.left == relatedModel ? relationship.left : relationship.right
                let column = "\(obj.label)_\(obj.primaryKey!.label)"
                let id = using.valueForKey(obj.primaryKey!.label)!
                let p = "\(column) = \"\(id)\""

                let relationshipPredicate = NSPredicate(format: p)

                if let filterPredicate = predicate{
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, relationshipPredicate])
                } else {
                    predicate = relationshipPredicate
                }
            }
        }

        if let predicate = predicate{
            let (filter, params) = engine.compiler.compile(predicate, table: fromTable, models: config.tableIndex)
            return(filter, params)
        } else {
            return nil
        }

    }

    func getExplicitColumns() -> [Column]{

        let cols = _values.map{ value -> Column in
            let parts = value.unicodeScalars.split{ $0 == "."}.map(String.init)

            if parts.count == 1{
                return model.table.columns[parts[0]]!
            } else {
                // this is a FK Column. We append "_id" as the ORM hides
                // that idea from the user.
                let column = model.table.columns[parts[0] + "_id"]!
                let table = column.foreignKey!.relatedColumn.table!
                return table.columns[parts[1]]!
            }
        }

        return cols
    }
}