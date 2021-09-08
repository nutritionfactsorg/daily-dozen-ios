//
//  TweakUITests.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

class TweakUITests: XCTestCase {
    // --- All Tests ---
    var scrollHelper = ScrollHelper.shared
    var snapHelper = SnapHelper.shared
    let urlHelper = UrlHelper.shared
    //
    let tweakList = ["tweakMealWater", "tweakMealNegCal", "tweakMealVinegar", "tweakMealUndistracted", "tweakMeal20Minutes", "tweakDailyBlackCumin", "tweakDailyGarlic", "tweakDailyGinger", "tweakDailyNutriYeast", "tweakDailyCumin", "tweakDailyGreenTea", "tweakDailyHydrate", "tweakDailyDeflourDiet", "tweakDailyFrontLoad", "tweakDailyTimeRestrict", "tweakExerciseTiming", "tweakWeightTwice", "tweakCompleteIntentions", "tweakNightlyFast", "tweakNightlySleep", "tweakNightlyTrendelenbrug"]
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

    func testSnapTweakEntryDetail() {
        let url = urlHelper.dirTopic("TweakEntry")
        let navtabBar: XCUIElement = app.tabBars["navtab_access"]
        navtabBar.buttons["navtab_tweak_access"].tap()
                
        // ----- Table Element Only -----
        
        //let tables: XCUIElementQuery = app.tables
        //screenshot = tables.firstMatch.screenshot()
        //urlHelper.writeScreenshot(screenshot, dir: url, name: "TweakEntryTables")
        
        // ----- One Example Calendar Page -----
        
        // ----- More Info Pages -----
        
        var cellElement: XCUIElement!
        var pageIdx = 0
        for item in tweakList {
            let id = "\(item)_access"
            cellElement = app.cells.matching(identifier: id).element
            
            if cellElement.exists == false || cellElement.isHittable == false {
                // Screenshot: Tweak Entry Screen
                let snap = app.screenshot()
                let name = "TweakEntry_\(scrollPage[pageIdx]).png"
                urlHelper.writeScreenshot(snap, dir: url, name: name)
                scrollOneSetUp()
                pageIdx += 1
            }

            if item != "otherVitaminB12" {
                // -- goto more info details page
                cellElement.buttons
                    .matching(identifier: "tweak_entry_info_access")
                    .element
                    .tap()
                scrollSnapAll(topic: item) 
                
                // return to main entry page
                app.navigationBars.firstMatch
                    .buttons.firstMatch
                    .tap()            
            }
        }
        // Screenshot: Tweak Entry Screen (last page)
        let snap = app.screenshot()
        let name = "TweakEntry_\(scrollPage[pageIdx]).png"
        urlHelper.writeScreenshot(snap, dir: url, name: name)
    }
    
    func scrollSnapAll(topic: String, max: Int = 10) {
        var count = 0
        let url = urlHelper.dirTopic(topic)
        
        awaitArrival(element: app.windows.firstMatch, timeout: 2.0)
        
        //_ = app.buttons
        //    .matching(identifier: "tweak_stats_history_access")
        //    .element
        //    .waitForExistence(timeout: 1)
        
        // :DEBUG:TRANSITION:        
        //let a = scrollHelper.getAccessTree(withFrames: true)
        //let aFilename = "\(topic)@\(count).txt"
        //try? a.write(
        //    to: url.appendingPathComponent(aFilename, isDirectory: false), 
        //    atomically: false, encoding: .utf8)
        
        let snap = app.screenshot()
        let name = "\(topic)@\(count).png"
        urlHelper.writeScreenshot(snap, dir: url, name: name)
        
        while scrollOneSetUp() {
            count += 1
            if count >= max { return }

            // :DEBUG:TRANSITION:
            let a = scrollHelper.getAccessTree(withFrames: true) 
            try? a.write(
                to: url.appendingPathComponent("\(topic)@\(count).txt", isDirectory: false), 
                atomically: false, encoding: .utf8)

            let snap = app.screenshot()
            let name = "\(topic)@\(count).png"
            urlHelper.writeScreenshot(snap, dir: url, name: name)
        }
    }
    
    func checkCellFirst(_ first: XCUIElement) -> Bool {
        if app.images.count > 0 { // Detail view has an image
            return checkDetailCellFirst(first)
        } else {
            return checkEntryCellFirst(first)
        }
    }

    func checkDetailCellFirst(_ first: XCUIElement) -> Bool {
        let frameCellFirst = first.frame
        let frameImage = app.images.firstMatch.frame
        
        var frameActivity: CGRect?
        if app.staticTexts
            .matching(identifier: "tweak_detail_section_activity_access")
            .firstMatch.exists {
            frameActivity = app.staticTexts.matching(identifier: "tweak_detail_section_activity_access").firstMatch.frame
        }
        
        var frameDescription: CGRect?
        if app.staticTexts
            .matching(identifier: "tweak_detail_section_description_access")
            .firstMatch.exists {
            frameDescription = app.staticTexts.matching(identifier: "tweak_detail_section_description_access").firstMatch.frame
        }

        if CGUtil.isCenter(frameCellFirst, below: frameImage) &&
            (frameActivity == nil || CGUtil.isCenter(frameCellFirst, outside: frameActivity!)) &&
            (frameDescription == nil || CGUtil.isCenter(frameCellFirst, outside: frameDescription!)) {
            return true
        }
        return false
    }

    func checkEntryCellFirst(_ first: XCUIElement) -> Bool {
        let frameCellFirst = first.frame
        let frameBtnStats = app.buttons.matching(identifier: "tweak_stats_history_access").element.frame
        let margin = CGFloat(5.0)
        return frameCellFirst.midY > frameBtnStats.maxY + margin
    }
    
    func checkCellLast(_ last: XCUIElement) -> Bool {
        let frameCellLast = last.frame
        let frameTabBar = app.tabBars.firstMatch.frame
        if CGUtil.isCenter(frameCellLast, above: frameTabBar) {
            return true
        }
        return false
    }

    func checkDetailCellsInfo(first: XCUIElement, last: XCUIElement) -> String {
        let frameCellFirst = first.frame
        let frameCellLast = last.frame
        let frameImage = app.images.firstMatch.frame
        let frameTabBar = app.tabBars.firstMatch.frame

        // Check First Cell
        let isOkFirst = checkCellFirst(first)
        // Check Last Cell
        let isOkLast = checkCellLast(last)
        
        var str = """
        
           frameCellFirst = \(frameCellFirst.debugDescription)
                isOkFirst : \(isOkFirst)
            frameCellLast = \(frameCellLast.debugDescription)
                 isOkLast : \(isOkLast)
         
               frameImage = \(frameImage.debugDescription)
              frameTabBar = \(frameTabBar.debugDescription)\n
        """
        
        if app.staticTexts
            .matching(identifier: "tweak_detail_section_activity_access")
            .firstMatch.exists {
            let frameSizes = app.staticTexts.matching(identifier: "tweak_detail_section_activity_access").firstMatch.frame
            str.append("       frameSizes = \(frameSizes.debugDescription)\n")
        } else {
            str.append("       frameSizes = NOT_IN_SCOPE\n")
        }
        
        if app.staticTexts
            .matching(identifier: "tweak_detail_section_description_access")
            .firstMatch.exists {
            let frameTypes = app.staticTexts.matching(identifier: "tweak_detail_section_description_access").firstMatch.frame
            str.append("       frameTypes = \(frameTypes.debugDescription)\n")
        } else {
            str.append("       frameTypes = NOT_IN_SCOPE\n")
        }
        str.append("\n")
        return str
    }
    
    func checkEntryCellsInfo(first: XCUIElement, last: XCUIElement) -> String {
        let frameCellFirst = first.frame
        let frameCellLast = last.frame
        
        let frameTabBar = app.tabBars.firstMatch.frame
        
        // Check First Cell
        let isOkFirst = checkCellFirst(first)
        // Check Last Cell
        let isOkLast = checkCellLast(last)
        
        return """
        
           frameCellFirst = \(frameCellFirst.debugDescription)
                isOkFirst : \(isOkFirst)
            frameCellLast = \(frameCellLast.debugDescription)
                 isOkLast : \(isOkLast)
        
              frameTabBar = \(frameTabBar.debugDescription)
        
        """
    }
    
    func checkCellsInfo(first: XCUIElement, last: XCUIElement) -> String {
        if app.images.count > 0 { // Detail view has an image
            return checkDetailCellsInfo(first: first, last: last)
        } else {
            return checkEntryCellsInfo(first: first, last: last)
        }
    }
    
    @discardableResult
    func scrollOneSetUp() -> Bool {
        let cellList: [XCUIElement] = app.cells.allElementsBoundByIndex
        var cellFirst: XCUIElement! = nil
        var cellLast: XCUIElement! = nil                
        
        if let endCell = cellList.last, endCell.isHittable {
             return false // no more to scroll
        }
        
        // find first and last hittable cell
        for idx in cellList.startIndex ..< cellList.endIndex {
            let cell = cellList[idx]
            if cell.isHittable {
                if cellFirst == nil && checkCellFirst(cell) {
                    cellFirst = cell
                } else {
                    if checkCellLast(cell) {
                        cellLast = cell
                    }
                }
            }
        }
        
        if cellFirst == nil || cellLast == nil {
            return false
        }
                
        let midpoint = CGVector(dx: 0.5, dy: 0.5)
        let firstCoord = cellFirst.coordinate(withNormalizedOffset: midpoint)
        let lastCoord = cellLast.coordinate(withNormalizedOffset: midpoint)
        
        let textTree = scrollHelper.getAccessTree(withFrames: true)
        let textFrames = checkCellsInfo(first: cellFirst, last: cellLast)
        snapHelper.logScreen(
            cellList: [cellFirst, cellLast], 
            coordinateList: [firstCoord, lastCoord], 
            name: "log\(logScrollCount)_A.png", 
            text: textFrames + textTree
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
            name: "log\(logScrollCount)_B.png"
        )
        logScrollCount += 1
        return true
    }
}
