//
//  SQLiteEngineFactory.swift
//  Amigo
//
//  Created by Adam Venturella on 7/22/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public struct SQLiteEngineFactory: EngineFactory{
    public let path: String
    public let echo: Bool
    public let engine: SQLiteEngine

    public init(_ path: String, echo: Bool = false){
        self.path = path
        self.echo = echo
        self.engine = SQLiteEngine(path, echo: echo)
    }

    public func connect() -> Engine {
        return engine
    }
}