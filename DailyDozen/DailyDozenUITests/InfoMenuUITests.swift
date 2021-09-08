//
//  InfoMenuUITests.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

class InfoMenuUITests: XCTestCase {
    // --- All Tests ---
    var scrollHelper = ScrollHelper.shared
    var snapHelper = SnapHelper.shared
    let urlHelper = UrlHelper.shared
    // 
    let infoList = ["info_item_videos_access", "info_item_how_not_to_die_access", "info_item_how_not_to_die_cookbook_access", "info_item_how_not_to_diet_access", "info_item_challenge_access", "info_item_donate_access", "info_item_subscribe_access", "info_item_open_source_access", "info_item_about_access"]
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
    
    func testInfoMenu() {
        let url = urlHelper.dirTopic("InfoMenu")
        let navtabBar: XCUIElement = app.tabBars["navtab_access"]
        navtabBar.buttons["navtab_info_access"].tap()
        
        // Screenshot: Info Screen
        scrollAndSnapshot(name: "InfoMenu", url: url)
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
        urlHelper.writeScreenshot(screenshot, dir: url, name: "\(name)_\(pageIdx).png")
        while isLastCellHittable() == false {
            pageIdx += 1
            scrollWindowFromBottonToTop()
            screenshot = app.screenshot()
            urlHelper.writeScreenshot(screenshot, dir: url, name: "\(name)_\(pageIdx).png")
        }
        return pageIdx + 1 // page count
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
    
}
