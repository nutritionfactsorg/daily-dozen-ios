//
//  XCTestCase.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

/// awaitArrival(element: app.staticTexts["Some content"], timeout: 5)
extension XCTestCase {
    func awaitArrival(element: XCUIElement, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "exists == 1")

        // Test runner will continously evalulate the predicate, 
        // and wait until it matches.
        expectation(for: predicate, evaluatedWith: element) 
        waitForExpectations(timeout: timeout)
    }

    func awaitDeparture(element: XCUIElement, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "exists == 0")

        // Test runner will continously evalulate the predicate, 
        // and wait until it matches.
        expectation(for: predicate, evaluatedWith: element) 
        waitForExpectations(timeout: timeout)
    }
}
