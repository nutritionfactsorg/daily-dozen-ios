//
//  SQLiteTypeCompiler.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData


public struct SQLiteTypeCompiler : TypeCompiler{
    
    public func compileInteger16() -> String{
        return "INTEGER"
    }

    public func compileInteger32() -> String{
        return "INTEGER"
    }

    public func compileInteger64() -> String{
        return "INTEGER"
    }

    public func compileString() -> String{
        return "TEXT"
    }

    public func compileBoolean() -> String{
        return "INTEGER"
    }

    public func compileDate() -> String{
        return "TEXT"
    }

    public func compileBinaryData() -> String{
        return "BLOB"
    }

    public func compileDecimal() -> String{
        return "REAL"
    }

    public func compileDouble() -> String{
        return "REAL"
    }

    public func compileFloat() -> String{
        return "REAL"
    }
    
    public func compileUndefined() -> String{
        return "BLOB"
    }
    
}