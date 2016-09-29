//
//  SpecializedColumnTests.swift
//  Amigo
//
//  Created by Adam Venturella on 1/3/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import XCTest
import Amigo


class UUIDModel: AmigoModel{
    dynamic var id: Int = 0
    dynamic var objId: String!
}

class UUIDPKModel: AmigoModel{
    dynamic var objId: String!
    dynamic var label: String = ""
}

func uuidToBytes(value: String) -> NSData{
    let uuid = NSUUID(UUIDString: value)!

    var bytes = [UInt8](count: 16, repeatedValue: 0)
    uuid.getUUIDBytes(&bytes)

    return NSData(bytes: bytes, length: bytes.count)
}



class SpecializedColumnTests: XCTestCase {

    let amigo: Amigo = {

        let uuid = ORMModel(UUIDModel.self,
            IntegerField("id", primaryKey: true),
            UUIDField("objId", indexed: true, unique: true)
        )

        let uuidPk = ORMModel(UUIDPKModel.self,
            UUIDField("objId", primaryKey: true){
                // the input case doesn't actually matter, but
                // rfc 4122 states that:
                //
                // The hexadecimal values "a" through "f" are output as
                // lower case characters and are case insensitive on input.
                //
                // See: https://www.ietf.org/rfc/rfc4122.txt
                // Declaration of syntactic structure
                return NSUUID().UUIDString.lowercaseString
            },
            CharField("label")

        )

        // now initialize Amigo
        let engine = SQLiteEngineFactory(":memory:", echo: true)
        let amigo = Amigo([uuid, uuidPk], factory: engine)
        amigo.createAll()
        
        return amigo
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUUIDDefaultValue() {
        let field = UUIDField("objId", primaryKey: true){
            // the input case doesn't actually matter, but
            // rfc 4122 states that:
            //
            // The hexadecimal values "a" through "f" are output as
            // lower case characters and are case insensitive on input.
            //
            // See: https://www.ietf.org/rfc/rfc4122.txt
            // Declaration of syntactic structure
            return NSUUID().UUIDString.lowercaseString
        }

        let value = field.valueOrDefault(nil)
        XCTAssert(value != nil)
    }

    func testUUIDDefaultValueSkip() {
        let objId = NSUUID().UUIDString

        let field = UUIDField("objId", primaryKey: true){
            // the input case doesn't actually matter, but
            // rfc 4122 states that:
            //
            // The hexadecimal values "a" through "f" are output as
            // lower case characters and are case insensitive on input.
            //
            // See: https://www.ietf.org/rfc/rfc4122.txt
            // Declaration of syntactic structure
            return NSUUID().UUIDString.lowercaseString
        }

        let value = field.valueOrDefault(objId) as! String
        XCTAssert(value == objId)
    }

    func testUUIDSerializeMalformed() {
        let objId = "ollie"

        let field = UUIDField("objId", primaryKey: true){
            // the input case doesn't actually matter, but
            // rfc 4122 states that:
            //
            // The hexadecimal values "a" through "f" are output as
            // lower case characters and are case insensitive on input.
            //
            // See: https://www.ietf.org/rfc/rfc4122.txt
            // Declaration of syntactic structure
            return NSUUID().UUIDString.lowercaseString
        }

        let value = field.serialize(objId)
        XCTAssert(value == nil)
    }

    func testUUIDSerialize() {
        let objId = NSUUID().UUIDString

        let field = UUIDField("objId", primaryKey: true){
            // the input case doesn't actually matter, but
            // rfc 4122 states that:
            //
            // The hexadecimal values "a" through "f" are output as
            // lower case characters and are case insensitive on input.
            //
            // See: https://www.ietf.org/rfc/rfc4122.txt
            // Declaration of syntactic structure
            return NSUUID().UUIDString.lowercaseString
        }

        let value = field.serialize(objId) as! NSData
        XCTAssert(value == uuidToBytes(objId))
    }

    func testUUIDColumnDeserialize() {
        // the input case doesn't actually matter, but
        // rfc 4122 states that:
        //
        // The hexadecimal values "a" through "f" are output as
        // lower case characters and are case insensitive on input.
        //
        // See: https://www.ietf.org/rfc/rfc4122.txt
        // Declaration of syntactic structure
        let objId = NSUUID().UUIDString.lowercaseString
        let uuid = UUIDModel()
        uuid.objId = objId

        let session = amigo.session

        session.add(uuid)

        if let result = session.query(UUIDModel).all().first{
            XCTAssert(result.id == 1)
            XCTAssert(result.objId == objId)
        } else {
            XCTFail()
        }

    }

    func testUUIDColumnFilter() {
        // the input case doesn't actually matter, but
        // rfc 4122 states that:
        //
        // The hexadecimal values "a" through "f" are output as
        // lower case characters and are case insensitive on input.
        //
        // See: https://www.ietf.org/rfc/rfc4122.txt
        // Declaration of syntactic structure
        let objId = NSUUID().UUIDString.lowercaseString
        let uuid = UUIDModel()
        uuid.objId = objId

        let session = amigo.session

        session.add(uuid)

        let query = session
        .query(UUIDModel)
        .filter("objId = \"\(objId)\"")

        if let results = query.all().first{
            XCTAssert(results.id == 1)
            XCTAssert(results.objId == objId)
        } else {
            XCTFail("Unable to locate object for filter: 'objId = \(objId)'")
        }
        
    }

    func testUUIDAsPrimaryKey() {
        let uuid = UUIDPKModel()
        uuid.label = "Lucy"

        let session = amigo.session

        session.add(uuid)

        if let result = session.query(UUIDPKModel).get(uuid.objId){
            XCTAssert(result.objId == uuid.objId)
            XCTAssert(result.label == uuid.label)
        } else {
            XCTFail("Unable to locate object for primary key: \(uuid.objId)")
        }
    }

    func testNSDataBatchUpsertTest() {
        // we have all the models setup here and a 
        // UUID is a BLOB for Amigo, so rather than
        // stick this with the other batch tests and need to 
        // duplicate the initialization code, we are just 
        // doing it here.

        // remember batch operations do not write any data
        // back to the original model. objId here is a 
        // "defaultValue" column, which means that it will
        // be generated at query time, but it will not
        // be written back to the model.
        // see the batch insert test below for the test
        // that covers this.
        let uuid = UUIDPKModel()
        uuid.label = "Lucy"
        uuid.objId = NSUUID().UUIDString.lowercaseString

        let session = amigo.session

        session.batch{ batch in
            batch.add(uuid, upsert: true)
        }

        if let result = session.query(UUIDPKModel).get(uuid.objId){
            XCTAssert(result.objId == uuid.objId)
            XCTAssert(result.label == uuid.label)
        } else {
            XCTFail("Unable to locate object for primary key: \(uuid.objId)")
        }
    }

    func testNSDataBatchInsertTest() {
        // we have all the models setup here and a
        // UUID is a BLOB for Amigo, so rather than
        // stick this with the other batch tests and need to
        // duplicate the initialization code, we are just
        // doing it here.


        let uuid = UUIDPKModel()
        uuid.label = "Lucy"

        let session = amigo.session

        session.batch{ batch in
            batch.add(uuid)
        }

        let obj = session.query(UUIDPKModel).all().first!
        print(obj.objId)

        if let result = session.query(UUIDPKModel).get(obj.objId){
            XCTAssert(result.objId == obj.objId)
            XCTAssert(result.label == obj.label)
        } else {
            XCTFail("Unable to locate object for primary key: \(uuid.objId)")
        }
    }
}
