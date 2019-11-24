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
    
    // World Pasta Day: Oct 25, 1995
    let date1995Pasta = Date.init(datestampKey: "19951025")!
    // International Carrot Day: Apr  4, 2003
    let date2003Carrot = Date.init(datestampKey: "20030404")!
    // World Porridge Day: Oct 10, 2009 (initial celebration date)
    let date2009Porridge = Date.init(datestampKey: "20091010")!
    // Nationale Kale Day: Oct  2, 2013
    let date2013Kale = Date.init(datestampKey: "20131002")!

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

    func testB() {
        print("\n::: testB :::")
        let date = date2009Porridge
        
        let realmOld = RealmProviderLegacy()
        let dozeA = realmOld.getDoze(for: date)
        let dozeAItems: List<Item> = dozeA.items
        realmOld.saveStates([true, true, true], with: dozeAItems[0].id)
        
        let realmNew = RealmProvider()
        _ = realmNew.getDailyTracker(date: date)
        realmNew.saveCount(1, date: date, countType: DataCountType.dozeBeans)
        
        let trackerRead = realmNew.getDailyTracker(date: date)
        XCTAssertEqual(trackerRead.itemsDict.count, DataCountType.allCases.count)
        
        print(":::::::::::::\n")
    }
    
    var workingUrl: URL {
        let fm = FileManager.default
        let urlList = fm.urls(for: .documentDirectory, in: .userDomainMask)
        return urlList[0]
    }
    
    func testC() {
        print("\n::: testC :::")
        // Oct  2, 2013 Nationale Kale Day
        let date00 = date2013Kale

        let realmMngrOld = RealmManagerLegacy(workingDirUrl: workingUrl)
        let realmDbOld = realmMngrOld.realmDb
        realmDbOld.deleteAll()
        let realmMngrNew = RealmManager(workingDirUrl: workingUrl)
        let realmDbNew = realmMngrNew.realmDb
        realmDbNew.deleteAll()

        // Add known content to legacy
        let dozeA = realmDbOld.getDoze(for: date00)
        realmDbOld.saveStates([true, false, true], with: dozeA.items[0].id) // Beans
        
        // 01: export legacy file, then import to new database
        let filename01 = realmMngrOld.csvExport()
        realmMngrNew.csvImport(filename: filename01)

        // Check new content length & values
        let trackersPass01 = realmDbNew.getDailyTrackers()
        XCTAssert(trackersPass01.count == 1, "incorrect number of imported legacy trackers")
        XCTAssert(
            trackersPass01[0].itemsDict[.dozeBeans]!.count == 2,
            ""
        )
        
        // Change a value
        realmDbNew.saveCount(3, date: date00, countType: .dozeBeans)
        
        // 02: export new database format
        let filename02 = realmMngrNew.csvExport()
        realmMngrNew.realmDb.deleteAll()
        realmMngrNew.csvImport(filename: filename02)

        // :!!!: check new content length & values
        let trackersPass02 = realmDbNew.getDailyTrackers()
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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
