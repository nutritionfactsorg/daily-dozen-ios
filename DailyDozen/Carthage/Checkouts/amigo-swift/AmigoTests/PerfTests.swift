//
//  PerfTests.swift
//  Amigo
//
//  Created by Adam Venturella on 7/28/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import XCTest
import CoreData
@testable import Amigo

class PerfTests: XCTestCase {

    var amigo: Amigo!
    var engine: SQLiteEngineFactory!

    override func setUp() {
        super.setUp()
        let name = "App"
        let bundle = NSBundle(forClass: self.dynamicType)
        let url = NSURL(string:bundle.pathForResource(name, ofType: "momd")!)!
        let mom = NSManagedObjectModel(contentsOfURL: url)!

        engine = SQLiteEngineFactory(":memory:", echo: true)
        amigo = Amigo(mom, factory: engine)
        amigo.createAll()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        (amigo.config.engine as! SQLiteEngine).db.close()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceBatch() {
        let session = amigo.session

        measureBlock{
            for _ in 0..<10000{
                let d = Dog()
                d.label = "foo"

                session.add(d)
            }

            session.commit()
        }
    }

    func testPerformancePerAdd() {

        measureBlock{
            for _ in 0..<10000{
                let session = self.amigo.session
                let d = Dog()
                d.label = "foo"

                session.add(d)
                session.commit()
            }
        }
    }

    func testBatchCreateItems() {
        var statements = [String]()
        let session = amigo.session

        let objs = (0..<10000).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy"
            return d
        }

        //AmigoSqlite3.test()
       
        self.measureBlock{
            objs.forEach{
                //                let model = $0.amigoModel
                session.add($0)
//                let sql = session.insertSQL(model)
//                print(sql)
//                let params = session.insertParams($0)
//                //let sql = "something"
//                //statements.append(sql)
            }
        }

    }

    func testSQLiteBatchUpsert(){
        let session = amigo.session

        let objs = (0..<10).map{ _ -> Dog in
            let d = Dog()
            d.label = "lucy's"
            return d
        }

        self.measureBlock{
            session.batch{ batch in
                objs.forEach{
                    batch.add($0, upsert: false)
                }
            }
        }
    }

    func testBatchJoinItem() {
        var statements = [String]()

        for _ in 0..<20000{
            let d = Dog()
            d.label = "foo"
            statements.append("INSERT INTO amigotests_dog (label) VALUES ('foo');")
        }

        self.measureBlock{
            statements.joinWithSeparator("\n")
        }
        
    }

    func testBatchMerge() {
        let a1 = [1, 2]
        let a2 = [3, 4]
        var out = [Int]()

        out.appendContentsOf(a1)
        out.appendContentsOf(a2)

        print(out)

        
    }

}
