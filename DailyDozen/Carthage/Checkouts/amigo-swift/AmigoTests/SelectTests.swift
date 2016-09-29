//
//  SelectTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/7/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import Amigo

class SelectTests: XCTestCase {

    var meta: MetaData!

    override func setUp() {
        super.setUp()
        meta = MetaData()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTableSelect() {
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let select = Select(t1)
        XCTAssertEqual(select.columns.count, 2)
    }

    func testTableSelectJoin(){
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t2 = Table("cats", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        let t3 = Table("people", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1)),
            Column("cat_id", type: ForeignKey(t2))
        )

        let j1 = t3.join(t1)
        let j2 = t3.join(t2)
        let select = Select(t3).selectFrom(j1, j2)

    }

    

}
