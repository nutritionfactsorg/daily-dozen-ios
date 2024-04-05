//
//  NumberLocalizationTests.swift
//  DailyDozenTests
//
//  Created by mc on 2024.04.03.
//  Copyright © 2024 Nutritionfacts.org. All rights reserved.
//

import XCTest

// Note: Direct use of NSNumber(integerLiteral: integer) causes a compiler warning.
//
// Compiler Protocol Init Violation: 
// Initializers declared in compiler protocol ExpressibleByIntegerLiteral
//     shouldn't be called directly (compiler_protocol_init)
//     let number = NSNumber(integerLiteral: integer)

/// Used to check localized number formatting.
final class NumberLocalizationTests: XCTestCase {
    
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    /// Checks completed count localization.
    func testCheckboxCountNumberLocalization() throws {
        print(":CHECK: Checkbox Count Number Localization")
        let intCompleted = 13
        let intTotal = 27
        let langRegionList = [
            "fa_IR", // Language: Persian, Region: Iran
            "fa", // Language: Persian
            "he", // Language: Hebrew
            "he_IL", // Language: Hebrew, Region: Isreal
            "zh-Hans", // Language: Chinese Simplified
            "zh-Hant", // Language: Chinese Traditional
            "ru_Ru" // Language: Russian, Region: Russia
        ]
        let nf = NumberFormatter()
        
        for identifier in langRegionList {
            print("LANGUAGE_REGION: \(identifier)")
            nf.locale = Locale(identifier: identifier)
            if let strCompleted = nf.string(from: intCompleted as NSNumber),
               let strTotal = nf.string(from: intTotal as NSNumber) {
                print("\(strCompleted)/\(strTotal) localized")
            } else {
                print("\(intCompleted)/\(intTotal) not-localize")
            }
        }
    }
    
    /// Checks completed count localization.
    func testStreakNumberLocalization() throws {
        print(":CHECK: Checkbox Count Number Localization")
        let streak = 8
        let streakDaysFormatList = [
            ["fa_IR", "%d روز"], 
            ["fa", "%d روز"], 
            ["he", "%d ימים"], 
            ["he_IL", "%d ימים"], 
            ["zh-Hant", "%d 天"], 
            ["zh-Hans", "%d 天"], 
            ["ru_Ru", "%d дни"]
        ]
        let nf = NumberFormatter()
        
        for streakDaysFormat in streakDaysFormatList {
            let streakLangCode = streakDaysFormat[0]
            let streakFormat = streakDaysFormat[1]
            print("LANGUAGE_REGION: \(streakLangCode)")
            nf.locale = Locale(identifier: streakLangCode)
            if let daysStr = nf.string(from: streak as NSNumber) {
                let str = streakFormat.replacingOccurrences(of: "%d", with: daysStr)
                print(str)
            } else {
                print(String(format: streakFormat, streak))
            }
        }
    }
    
}
