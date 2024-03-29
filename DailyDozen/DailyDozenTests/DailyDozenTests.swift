//
//  DailyDozenTests.swift
//  DailyDozenTests
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import XCTest
@testable import DailyDozen // module
import RealmSwift // List

/// `IPHONEOS_DEPLOYMENT_TARGET` 12.4+
class DailyDozenTests: XCTestCase {
        
    lazy var testBundle = Bundle(for: type(of: self))
    lazy var testBundleUrl = testBundle.bundleURL
    
    // World Pasta Day: Oct 25, 1995
    let date1995Pasta = Date(datestampKey: "19951025")!
    // International Carrot Day: Apr  4, 2003
    let date2003Carrot = Date(datestampKey: "20030404")!
    // World Porridge Day: Oct 10, 2009 (initial celebration date)
    let date2009Porridge = Date(datestampKey: "20091010")!
    // Nationale Kale Day: Oct  2, 2013
    let date2013Kale = Date(datestampKey: "20131002")!

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
        //
        //let exampleTask = ExampleTask()
        //exampleTask.doTask01ImportRealmCsv()
        
        print(":::::::::::::\n")
    }

    func testB() {
        print("\n::: testB :::")
        let date = date2009Porridge
        
        let urlV01 = workingUrl.appendingPathComponent("testBV01.realm", isDirectory: false)
        let realmV01 = RealmProvider(fileURL: urlV01)
        _ = realmV01.getDailyTracker(date: date)
        realmV01.saveCount(1, date: date, countType: DataCountType.dozeBeans)
        
        let trackerReadV01 = realmV01.getDailyTracker(date: date)
        XCTAssertEqual(trackerReadV01.itemsDict.count, DataCountType.allCases.count)
        
        print(":::::::::::::\n")
    }
    
    var workingUrl: URL {
        URL.inDocuments()
    }
    
    func testC() {
        print("\n::: testC :::")
        // Oct  2, 2013 Nationale Kale Day
        let date00 = date2013Kale

        let urlV01 = workingUrl.appendingPathComponent("testCV01.realm", isDirectory: false)
        let realmMngrV01 = RealmManager(fileURL: urlV01)
        let realmDBV01 = realmMngrV01.realmDb
        realmDBV01.deleteAllObjects()

        // Check new content length & values
        let trackersPass01 = realmDBV01.getDailyTrackers()
        XCTAssert(trackersPass01.count == 1, "incorrect number of imported legacy trackers")
        XCTAssert(
            trackersPass01[0].itemsDict[.dozeBeans]!.count == 2,
            ""
        )
        
        // Change a value
        realmDBV01.saveCount(3, date: date00, countType: .dozeBeans)
        
        // 02: export new database format
        let filename02 = realmMngrV01.csvExport(marker: "DB01_UnitTestC_Data")
        realmMngrV01.realmDb.deleteAllObjects()
        realmMngrV01.csvImport(filename: filename02)

        // :!!!: check new content length & values
        let trackersPass02 = realmDBV01.getDailyTrackers()
        XCTAssert(trackersPass02.count == 1, "incorrect number of imported legacy trackers")
        XCTAssert(
            trackersPass02[0].itemsDict[.dozeBeans]!.count == 3,
            ""
        )
        
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

    //func testPerformance() {
    //    // Performance test case.
    //    measure {
    //        // Put the code you want to measure the time of here.
    //    }
    //}

}
