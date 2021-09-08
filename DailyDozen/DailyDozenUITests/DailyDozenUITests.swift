//
//  DailyDozenUITests.swift
//  DailyDozenUITests
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//
// swiftlint: disable type_body_length
// swiftlint: disable file_length

import XCTest

class DailyDozenUITests: XCTestCase {
    // all tests
    var scrollHelper = ScrollHelper.shared
    var snapHelper = SnapHelper.shared
    let urlHelper = UrlHelper.shared
    
    // each test
    var app: XCUIApplication!

    /// Called before each test method invocation
    override func setUp() {        
        continueAfterFailure = false
        app = XCUIApplication()
        
        //app.launchArguments = [
        //        "-inUITest",
        //        "-AppleLanguages",
        //        "(pl)",
        //        "-AppleLocale",
        //        "pl_PL"
        //    ]
        
        app.launch()
        snapHelper.setup(app: app)
    }
    
    /// Called after each test method invocation
    override func tearDown() { /* not used */ }
    
    func snapUtilities() {
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
        urlHelper.writeScreenshot(screenshot, dir: url, name: "Utilities")
    }
    
    // MARK: - Input Actions

    func toggleDozeCheckbox(row: XCUIElement, boundedBy: Int) {
        row.children(matching: .button)
            .matching(identifier: "doze_entry_checkbox_access")
            .element(boundBy: boundedBy).tap()
    }
    
    // MARK: - Scroll Actions
    
    func isLastCellHittable() -> Bool {
        let cellList = app.cells.allElementsBoundByIndex
        if let lastCell = cellList.last {
            return lastCell.isHittable
        }
        fatalError("isLastCellHittable() cells not found")
    }
    
    /// returns page count
    @discardableResult
    func scrollAndSnapshot(name: String, url: URL) -> Int {
        var pageIdx = 0
        var screenshot: XCUIScreenshot = app.screenshot()
        urlHelper.writeScreenshot(screenshot, dir: url, name: "\(name)_\(pageIdx)")
        while isLastCellHittable() == false {
            pageIdx += 1
            scrollWindowFromBottonToTop()
            screenshot = app.screenshot()
            urlHelper.writeScreenshot(screenshot, dir: url, name: "\(name)_\(pageIdx)")
        }
        return pageIdx + 1 // page count
    }

    /// returns page count
    @discardableResult
    func scrollAndSnapshotCells(name: String, url: URL) -> Int {
        var pageIdx = 0
        var screenshot: XCUIScreenshot = app.screenshot()
        urlHelper.writeScreenshot(screenshot, dir: url, name: "\(name)_\(pageIdx)")
        while isLastCellHittable() == false {
            pageIdx += 1
            scrollWindowFromBottonToTop()
            screenshot = app.screenshot()
            urlHelper.writeScreenshot(screenshot, dir: url, name: "\(name)_\(pageIdx)")
        }
        return pageIdx + 1 // page count
    }
    
    func scrollSnapAll(topic: String, max: Int = 10) {
        let url = urlHelper.dirTopic(topic)
        var count = 0
        
        let snap = app.screenshot()
        let name = "\(topic)@\(count)"
        urlHelper.writeScreenshot(snap, dir: url, name: name)
        
        while scrollOneSetUp() {
            count += 1
            if count >= max { return }

            let snap = app.screenshot()
            let name = "\(topic)@\(count)"
            urlHelper.writeScreenshot(snap, dir: url, name: name)
        }
    }
    
    var scrollCount = 0
    
    @discardableResult
    func scrollOneSetUp() -> Bool {
        let cellList: [XCUIElement] = app.cells.allElementsBoundByIndex
        var firstCell: XCUIElement! = nil
        var lastCell: XCUIElement! = nil                
        
        if let endCell = cellList.last, endCell.isHittable {
             return false // no more to scroll
        }
        
        // find first and last hittable cell
        for idx in cellList.startIndex ..< cellList.endIndex {
            let cell = cellList[idx]
            if cell.isHittable {
                if firstCell == nil {
                    firstCell = cell
                } else {
                    lastCell = cell
                }
            }
        }
        
        if firstCell == nil || lastCell == nil {
            return false
        }
        
        let midpoint = CGVector(dx: 0.5, dy: 0.5)
        let firstCoord = firstCell.coordinate(withNormalizedOffset: midpoint)
        let lastCoord = lastCell.coordinate(withNormalizedOffset: midpoint)
        
        snapHelper.logScreen(
            cellList: [firstCell, lastCell], 
            coordinateList: [firstCoord, lastCoord], 
            name: "log\(scrollCount)_A.png", 
            text: scrollHelper.getAccessTree(withFrames: true)
        )
        
        lastCoord.press(
            forDuration: 0.1,        // seconds 
            thenDragTo: firstCoord, 
            withVelocity: .slow,     // XCUIGestureVelocity(pixels_per_sec)  
            thenHoldForDuration: 0.1 // seconds
        )

        snapHelper.logScreen(
            cellList: [], 
            coordinateList: [], 
            name: "log\(scrollCount)_B.png"
        )
        scrollCount += 1
        return true
    }
    
    func scrollWindowFromBottonToTop(times: Int = 1) {
        let mainWindow: XCUIElement = app.windows.firstMatch
        let topScreenPoint = mainWindow
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let bottomScreenPoint = mainWindow
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.90))
        for _ in 0 ..< times {
            //bottomScreenPoint.press(forDuration: 0, thenDragTo: topScreenPoint)
            bottomScreenPoint.press(forDuration: 0, thenDragTo: topScreenPoint, withVelocity: XCUIGestureVelocity.slow, thenHoldForDuration: 0.1)
        }
    }
    
    func scrollWindowFromTopToBottomUp(times: Int = 1) {
        let mainWindow = app.windows.firstMatch
        let topScreenPoint = mainWindow
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let bottomScreenPoint = mainWindow
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.90))
        for _ in 0 ..< times {
            topScreenPoint.press(forDuration: 0, thenDragTo: bottomScreenPoint)
        }
    }  
    
}

// :NYI: doze.backBtn.access --> doze_backBtn_access

// --- Screenshot providers
// let screenshot = app.screenshot() // current device screen
// let xcuiScreen: XCUIScreen = XCUIScreen.main
// let screenshot = xcuiScreen.screenshot()
// let mainWindow: XCUIElement = XCUIApplication().windows.firstMatch
// let screenshot mainWindow.screenshot()
// let screenshot = app.screenshot() // current device screen
// 

// :NYI: first launch
//app.alerts["“DailyDozen” Would Like to Send You Notifications"].scrollViews.otherElements.buttons["Allow"].tap()
//app/*@START_MENU_TOKEN@*/.staticTexts["Codzienny Tuzin + 21 Adaptacji"]/*[[".buttons[\"Codzienny Tuzin + 21 Adaptacji\"].staticTexts[\"Codzienny Tuzin + 21 Adaptacji\"]",".staticTexts[\"Codzienny Tuzin + 21 Adaptacji\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

//let tablesQuery = app.tables
//tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Turn All Categories Off"]/*[[".cells.staticTexts[\"Turn All Categories Off\"]",".staticTexts[\"Turn All Categories Off\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//app.navigationBars["Health Access"].buttons["Allow"].tap()
