//
//  SnapHelperTests.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

class SnapHelperTests: XCTestCase {
    // all tests
    let urlHelper = UrlHelper.shared
    // each test
    var app: XCUIApplication!
   
    /// Called before each test method invocation
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()        
        app.launch()
    }
    
    /// Called after each test method invocation
    override func tearDownWithError() throws { /* not used */ }

    func testSizingsCell() {
        let cell: XCUIElement = app.cells.firstMatch
        
        let cellScreenshot = cell.screenshot()
        let cellScreenshotSize = cellScreenshot.image.size
        
        let cellFrame = cell.frame
        let cellFrameOrigin = cellFrame.origin
        let cellFrameSize = cellFrame.size
        
        let p00 = cell.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)).screenPoint
        let p05 = cell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).screenPoint
        let p10 = cell.coordinate(withNormalizedOffset: CGVector(dx: 1.0, dy: 1.0)).screenPoint
        
        //"dozeBeans_access" at {(0.0, 158.1), (320.0, 90.0)}[0.00, 0.00]
        //"dozeBeans_access" at {(0.0, 158.1), (320.0, 90.0)}[0.50, 0.50]
        //"dozeBeans_access" at {(0.0, 158.1), (320.0, 90.0)}[1.00, 1.00]
        
        print("""
        ••••• •••••
                  cell frame {\(cellFrameOrigin), \(cellFrameSize)} 
        
            cell frame origin \(cellFrameOrigin)
                
              cell frame size \(cellFrameSize)
              cell image size \(cellScreenshotSize)
        
        cell screenPoint with [normalized offsets]
          offset: [0.0, 0.0]  point:   \(p00.debugDescription) origin, left-upper
          offset: [0.5, 0.5]  point: \(p05.debugDescription) midpoint
          offset: [1.0, 1.0]  point: \(p10.debugDescription) right-lower
        
        """)
        
        //••••• •••••
        //          cell frame {(0.0, 158.1), (320.0, 90.0)} 
        //
        //    cell frame origin (0.0, 158.1)
        //        
        //      cell frame size (320.0, 90.0)
        //      cell image size (640.0, 180.0)
        //
        //cell screenPoint with [normalized offsets]
        //  offset: [0.0, 0.0]  point:   (0.0, 158.1) origin, left-upper
        //  offset: [0.5, 0.5]  point: (160.0, 203.1) midpoint
        //  offset: [1.0, 1.0]  point: (320.0, 248.1) right-lower
    }
    
    func testSizingsWindow() {
        let window: XCUIElement = app.windows.firstMatch
        
        let windowScreenshot = window.screenshot()
        let windowScreenshotSize = windowScreenshot.image.size
        
        let windowFrameOrigin = window.frame.origin
        let windowFrameSize = window.frame.size
        
        let p00 = window.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)).screenPoint
        let p05 = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).screenPoint
        let p10 = window.coordinate(withNormalizedOffset: CGVector(dx: 1.0, dy: 1.0)).screenPoint
        
        //Window at {{0.0, 0.0}, {320.0, 568.0}}[0.00, 0.00]
        //Window at {{0.0, 0.0}, {320.0, 568.0}}[0.50, 0.50]
        //Window at {{0.0, 0.0}, {320.0, 568.0}}[1.00, 1.00]
        
        print("""
        ••••• •••••
          window frame origin \(windowFrameOrigin)
                
            window frame size \(windowFrameSize)
            window image size \(windowScreenshotSize)
        
        window screenPoint with [normalized offsets]
          offset: [0.0, 0.0]  point:   \(p00) origin, left-upper
          offset: [0.5, 0.5]  point: \(p05) midpoint
          offset: [1.0, 1.0]  point: \(p10) right-lower
        
        """)
        
        //••••• •••••
        //  window frame origin (0.0, 0.0)
        //        
        //    window frame size (320.0, 568.0)
        //    window image size (640.0, 1136.0)
        //
        //window screenPoint with [normalized offsets]
        //  offset: [0.0, 0.0]  point:   (0.0,   0.0) origin, left-upper
        //  offset: [0.5, 0.5]  point: (160.0, 284.0) midpoint
        //  offset: [1.0, 1.0]  point: (320.0, 568.0) right-lower
    }
    
    func testDrawTouchPoints() throws {
        let url = urlHelper.dirTopic("SnapHelperTests")
        print(url.path)

        let window: XCUIElement = app.windows.firstMatch
        let windowScreenshot = window.screenshot()
        
        let cellList = window.cells.allElementsBoundByIndex
        var drawAreas = [CGRect]()
        var drawPoints = [CGPoint]()
        for cell in cellList {
            if cell.exists && cell.isHittable {
                drawAreas.append(cell.frame)
                
                let midpoint = CGVector(dx: 0.5, dy: 0.5)
                let cellMidpoint = cell.coordinate(withNormalizedOffset: midpoint).screenPoint
                drawPoints.append(cellMidpoint)
            }
        }
        
        let snapHelper = SnapHelper.shared
        let markedPng = snapHelper
            .addMarkers(windowScreenshot, areas: drawAreas, points: drawPoints)
        urlHelper.writeScreenshot(data: markedPng, dir: url, name: "01.png")        
    }
    
}
