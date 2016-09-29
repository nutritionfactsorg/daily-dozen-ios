//
//  MetaData.swift
//  Amigo
//
//  Created by Adam Venturella on 7/5/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public class MetaData{
    public var tables = [String: Table]()
    var _sortedTables = [Table]()

    public var sortedTables:[Table]{
        return _sortedTables
    }

    public init(){

    }
    
    public func createAll(engine: Engine){
        let sql = engine.generateSchema(self)
        engine.createAll(sql)
    }
}