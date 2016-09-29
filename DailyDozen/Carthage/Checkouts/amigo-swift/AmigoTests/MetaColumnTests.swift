//
//  MetaColumnTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/6/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
import Amigo

class MetaColumnTests: XCTestCase {


    func testString() {
        let column = Column("test", type: String.self)
        XCTAssertTrue(column.type == NSAttributeType.StringAttributeType)
    }

    func testInt16() {
        let column = Column("test", type: Int16.self)
        XCTAssertTrue(column.type == NSAttributeType.Integer16AttributeType)
    }

    func testInt32() {
        let column = Column("test", type: Int32.self)
        XCTAssertTrue(column.type == NSAttributeType.Integer32AttributeType)
    }

    func testInt64() {
        let column = Column("test", type: Int64.self)
        XCTAssertTrue(column.type == NSAttributeType.Integer64AttributeType)
    }

    func testInt() {
        let column = Column("test", type: Int.self)
        XCTAssertTrue(column.type == NSAttributeType.Integer64AttributeType)
    }

    func testBool() {
        let column = Column("test", type: Bool.self)
        XCTAssertTrue(column.type == NSAttributeType.BooleanAttributeType)
    }

    func testDouble() {
        let column = Column("test", type: Double.self)
        XCTAssertTrue(column.type == NSAttributeType.DoubleAttributeType)
    }

    func testFloat() {
        let column = Column("test", type: Float.self)
        XCTAssertTrue(column.type == NSAttributeType.FloatAttributeType)
    }

    func testUInt8Buffer() {
        let column = Column("test", type: [UInt8].self)
        XCTAssertTrue(column.type == NSAttributeType.BinaryDataAttributeType)
    }

    func testNSData() {
        let column = Column("test", type: NSData.self)
        XCTAssertTrue(column.type == NSAttributeType.BinaryDataAttributeType)
    }

    func testNSDate() {
        let column = Column("test", type: NSDate.self)
        XCTAssertTrue(column.type == NSAttributeType.DateAttributeType)
    }

    func testNSString() {
        let column = Column("test", type: NSString.self)
        XCTAssertTrue(column.type == NSAttributeType.StringAttributeType)
    }

    func testDecimalNumber() {
        let column = Column("test", type: NSDecimalNumber.self)
        XCTAssertTrue(column.type == NSAttributeType.DecimalAttributeType)
    }

    func testNoDefaultValueWithNil() {
        let column = Column("test", type: String.self)

        let value = column.valueOrDefault(nil)
        XCTAssert(value == nil)
    }

    func testNoDefaultValueWithValue() {
        let column = Column("test", type: String.self)

        let value = column.valueOrDefault("ollie") as! String
        XCTAssert(value == "ollie")
    }

    func testDefaultValue() {
        let column = Column("test", type: String.self){
            return "ollie"
        }

        let value = column.valueOrDefault(nil) as! String
        XCTAssert(value == "ollie")
    }

    func testDefaultValueSkip() {
        let column = Column("test", type: String.self){
            return "ollie"
        }

        let value = column.valueOrDefault("lucy") as! String
        XCTAssert(value == "lucy")
    }

    func testForeignKeyColumn() {
        let meta = MetaData()
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        XCTAssert(t1.c["id"]!.table != nil)

        let t2 = Table("owner", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1.c["id"]!))
        )

        XCTAssertTrue(t2.c["dog_id"]!.type == t1.primaryKey!.type)
    }

    func testForeignKeyTable() {
        let meta = MetaData()
        let t1 = Table("dogs", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self)
        )

        XCTAssert(t1.c["id"]!.table != nil)

        let t2 = Table("owner", metadata: meta,
            Column("id", type: Int.self, primaryKey: true),
            Column("label", type: String.self),
            Column("dog_id", type: ForeignKey(t1))
        )

        XCTAssertTrue(t2.c["dog_id"]!.type == t1.primaryKey!.type)
    }


}
