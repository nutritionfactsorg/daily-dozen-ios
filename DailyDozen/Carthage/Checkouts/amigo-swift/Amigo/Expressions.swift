//
//  CreateTable.swift
//  Amigo
//
//  Created by Adam Venturella on 7/6/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public class Expression<T>{
    let element: T

    public init(element: T){
        self.element = element
    }
}


public class CreateColumn: Expression<Column>{
    public init(_ column: Column){
        super.init(element: column)
    }
}


public class CreateIndex: Expression<Index>{
    public init(_ index: Index){
        super.init(element: index)
    }
}


public class CreateTable: Expression<Table>{
    let columns: [CreateColumn]

    public init(_ table: Table){
        self.columns = table.sortedColumns.map(CreateColumn.init)
        super.init(element: table)
    }
}