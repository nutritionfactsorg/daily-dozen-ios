//
//  Mapper.swift
//  Amigo
//
//  Created by Adam Venturella on 7/12/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation


public protocol Mapper{
    init()
}

extension Mapper{
    func instanceFromString(value: String) -> AmigoModel{
        let type = NSClassFromString(value) as! NSObject.Type
        let obj = type.init() as! AmigoModel
        return obj
    }

    func dottedNameToTableName(name: String) -> String{
        return typeToTableName(name)
    }
}


