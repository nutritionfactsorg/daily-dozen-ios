//
//  AmigoMeta.swift
//  Amigo
//
//  Created by Adam Venturella on 7/1/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData

@testable import Amigo

class AmigoMeta: XCTestCase {
    var amigo: Amigo!
    var config: AmigoConfiguration!

    override func setUp() {
        super.setUp()

        let bundle = NSBundle(forClass: self.dynamicType)
        config = AmigoConfiguration.fromName("App", bundle: bundle)
        amigo = Amigo(config: config)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateAll(){
        //let meta = AmigoMetaData(amigo.managedObjectModel)
        //let engine = SQLiteEngine(path: NSURL(string:"")!)
        // engine.createAll(meta)
    }

    
    func testMetaModelForType() {
        //let meta = AmigoMetaData(amigo.managedObjectModel)
        //let value = meta.metaModelForType(Author)
        //XCTAssertNotNil(value)
        //let engine = SQLiteEngine(path: NSURL(string:"")!)
        //meta.createAll(engine)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testSQLLiteEngine(){
//        let session = amigo.session
//        let engine = session.config.engine as! SQLiteEngine
//        let query = session.query(Post)
//
//        engine.createQueryFields(<#T##query: T##T#>, model: <#T##MetaModel#>)
//        .all()
    }


    
    func testPerformanceExample() {

        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
