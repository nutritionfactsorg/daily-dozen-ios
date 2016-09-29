//
//  Insert.swift
//  Amigo
//
//  Created by Adam Venturella on 7/19/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation


public class Insert {
    public let table: Table
    public let upsert: Bool

    public init(_ table: Table){
        self.table = table
        self.upsert = false
    }

    public init(_ table: Table, upsert: Bool = false){
        self.table = table
        self.upsert = upsert
    }
}