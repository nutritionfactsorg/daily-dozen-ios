//
//  DailyDozenTests.swift
//  DailyDozenTests
//
//  Created by marc on 2019.11.13.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import XCTest
@testable import DailyDozen // module
import RealmSwift // List

/// `IPHONEOS_DEPLOYMENT_TARGET` 12.4+
class DailyDozenTests: XCTestCase {
        
    lazy var testBundle = Bundle(for: type(of: self))
    lazy var testBundleUrl = testBundle.bundleURL
    
    override func setUp() {
        // Setup code. Called before each test method invocation.
    }

    override func tearDown() {
        // Teardown code. Called after each test method invocation.
    }

    func testA() {
        print("\n::: testA :::")
        
        let fm = FileManager.default
        let testWorkingDirPath = fm.currentDirectoryPath
        print("TestBundle Directory: \n\(testBundleUrl.path)")
        print("TestBundle Working Directory = \n\(testWorkingDirPath)")
        
        //import Foundation
        //import RealmSwift

        //let mainTask = MainTask()

        // Import safety approaches.
        // 1. whole new file until complete and validated. rename.
        // 2. or, have a database pre-validation pass.
        // 3. ... wait until release feature for safety.

        //mainTask.doTask01ImportRealmCsv()
        
        print(":::::::::::::\n")
    }

    // Apr  4, 2003 International Carrot Day
    // Oct 25, 1995 World Pasta Day
    // Oct  2, 2013 Nationale Kale Day
    
    func testB() {
        print("\n::: testB :::")
        // World Porridge Day: Oct 10, 2009 (initial celebration date)
        let dateA = Date.init(datestampKey: "20091010")!
        
        let realmOld = RealmProviderVersion02()
        let dozeA = realmOld.getDoze(for: dateA)
        let dozeAItems: List<Item> = dozeA.items
        realmOld.saveStates([true, false, true], with: dozeAItems[0].id)
        
        let realmNew = RealmProvider()
        let trackerA = realmNew.getDailyTracker(date: dateA)
        //realmNew.saveCount(1, date: dateA, type: DataCountType.dozeBeans)
        
        // :!!!:NYI: case where date is not present in database.
        
        print(":::::::::::::\n")
    }
    
    func testC() {
        print("\n::: testC :::")
        
    }
    
    func testDatestamp() {
        print("\n::: testDatestamp :::")
        // World Vegan Day:  Nov 1, 1994 (initial celebration date)
        guard let date = Date(datestampKey: "19941102") else {
            XCTFail("testDatestamp() failed to create date.")
            return
        }
        
        print("date: '\(date)'")
        print("datestampKey: '\(date.datestampKey)'")
        print("datestampHHmm: '\(date.datestampHHmm)'")
        XCTAssertEqual(date.datestampKey, "19941102")
        XCTAssertEqual(date.datestampHHmm, "00:00")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
