//
//  SQLiteEngine.swift
//  Amigo
//
//  Created by Adam Venturella on 7/3/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import FMDB
@testable import Amigo

class SQLiteEngineTests: XCTestCase {

    var engine: SQLiteEngine!
    var meta: MetaData!

    override func setUp() {
        super.setUp()

        meta = MetaData()
        engine = SQLiteEngine(":memory:")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        engine.db.close()
    }

//    func testCreateSchema(){
//        let done = expectationWithDescription("Done")
//
//
//        let _ = Table("dogs", metadata: meta,
//            Column("id", type: Int.self, primaryKey: true),
//            Column("name", type: String.self)
//        )
//
//        meta.createAll(engine)
//
//        engine.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"){ (result: FMResultSet) in
//
//            //XCTAssert(result.count == 1)
//            //XCTAssert(result[0][0] as! String == "dogs")
//            done.fulfill()
//        }
//
//        waitForExpectationsWithTimeout(5.0, handler:nil)
//
//    }

    func testSelect(){
//        let done = expectationWithDescription("Done")
//
//        let _ = Table("dogs", metadata: meta,
//            Column("id", type: Int.self, primaryKey: true),
//            Column("name", type: String.self)
//        )
//
//        meta.createAll(engine)
//
//        let master = Table("sqlite_master", metadata: meta,
//            Column("name", type: String.self)
//        )
//
//        engine.query(master.select()){ result in
//            XCTAssert(result.count == 1)
//            XCTAssert(result[0][0] as! String == "dogs")
//            done.fulfill()
//        }
//
//        waitForExpectationsWithTimeout(5.0, handler:nil)

    }



}
