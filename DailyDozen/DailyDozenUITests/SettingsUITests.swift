//
//  SettingsUITests.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

class SettingsUITests: XCTestCase {
    // --- All Tests ---
    var scrollHelper = ScrollHelper.shared
    var snapHelper = SnapHelper.shared
    let urlHelper = UrlHelper.shared
    // all tests
    let scrollPage = ["A", "B", "C", "D", "E", "F", "G"]
    var logScrollCount = 0

    // --- Each Test ---
    var app: XCUIApplication!

    /// Called before each test method invocation
    override func setUpWithError() throws {
        // Usually best to stop UI tests when a failure occurs.
        continueAfterFailure = false
        
        //app.launchArguments = [
        //        "-inUITest",
        //        "-AppleLanguages",
        //        "(pl)",
        //        "-AppleLocale",
        //        "pl_PL"
        //    ]
        
        app = XCUIApplication()
        app.launch()

        scrollHelper.setApp(app)
        snapHelper.setup(app: app)
    }
    
    /// Called after each test method invocation
    override func tearDownWithError() throws { /* not used */ }
    
    func testSettingsView() throws {
        let url = urlHelper.dirTopic("Preferences")
        let navtabBar: XCUIElement = app.tabBars["navtab_access"]
        navtabBar.buttons["navtab_preferences_access"].tap()

        // Screenshot: Preferences Screen
        var screenshot: XCUIScreenshot = app.screenshot()
        urlHelper.writeScreenshot(screenshot, dir: url, name: "Preferences.png")

        app.cells.matching(identifier: "reminder_cell_access").element.tap()
        
        guard
            app.switches
                .matching(identifier: "reminder_settings_enable_access")
                .element.waitForExistence(timeout: 5.0)
        else {
            scrollHelper.printAccessTree()
            fatalError("reminder_settings_enable_access does not exist")
        }
        
        // Screenshot: Utilities Screen
        screenshot = app.screenshot()
        urlHelper.writeScreenshot(screenshot, dir: url, name: "Reminder.png")
    }
    
    func testUtilitiesView() {
        let url = urlHelper.dirTopic("Utilities")
        let navtabBar: XCUIElement = app.tabBars["navtab_access"]
        navtabBar.buttons["navtab_preferences_access"].tap()

        app.buttons.matching(identifier: "setting_util_advanced_access").element.tap()
        
        guard
            app.buttons
                .matching(identifier: "util_db_btn_export_access")
                .element.waitForExistence(timeout: 5.0)
        else {
            scrollHelper.printAccessTree()
            fatalError("util_db_btn_export_access does not exist")
        }
        
        // Screenshot: Utilities Screen
        let screenshot: XCUIScreenshot = app.screenshot()
        urlHelper.writeScreenshot(screenshot, dir: url, name: "Utilities.png")
    }

}
