//
//  AmigoSessionAsyncTests.swift
//  Amigo
//
//  Created by Adam Venturella on 1/16/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import XCTest
import Amigo


class AmigoSessionAsyncTests: AmigoTestBase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAsyncActionNoResult() {
        let done = expectationWithDescription("done")
        let session = amigo.session

        let complete = {
            let results = session.query(Dog).all()
            XCTAssert(results.count == 1)

            done.fulfill()
        }

        session.async{
            let d1 = Dog()
            d1.label = "lucy"
            session.add(d1)
            complete()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)

    }

    func testAsyncActionResult() {
        let done = expectationWithDescription("done")
        let session = amigo.session

        session.async{ () -> Dog in
            let d1 = Dog()
            d1.label = "lucy"
            session.add(d1)

            return d1

        }.then{ dog in

            let results = session.query(Dog).all()
            XCTAssert(results.count == 1)
            XCTAssert(results[0].id == dog.id)
            XCTAssert(results[0].label == dog.label)

            done.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }

    func testAsyncActionNoResultThen() {
        let done = expectationWithDescription("done")
        let session = amigo.session

        session.async{
            let d1 = Dog()
            d1.label = "lucy"
            session.add(d1)

        }.then{
            let results = session.query(Dog).all()
            XCTAssert(results.count == 1)

            done.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
    }

    func testAsyncActionCustomQueue() {
        let queue = dispatch_queue_create("com.amigo.async.tests", nil)

        let done = expectationWithDescription("done")
        let session = amigo.session

        session.async(queue: queue){
            let d1 = Dog()
            d1.label = "lucy"
            session.add(d1)

        }.then{
            let results = session.query(Dog).all()
            XCTAssert(results.count == 1)

            done.fulfill()
        }

        waitForExpectationsWithTimeout(60.0, handler: nil)
        
    }

    func testAsyncResultsArray() {

        let done = expectationWithDescription("done")
        let session = amigo.session

        let callback : ([Dog]) -> () = { results in
            XCTAssert(results.count == 1)
            done.fulfill()
        }

        session.async{ () -> [Dog] in
            let d1 = Dog()
            d1.label = "lucy"
            session.add(d1)
            return session.query(Dog).all()
        }.then(callback)


        waitForExpectationsWithTimeout(60.0, handler: nil)
        
    }

}
