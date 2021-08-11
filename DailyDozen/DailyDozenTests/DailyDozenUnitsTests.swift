//
//  DailyDozenUnitsTests.swift
//  DailyDozenTests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import Foundation

import XCTest
@testable import DailyDozen // module

class DailyDozenUnitsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
        // This method is called after the invocation of each test method in the class.
    }

    func testWeightConversions() throws {
        print("\n::: testWeightConversions :::")
        let currentLocale = Locale.current
        print("currentLocal=\(currentLocale.identifier)")
        let decimalSeparator = currentLocale.decimalSeparator!
        print("decimalSeparator = \(decimalSeparator)")

        let kg52o1Str = "52\(decimalSeparator)1"
        if let lbsStr = UnitsUtility.convertKgToLbs(kg52o1Str) {
            print(" \(kg52o1Str) kg  --> \(lbsStr) lbs")
            XCTAssert(lbsStr == "114\(decimalSeparator)9")
        } else {
            XCTFail("UnitsUtility.convertKgToLbs(…) returned nil")
        }
        
        let lbs128o8Str = "128\(decimalSeparator)9"
        if let kgStr = UnitsUtility.convertLbsToKg(lbs128o8Str) {
            print("\(lbs128o8Str) lbs -->  \(kgStr) kg")
            XCTAssert(kgStr == "58\(decimalSeparator)5")
        } else {
            XCTFail("UnitsUtility.convertLbsToKg(…) returned nil")
        }
    }

    func testWeightNormalization() throws {
        print("\n::: testWeightNormalization :::")
        let currentLocale = Locale.current
        print("currentLocal=\(currentLocale.identifier)")
        let decimalSeparator = currentLocale.decimalSeparator!
        print("decimalSeparator = \(decimalSeparator)")
        
        let w120o2LbsText = "120\(decimalSeparator)2"
        if let normalizedA = UnitsUtility.normalizedKgWeight(
            from: w120o2LbsText,
            fromUnits: .imperial
        ) {
            print(" '\(w120o2LbsText)' lbs --> \(normalizedA) kg (normalized Double)")
        } else {
            XCTFail("Failed: normalizedKgWeight \(w120o2LbsText)")
        }
        
        let w50o8KgText = "50\(decimalSeparator)8"
        if let normalizedB = UnitsUtility.normalizedKgWeight(
            from: w50o8KgText,
            fromUnits: .metric
        ) {
            print("  '\(w50o8KgText)' kg  --> \(normalizedB) kg (normalized Double)")
        } else {
            XCTFail("Failed: normalizedKgWeight \(w50o8KgText)")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
