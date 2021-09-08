//
//  MapHelperTests.swift
//  DailyDozenUITests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import XCTest

class MapHelperTests: XCTestCase {
    var mapHelper: MapHelper!
    var list: [(rect: CGRect, name: String)]!
    
    override func setUpWithError() throws {
        mapHelper = MapHelper()
        list = [(rect: CGRect, name: String)]()
    }
    
    override func tearDownWithError() throws {         
        let svg = mapHelper.getSvg()
        print(svg)
    }

    func testMapHelper() throws {
        // NavigationBar {{0.0, 20.0}, {320.0, 44.0}}, identifier: 'Docena Diaria'
        var r = CGRect(x: 0, y: 20, width: 320, height: 44)
        mapHelper.addRect(r, name: "NavBar")

        // Image {{0.0, 0.0}, {320.0, 244.0}}, identifier: 'detail_dozeBeans'
        r = CGRect(x: 0, y: 0, width: 320, height: 244)
        mapHelper.addRect(r, name: "Image")
        
        // Cell {{0.0, 294.0}, {320.0, 40.5}} label: '60 g de hummus o untable de legumbres'
        r = CGRect(x: 0, y: 294, width: 320, height: 40.5)
        mapHelper.addRect(r, name: "Hummus")

        // Cell {{0.0, 482.0}, {320.0, 40.5}} label: 'Frijoles negros'
        r = CGRect(x: 0, y: 482, width: 320, height: 40.5)
        mapHelper.addRect(r, name: "Frijoles")

        // TabBar {{0.0, 519.0}, {320.0, 49.0}}, identifier: 'navtab_access'
        r = CGRect(x: 0, y: 519, width: 320, height: 49)
        mapHelper.addRect(r, name: "navtab_access")
    }

    func testDozeExercise01() throws {
        // TabBar {{0.0, 519.0}, {320.0, 49.0}}, identifier: 'navtab_access'
        list.append((rect((0.0, 519.0), (320.0, 49.0)), "navtab_access"))

    }

    /// (origin: (x, y), size: (width, height))
    private func rect(_ origin: (Double, Double), _ size: (Double, Double)) -> CGRect {
        return CGRect(x: origin.0, y: origin.1, width: size.0, height: size.1)
    }

    /// (origin: (x, y), size: (width, height))
    private func rect(_ origin: (Int, Int), _ size: (Int, Int)) -> CGRect {
        return CGRect(x: origin.0, y: origin.1, width: size.0, height: size.1)
    }
}
