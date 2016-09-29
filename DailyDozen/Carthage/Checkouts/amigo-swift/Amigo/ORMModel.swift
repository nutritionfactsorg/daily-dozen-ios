//
//  ORMModel.swift
//  Amigo
//
//  Created by Adam Venturella on 7/12/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public func ==(lhs: ORMModel, rhs: ORMModel) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


public class ORMModel: Hashable{
    public static let metadata = MetaData()

    public let table: Table
    public let foreignKeys: [String:Column]
    public let relationships: [String:Relationship]
    public let columns: [Column]
    public let primaryKey: Column!
    public let type: String
    public let label: String
    public var throughModelRelationship: ManyToMany?
    public var sqlInsert: String?
    public var sqlUpsert: String?
    public var sqlUpdate: String?
    public var sqlDelete: String?
    public var sqlDeleteThrough = [String: String]()
    public var sqlInsertThrough = [String: String]()

    public convenience init<T:AmigoModel>(_ qualifiedType: T.Type, _ properties: MetaItem...){
        let type = qualifiedType.description()
        self.init(type, properties: properties)
    }

    public convenience init(_ qualifiedType: String, properties: MetaItem...){
        self.init(qualifiedType, properties: properties)
    }

    public init(_ qualifiedType: String, properties:[MetaItem]){

        let schemaItems = properties.filter{$0 is SchemaItem}.map{ $0 as! SchemaItem}

        let relationshipList = properties.filter{$0 is Relationship}.map{ $0 as! Relationship }
        let nameParts = qualifiedType.unicodeScalars
                       .split{ $0 == "." }
                       .map{ String($0).lowercaseString }

        let tableName = nameParts.joinWithSeparator("_")
        var tmpForeignKeys = [String:Column]()
        var tmpColumns = [Column]()
        var tmpPrimaryKey: Column!
        var tmpRelationships = [String: Relationship]()


        relationshipList.forEach{ (each: Relationship) -> Void in
            if let m2m = each as? ManyToMany, let partial = m2m.partial{
                partial(type: qualifiedType)
            }

            if let o2m = each as? OneToMany{
                o2m.initOriginType(qualifiedType)
            }
        }

        type = qualifiedType
        label = nameParts[1]

        // as an ORMModel we do some fancy name mangling with foreignKey Columns:
        let transformedSchemaItems = schemaItems.map{ item -> SchemaItem in

            if let column = item as? Column, let fk = column.foreignKey{
                let associatedPrimaryKeyName = fk.relatedColumn.label
                // behold! the fancy name mangling
                let label = "\(column.label)_\(associatedPrimaryKeyName)"

                let primaryKey = column.primaryKey
                let indexed = column.indexed
                let unique = column.unique
                let defaultValue = column.defaultValue

                let newColumn = Column(label, type: fk, primaryKey: primaryKey, indexed: indexed, unique: unique, defaultValue: defaultValue)
                tmpForeignKeys[column.label] = newColumn

                return newColumn as SchemaItem
            }

            return item
        }

        table = Table(tableName, metadata: ORMModel.metadata, items: transformedSchemaItems)
        relationshipList.forEach{tmpRelationships[$0.label] = $0}

        table.sortedColumns.forEach{ value -> () in

            guard value.foreignKey == nil else {
                return
            }

            tmpColumns.append(value)

            if value.primaryKey {
                tmpPrimaryKey = value
            }
        }

        foreignKeys = tmpForeignKeys
        columns = tmpColumns
        primaryKey = tmpPrimaryKey
        relationships = tmpRelationships

        AmigoModel.amigoModelIndex[qualifiedType] = self
        table.model = self
    }

    public var hashValue: Int{
        return type.hashValue
    }
}