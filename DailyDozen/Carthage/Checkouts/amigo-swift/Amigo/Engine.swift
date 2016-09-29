//
//  Engine.swift
//  Amigo
//
//  Created by Adam Venturella on 7/2/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//


public protocol Engine {

    var compiler: Compiler {get}
    var fetchLastRowIdAfterInsert: Bool {get}


    func createAll(sql: String)
    func generateSchema(meta: MetaData) -> String
    func lastrowid() -> Int

    func execute<Input, Output>(sql: String, params: [AnyObject]!, mapper: Input -> Output) -> Output
    func execute(sql: String, params: [AnyObject]!)
    func execute(sql: String)
    func execute<T: AmigoModel>(queryset: QuerySet<T>) -> [T]
    func createBatchOperation(session: AmigoSession) -> AmigoBatchOperation

    func beginTransaction()
    func commitTransaction()
    func rollback()
}