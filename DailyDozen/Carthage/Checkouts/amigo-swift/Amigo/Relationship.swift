//
//  Relationship.swift
//  Amigo
//
//  Created by Adam Venturella on 7/24/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

// there is probably a way to combine ForeignKey With relationship, they
// both are a relationship afterall. Need to think about that abstraction.

public protocol Relationship: MetaItem{
    var label: String {get}
    var type: RelationshipType {get}

}

public enum RelationshipType{
    case OneToMany, ManyToMany
}

public func ==(lhs: ManyToMany, rhs: ManyToMany) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public class ManyToMany: Relationship, CustomStringConvertible, Hashable{
    public let label: String
    public let type = RelationshipType.ManyToMany

    var left: ORMModel!
    var right: ORMModel!
    var through: ORMModel?
    var tables: [String]!
    var throughModel: String?
    var associationTable: Table!
    var partial: ((type: String) -> Void)?

    public init<T: AmigoModel, U: AmigoModel>(_ label: String, using: T.Type, throughModel: U.Type? = nil){
        self.label = label
        self.partial = self.partialInit(using, throughModel: throughModel)
    }

    public init(_ label: String, tables:[String], throughModel: String? = nil){
        self.label = label
        self.tables = tables.sort()

        if let throughModel = throughModel {
            self.throughModel = throughModel
        }
    }

    func partialInit<T: AmigoModel, U: AmigoModel>
        (right: T.Type, throughModel: U.Type? = nil)
        (left: String){

        let r = typeToTableName(right)
        let l = typeToTableName(left)

        self.tables = [l, r].sort()

        if let throughModel = throughModel{
            self.throughModel = throughModel.description()
        }

        self.partial = nil
    }

    public lazy var tableName: String = {
        return self.tables.joinWithSeparator("_")
    }()

    public lazy var hashValue: Int = {
        return self.tables.joinWithSeparator("_").hashValue
    }()

    public var description: String{
        return "<ManyToMany: \(label)>"
    }
}

public class OneToMany: Relationship, CustomStringConvertible{
    public let label: String
    public let type = RelationshipType.OneToMany

    let table: String
    var column: String!
    var originTable: String!

    public convenience init<T: AmigoModel>(_ label: String, using: T.Type){
        let tableName = typeToTableName(using)
        self.init(label, table: tableName, column: nil)
    }

    public init(_ label: String, table: String, column: String? = nil){
        self.label = label
        self.table = table
        self.column = column
    }

    func initOriginType(value: String){
        originTable = typeToTableName(value)
    }

    public var description: String{
        return "<OneToMany: \(label)>"
    }
}


//public class Relationship: MetaItem, CustomStringConvertible{
//    public let label: String
//    public let type: RelationshipType
//
//    let relatedTableLabel: String
//    let relatedColumnLabel: String
//    
//    public init(_ label: String, table: String, column: String, type: RelationshipType){
//        self.label = label
//        self.type = type
//        self.relatedTableLabel = table
//        self.relatedColumnLabel = column
//    }
//
//    public var description: String{
//        return "<Relationship: \(label)>"
//    }
//}