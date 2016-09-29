//
//  OrderBy.swift
//  Amigo
//
//  Created by Adam Venturella on 7/28/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public protocol OrderBy{
    var keyPath: String {get}
    var ascending: Bool {get}

    init(_ keyPath: String)
}

public struct Asc: OrderBy{
    public let ascending = true
    public let keyPath: String

    public init(_ keyPath: String){
        self.keyPath = keyPath
    }
}

public struct Desc: OrderBy{
    public let ascending = false
    public let keyPath: String

    public init(_ keyPath: String){
        self.keyPath = keyPath
    }
}