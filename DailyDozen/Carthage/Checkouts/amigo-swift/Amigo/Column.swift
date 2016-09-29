//
//  Column.swift
//  Amigo
//
//  Created by Adam Venturella on 7/3/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public func ==(lhs: Column, rhs: Column) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


public class Column: SchemaItem, CustomStringConvertible, Hashable{

    public let label: String
    public let type: NSAttributeType
    public let primaryKey: Bool
    public let indexed: Bool
    public let unique: Bool
    public var optional: Bool
    public let defaultValue: (() -> AnyObject?)?

    public var hashValue: Int{
        return description.hashValue
    }

    public func modelValue(model: AmigoModel) -> AnyObject? {
        return model.valueForKey(label)
    }

    public func valueOrDefault(model: AmigoModel) -> AnyObject? {
        return valueOrDefault(modelValue(model))
    }

    public func valueOrDefault(value: AnyObject?) -> AnyObject? {
        if let defaultValue = defaultValue where value == nil{
            return defaultValue()
        }

        return value
    }

    public func serialize(value: AnyObject?) -> AnyObject? {
        return value
    }

    public func deserialize(value: AnyObject?) -> AnyObject? {
        return value
    }

    var _foreignKey: ForeignKey?
    public var foreignKey: ForeignKey? {
        get{
            return _foreignKey
        }
    }

    var _table: Table? {
        didSet{
            _qualifiedLabel = "\(_table!.label).\(label)"
        }
    }

    public var table: Table? {
        return _table
    }

    var _qualifiedLabel: String?
    public var qualifiedLabel: String? {
        return _qualifiedLabel
    }

    public init(_ label: String, type: NSAttributeType, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil){
        self.label = label
        self.type = type
        self.primaryKey = primaryKey
        self.indexed = indexed
        self.optional = optional
        self.unique = unique
        self.defaultValue = defaultValue
    }

    public convenience init(_ label: String, type: Any.Type, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil){
        let attrType: NSAttributeType

        switch type{
        case is NSString.Type:
            attrType = .StringAttributeType
        case is String.Type:
            attrType = .StringAttributeType
        case is Int16.Type:
            attrType = .Integer16AttributeType
        case is Int32.Type:
            attrType = .Integer32AttributeType
        case is Int64.Type:
            attrType = .Integer64AttributeType
        case is Int.Type:
            attrType = .Integer64AttributeType
        case is NSDate.Type:
            attrType = .DateAttributeType
        case is [UInt8].Type:
            attrType = .BinaryDataAttributeType
        case is NSData.Type:
            attrType = .BinaryDataAttributeType
        case is NSDecimalNumber.Type:
            attrType = .DecimalAttributeType
        case is Double.Type:
            attrType = .DoubleAttributeType
        case is Float.Type:
            attrType = .FloatAttributeType
        case is Bool.Type:
            attrType = .BooleanAttributeType
        default:
            attrType = .UndefinedAttributeType
        }

        self.init(label, type: attrType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)

    }

    public convenience init(_ label: String, type: ForeignKey, primaryKey: Bool = false, indexed: Bool = true, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil){
        let associatedType = type.relatedColumn.type
        self.init(label, type: associatedType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
        _foreignKey = ForeignKey(type.relatedColumn, column: self)
    }


    public var description: String {
        if let t = table{
            return "<Column<\(t.label)>:\(label), primaryKey:\(primaryKey), indexed: \(indexed), optional: \(optional), unique:\(unique)>"
        } else {
            return "<Column:\(label), primaryKey:\(primaryKey), indexed: \(indexed), optional: \(optional), unique:\(unique)>"
        }

    }
}