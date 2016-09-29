//
//  SQLiteFormatTests.swift
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import XCTest
import Amigo

class SQLiteFormatTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEscapeNilWithQuotes() {
        let value: String? = nil
        let result = SQLiteFormat.escapeWithQuotes(value)
        XCTAssert(result == "NULL")
    }

    func testEscapeNilWithoutQuotes() {
        let value: String? = nil
        let result = SQLiteFormat.escapeWithoutQuotes(value)
        XCTAssert(result == "(NULL)")
    }

    func testEscapeWithQuotes() {
        let value = "test's"
        let result = SQLiteFormat.escapeWithQuotes(value)
        XCTAssert(result == "'test''s'")
    }

    func testEscapeWithoutQuotes() {
        let value = "test's"
        let result = SQLiteFormat.escapeWithoutQuotes(value)
        XCTAssert(result == "test''s")
    }

    func testEscapeBlob() {

        let uuid = NSUUID()
        var bytes = [UInt8](count: 16, repeatedValue: 0)
        uuid.getUUIDBytes(&bytes)

        let data = NSData(bytes: bytes, length: bytes.count)

        let hex = SQLiteFormat.hexStringWithData(data)
        let result = SQLiteFormat.escapeBlob(data)

        XCTAssert(result == "x'\(hex)'")
    }

    func testEscapeEmptyBlob() {

        let data = NSData()
        let result = SQLiteFormat.escapeBlob(data)

        XCTAssert(result == "NULL")
    }

    func testEscapeNilBlob() {

        var data: NSData?
        let result = SQLiteFormat.escapeBlob(data)

        XCTAssert(result == "NULL")
    }
}