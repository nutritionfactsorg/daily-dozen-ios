//
//  UrlHelperTests.swift
//  DailyDozenUITests
//
//  Created by marc on 2021.08.29.
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

class UrlHelperTests: XCTestCase {
    // --- All Tests ---
    let urlHelper = UrlHelper.shared

    override func setUpWithError() throws { /* not used */ }
    override func tearDownWithError() throws { /* not used */ }

    func testUrlHelper() throws {
        print(urlHelper.infoAppLaunchEnvironment)
        print(urlHelper.infoDevice)
        print(urlHelper.infoLocale)
        print(urlHelper.infoLocaleIdentifier)
        print(urlHelper.infoProcessArguments)
        print(urlHelper.infoProcessEnvironment)
        // print(urlHelper.dirTopic("HelperTestTopicA"))
        // print(helper.dirTopic("HelperTestTopicB"))
    }

}
