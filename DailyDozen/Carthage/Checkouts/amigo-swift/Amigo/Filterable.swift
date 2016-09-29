//
//  Filterable.swift
//  Amigo
//
//  Created by Adam Venturella on 7/21/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public protocol Filterable{
    var predicate: String? {get set}
    var predicateParams: [AnyObject]? {get set}
}


extension Filterable{

    mutating func filter(value: String, params:[AnyObject]? = nil) -> Self{
        predicate = value
        predicateParams = params

        return self
    }
}