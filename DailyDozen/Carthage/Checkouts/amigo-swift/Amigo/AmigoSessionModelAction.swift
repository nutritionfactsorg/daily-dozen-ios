//
//  AmigoSessionModelAction.swift
//  Amigo
//
//  Created by Adam Venturella on 1/16/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation


/// Used in Many-To-Many queries
public class AmigoSessionModelAction<T: AmigoModel>{
    let using: T
    let usingModel: ORMModel
    let session: AmigoSession
    var _relationship: String?

    public init(_ obj: T, model: ORMModel, session: AmigoSession){
        self.using = obj
        self.usingModel = model
        self.session = session
    }

    public func relationship(value: String) -> AmigoSessionModelAction<T>{
        self._relationship = value
        return self
    }

    public func delete<U: AmigoModel>(other: U){

        if let key = _relationship{

            if let relationship = usingModel.relationships[key] as? ManyToMany{

                if let throughModel = relationship.throughModel{
                    fatalError("Relationship is managed though: \(throughModel)")
                }

                let leftModel = session.config.tableIndex[relationship.tables[0]]!
                let rightModel = session.config.tableIndex[relationship.tables[1]]!
                let left: AmigoModel
                let right: AmigoModel

                if leftModel == usingModel{
                    left = using
                    right = other
                } else {
                    left = other
                    right = using
                }

                let leftId = leftModel.primaryKey!.label
                let leftColumn = "\(leftModel.label)_\(leftId)"
                let leftParam = left.valueForKey(leftId)!

                let rightId = rightModel.primaryKey!.label
                let rightColumn = "\(rightModel.label)_\(rightId)"
                let rightParam = right.valueForKey(rightId)!

                var delete = relationship.associationTable.delete()

                let predicate = NSPredicate(format:" \(leftColumn) = \"\(leftParam)\" AND \(rightColumn) = \"\(rightParam)\"")

                let (filter, params) = session.engine.compiler.compile(predicate,
                    table: relationship.associationTable,
                    models: session.config.typeIndex)

                delete.filter(filter)

                let sql = session.engine.compiler.compile(delete)
                session.engine.execute(sql, params: params)
            }
        }
    }

    public func add<U: AmigoModel>(other: U...){
        add(other)
    }

    public func add<U: AmigoModel>(other: [U]){
        other.forEach(addModel)
    }

    public func addModel<U: AmigoModel>(other: U){

        if let key = _relationship{

            if let relationship = usingModel.relationships[key] as? ManyToMany{

                if let throughModel = relationship.throughModel{
                    fatalError("Relationship is managed though: \(throughModel)")
                }

                let leftModel = session.config.tableIndex[relationship.tables[0]]!
                let rightModel = session.config.tableIndex[relationship.tables[1]]!
                let left: AmigoModel
                let right: AmigoModel

                if leftModel == usingModel{
                    left = using
                    right = other
                } else {
                    left = other
                    right = using
                }

                let leftId = leftModel.primaryKey!.label
                let leftParam = left.valueForKey(leftId)!

                let rightId = rightModel.primaryKey!.label
                let rightParam = right.valueForKey(rightId)!
                
                let params = [leftParam, rightParam]
                let insert = relationship.associationTable.insert()
                let sql = session.engine.compiler.compile(insert)
                
                session.engine.execute(sql, params: params)
            }
        }
    }
}
