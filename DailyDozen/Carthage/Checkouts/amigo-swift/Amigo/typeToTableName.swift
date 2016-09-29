//
//  typeToTableName.swift
//  Amigo
//
//  Created by Adam Venturella on 8/2/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation


func typeToTableName<T: AmigoModel>(type: T.Type) -> String{
    return typeToTableName(type.description())
}

func typeToTableName(type: String) -> String{
    let parts = type.unicodeScalars.split{ $0 == "." }.map{ String($0).lowercaseString }
    return parts.joinWithSeparator("_")
}