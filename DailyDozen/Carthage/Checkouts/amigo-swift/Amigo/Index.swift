//
//  Index.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public class Index: SchemaItem, CustomStringConvertible{
    public let label: String
    public let unique: Bool

    public var columns: [Column]!
    public var table: Table? {
        didSet{
            if let strings = columnStrings{
                columns = strings.map{ table!.c[$0]! }
            }
        }
    }

    var columnStrings: [String]?

    public convenience init(_ label: String, unique: Bool = false, _ columns: String...){
        self.init(label, unique: unique, columns: columns)
    }

    public convenience init(_ label: String, unique: Bool = false, columns: [String] ){
        self.init(label, unique: unique, columns: nil)
        columnStrings = columns
    }

    public convenience init(_ label: String, unique: Bool = false, columns: Column...){
        self.init(label, unique: unique, columns: columns)
    }

    public init(_ label: String, unique: Bool = false, columns maybeColumns: [Column]? ){
        self.label = label
        self.unique = unique

        if let columns = maybeColumns{
            self.columns = columns
            self.table = columns[0].table
        }
    }

    public var description: String{
        return "<Index: \(label)>"
    }
}