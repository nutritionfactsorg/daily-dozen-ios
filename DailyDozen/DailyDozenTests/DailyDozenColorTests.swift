//
//  DailyDozenColorTests.swift
//  DailyDozenTests
//
//  Created by mc on 2024.07.27.
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import XCTest
@testable import DailyDozen // module
import SwiftUI

final class DailyDozenColorTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // Color.RGBColorSpace.sRGB
        // Color.RGBColorSpace.sRGBLinear
        // Color(Color.RGBColorSpace, …)
        
        print("### :BEGIN: Color Test")
        print("r: 235/255   \(235/255)")
        print("r: 235/255.0 \(235/255.0)")
        print("g: 193/255.0 \(193/255.0)")
        print("b:  64/255.0 \( 64/255.0)")
        
        print("### SwiftUI Color Test")
        let allCheckedColor: Color = ColorGuide.calendarAllChecked
        print("\(allCheckedColor)\n")
        print("\(allCheckedColor.cgColor!)\n")
        
        //let color = Color(uiColor: ColorManager.style.calendarAllChecked)
        //print(color)
        
        print("### UIKit UIColor Test")
        let allCheckedUIColor: UIColor = ColorManager.style.calendarAllChecked
        print("\(allCheckedUIColor)\n")
        print("\(allCheckedUIColor.cgColor)\n")
        
        //let uicolor = UIColor(allCheckedColor)
        //print(uicolor)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
