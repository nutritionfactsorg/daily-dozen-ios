//
//  AmigoTests.swift
//  AmigoTests
//
//  Created by Adam Venturella on 6/29/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import FMDB
import Amigo

class AmigoTests: AmigoTestBase {

    func testSelectRelated(){
        let select: Select
        let sql: String
        let query = amigo.query(People)
        query.selectRelated("dog", "cat")

        select = query.compile()
        sql = amigo.config.engine.compiler.compile(select)
        print(sql)
    }

    func testSelectValues(){
        let select: Select
        let sql: String
        let query = amigo.query(People)
        query.selectRelated("dog")
        query.values("id", "label", "dog.id")

        select = query.compile()
        sql = amigo.config.engine.compiler.compile(select)
        print(sql)
    }
}
