//
//  Table.swift
//  Amigo
//
//  Created by Adam Venturella on 7/3/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public func ==(lhs: Table, rhs: Table) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


public class Table: SchemaItem, FromClause{
    public let label: String
    public let metadata: MetaData
    public var primaryKey: Column?
    public var columns = [String: Column]()
    public var indexes = [Index]()
    var model: ORMModel?

    var _sortedColumns = [Column]() // represents the order added

    public var hashValue: Int {
        return description.hashValue
    }

    public var sortedColumns: [Column]{
        return _sortedColumns
    }


    public var c: [String: Column]{
        return columns
    }

    public convenience init(_ label: String, metadata: MetaData, _ items: SchemaItem...){
        self.init(label, metadata: metadata, items: items)
    }

    public init(_ label: String, metadata: MetaData, items: [SchemaItem]){

        self.label = label
        self.metadata = metadata

        let addIndex = { (value: Index) -> ()  in
            value.table = self
            self.indexes.append(value)
        }

        let addColumn = { (value: Column) -> () in

            value._table = self
            self.columns[value.label.lowercaseString] = value
            self._sortedColumns.append(value)

            if value.primaryKey{
                self.primaryKey = value
            }

            if value.indexed{
                let label = "\(self.label)_\(value.label)_idx"
                if value.unique{
                    addIndex(Index(label, unique: true, columns:value))
                } else {
                    addIndex(Index(label, columns:value))
                }
            }
        }

        items.filter{$0 is Column}.forEach{addColumn($0 as! Column)}
        items.filter{$0 is Index}.forEach{addIndex($0 as! Index)}

        metadata.tables[label] = self
        metadata._sortedTables.append(self)
    }

    public var description: String {
        return "<Table: \(label)>"
    }
}