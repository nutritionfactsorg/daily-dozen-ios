//
//  EntityDescriptionMapper.swift
//  Amigo
//
//  Created by Adam Venturella on 7/9/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData
// need to make an intermediate model to query against.

public class EntityDescriptionMapper: AmigoEntityDescriptionMapper{

    public required init(){}

    public func map(entity: NSEntityDescription) -> ORMModel {
        let type = entity.managedObjectClassName
        var items: [MetaItem]

        items = Array(entity.propertiesByName.values).map(mapColumn)
            .filter{ $0 != nil }
            .map{ $0! }

        let model = ORMModel(type, properties: items)
        return model
    }

    func mapColumn(obj: NSPropertyDescription) -> MetaItem?{
        var column: MetaItem?

        if obj is NSAttributeDescription{
            column = mapAttributeColumn(obj as! NSAttributeDescription)
        } else if obj is NSRelationshipDescription{
            column = mapRelationshipColumn(obj as! NSRelationshipDescription)
        }

        return column
    }

    func mapAttributeColumn(obj: NSAttributeDescription) -> MetaItem{
        let name = obj.name
        let indexed = obj.indexed
        let optional = obj.optional
        let type = obj.attributeType
        let primaryKey: Bool


        if let pk = obj.userInfo?["primaryKey"] as? NSString{
            primaryKey = pk.boolValue
        } else{
            primaryKey = false
        }

        return Column(name,
            type: type,
            primaryKey: primaryKey,
            indexed: indexed,
            optional: optional)
    }

    func mapRelationshipColumn(obj: NSRelationshipDescription) -> MetaItem?{

        if obj.toMany == false{
            return mapToOneRelationship(obj)
        } else {
            return mapToManyRelationship(obj)
        }
    }

    func mapToManyRelationship(obj: NSRelationshipDescription) -> Relationship?{
        guard let inverseRelationship = obj.inverseRelationship else {
            return nil
        }

        if inverseRelationship.toMany == true{
            return mapManyToManyRelationship(obj)
        } else {
            return mapOneToManyRelationship(obj)
        }
    }

    func mapManyToManyRelationship(obj: NSRelationshipDescription) -> Relationship{

        let label = obj.name
        let entity = obj.entity
        let relationship = obj.inverseRelationship!
        let relatedEntity = relationship.entity
        let tableName = dottedNameToTableName(entity.managedObjectClassName)
        let relatedTableName = dottedNameToTableName(relatedEntity.managedObjectClassName)
        let tables = [tableName, relatedTableName]
        let throughModel : String?

        if let through = obj.userInfo?["throughModel"]{
            throughModel = through as? String
        } else{
            throughModel = nil
        }

        return ManyToMany(label, tables: tables, throughModel: throughModel)
    }

    func mapOneToManyRelationship(obj: NSRelationshipDescription) -> Relationship{
        let label = obj.name
        let relationship = obj.inverseRelationship!
        let entity = relationship.entity
        let tableName = dottedNameToTableName(entity.managedObjectClassName)

        return OneToMany(label, table: tableName, column: relationship.name)
    }

    func mapToOneRelationship(obj: NSRelationshipDescription) -> Column{


        let name = obj.name
        let entity = obj.destinationEntity!
        let destinationTable = dottedNameToTableName(entity.managedObjectClassName)
        let table = ORMModel.metadata.tables[destinationTable]!

        return Column(name, type: ForeignKey(table))
    }
}