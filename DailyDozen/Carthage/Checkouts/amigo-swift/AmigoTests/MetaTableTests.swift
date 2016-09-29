//
//  ASTTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/5/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo

class MetaTableTests: XCTestCase {

    var metadata: MetaData!
    
    override func setUp() {
        metadata = MetaData()
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTableVariadicColumns() {

        let table = Table("dogs", metadata: metadata,
            Column("id", type: Int.self, primaryKey: true),
            Column("lucy", type: String.self)
        )

        XCTAssertTrue(table.c.count == 2)
    }

    func testTableVariadicMixed() {

        let table = Table("dogs", metadata: metadata,
            Column("id", type: Int.self, primaryKey: true),
            Column("lucy", type: String.self),
            Index("dogs_lucy_idx", "lucy")
        )

        XCTAssertTrue(table.c.count == 2)
        XCTAssertTrue(table.indexes.count == 1)
    }

    func testTableList() {

        let items:[SchemaItem] = [
            Column("id", type: Int.self, primaryKey: true),
            Column("lucy", type: String.self)]

        let table = Table("dogs", metadata: metadata, items: items)

        XCTAssertTrue(table.c.count == 2)
    }

    func testMetadata() {

        let items: [SchemaItem] = [
            Column("id", type: Int.self, primaryKey: true),
            Column("lucy", type: String.self)]

        let _ = Table("dogs", metadata: metadata, items: items)

        XCTAssertTrue(metadata.tables.values.count == 1)
    }

    func testColumnAliasAccess() {

        let items:[SchemaItem] = [
            Column("id", type: Int.self, primaryKey: true),
            Column("lucy", type: String.self)]

        let table = Table("dogs", metadata: metadata, items: items)

        XCTAssertNotNil(table.c["id"]!)
    }

    func testColumnTableAssociation() {

        let items: [SchemaItem] = [
            Column("id", type: Int.self, primaryKey: true),
            Column("lucy", type: String.self)]

        let table = Table("dogs", metadata: metadata, items: items)
        let id = table.c["id"]!

        if let _ = id.table {
            XCTAssertTrue(true)
        }
        else {
            XCTFail("Value isn't set")
        }
    }

    func testPrimaryKeyTrue() {

        let items: [SchemaItem] = [
            Column("id", type: Int.self, primaryKey: true),
            Column("lucy", type: String.self)]

        let table = Table("dogs", metadata: metadata, items: items)

        XCTAssertNotNil(table.primaryKey)
    }

    func testPrimaryKeyFalse() {

        let items: [SchemaItem] = [
            Column("id", type: Int.self),
            Column("lucy", type: String.self)]

        let table = Table("dogs", metadata: metadata, items: items)

        XCTAssertNil(table.primaryKey)
    }
}
