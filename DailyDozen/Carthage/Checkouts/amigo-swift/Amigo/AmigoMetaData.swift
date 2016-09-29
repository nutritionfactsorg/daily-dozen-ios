//
//  AmigoMeta.swift
//  Amigo
//
//  Created by Adam Venturella on 7/1/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData


public class AmigoMetaData{
    var tables = [String:MetaModel]()

    public init(_ managedObjectModel: NSManagedObjectModel){
        self.initialize(managedObjectModel)
    }

    public func metaModelForType<T: AmigoModel>(type: T.Type) -> MetaModel{
        let key = type.description()
        return metaModelForName(key)
    }

    public func metaModelForName(name: String) -> MetaModel{
        return tables[name]!
    }

    func initialize(managedObjectModel: NSManagedObjectModel){
        let lookup = managedObjectModel.entitiesByName
        // there may be a better way here, right now we ensure we have 
        // all the models, then we need to go do some additional passes
        // to ensure the ForeignKey Relationships (ToOne) and the Many To Many
        // relationships (ToMany). 
        //
        // the N*3 loops hurts my heart, but for now, it'a only done
        // on initialization.


        lookup.map{metaModelFromEntity($1)}
        zip(lookup.values, tables.values).map(initializeRelationships)

        //        lookup.map{registerModel($1)}


        // zip(lookup.values, tables.values).map(initializeRelationships)
//            initializeRelationships($0, model: $1)
//        }

//        join.map{(x, y) -> String in
//            print(99)
//            return ""
//        }.count


    }

    func initializeRelationships(entity:NSEntityDescription, model: MetaModel){

        var columns = [Column]()
        var foreignKeys = [ForeignKey]()
        
        // sqlite supports FK's with actions:
        // https://www.sqlite.org/foreignkeys.html#fk_actions
        // TODO determine if iOS 9+ sqlite supports this
        // adjust column creation accordingly

        entity.relationshipsByName
              .filter{ $1.toMany == false }
              .map{ _, relationship -> Void in

                let target = relationship.destinationEntity!
                    let targetModel = metaModelForName(target.managedObjectClassName)

                    let foreignKey = ForeignKey(
                        label: relationship.name,
                        type: targetModel.primaryKey.type,
                        relatedType: targetModel.table.type,
                        optional: relationship.optional)

                    let column = Column(
                        label: "\(relationship.name)_id",
                        type: targetModel.primaryKey.type,
                        primaryKey: false,
                        indexed: true,
                        optional: relationship.optional,
                        unique: false,
                        foreignKey: foreignKey)

                    columns.append(column)
                    foreignKeys.append(foreignKey)
              }

        let model = MetaModel(
            table: model.table,
            columns: model.columns + columns,
            primaryKey: model.primaryKey,
            foreignKeys: foreignKeys)

        tables[String(model.table.type)] = model

    }


    func registerModel(model: MetaModel){

    }

    func metaModelFromEntity(entityDescription: NSEntityDescription){
        let model: MetaModel
        var primaryKey: Column?
        let table = Table.fromEntityDescription(entityDescription)
        var columns = entityDescription.attributesByName.map {
            Column.fromAttributeDescription($1)
        }

        primaryKey = columns.filter{ $0.primaryKey }.first
        if primaryKey == nil{
            primaryKey = Column.defaultPrimaryKey()
            columns = [primaryKey!] + columns
        }

        model = MetaModel(table: table, columns: columns, primaryKey: primaryKey!)
        tables[String(table.type)] = model
    }

    func createAll(engine: Engine){

    }
}