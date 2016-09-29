//
//  AmigoConfiguration.swift
//  Amigo
//
//  Created by Adam Venturella on 6/29/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public protocol AmigoConfigured{
    var config: AmigoConfiguration {get}
}

extension AmigoConfigured{
    var mapper: Mapper{
        return config.mapper
    }

    var engine: Engine{
        return config.engine
    }

    var tableIndex: [String: ORMModel]{
        return config.tableIndex
    }

    var typeIndex: [String: ORMModel]{
        return config.typeIndex
    }

}

public struct AmigoConfiguration{

    public let engine: Engine
    public let mapper: Mapper
    public let tableIndex: [String: ORMModel]
    public let typeIndex: [String: ORMModel]


    static var documentsDirectory: String{
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1].path!
    }

//    public static var defaultConfiguration: AmigoConfiguration{
//        return AmigoConfiguration.fromName("App")
//    }

//    public static func fromName(name: String) -> AmigoConfiguration{
//        let dir = AmigoConfiguration.documentsDirectory.stringByAppendingPathComponent("\(name).sqlite")
//        let engine = SQLiteEngine(path: dir)
//        let mapper = EntityDescriptionMapper()
//
//        return AmigoConfiguration(engine: engine, mapper: mapper)
//    }
//
//    public static func fromMemory() -> AmigoConfiguration{
//        let engine = SQLiteEngine(path: ":memory:")
//        let mapper = EntityDescriptionMapper()
//
//        return AmigoConfiguration(engine: engine, mapper: mapper)
//    }
}