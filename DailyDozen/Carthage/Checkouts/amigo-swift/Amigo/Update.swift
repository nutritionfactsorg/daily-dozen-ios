//
//  Update.swift
//  Amigo
//
//  Created by Adam Venturella on 7/23/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public class Update: Filterable{
    public let table: Table
    public var predicate: String?
    public var predicateParams: [AnyObject]?

    public init(_ table: Table){
        self.table = table
    }
}