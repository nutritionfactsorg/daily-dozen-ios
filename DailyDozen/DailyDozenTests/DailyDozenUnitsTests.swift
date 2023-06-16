//
//  DailyDozenUnitsTests.swift
//  DailyDozenTests
//
//  Copyright © 2021 Nutritionfacts.org. All rights reserved.
//

import Foundation

import XCTest
@testable import DailyDozen // module

class DailyDozenUnitsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here.
        // This method is called after the invocation of each test method in the class.
    }
    
    func testWeightConversions() throws {
        print("\n::: testWeightConversions :::")
        let currentLocale = Locale.current
        print("currentLocal=\(currentLocale.identifier)")
        let decimalSeparator = currentLocale.decimalSeparator!
        print("decimalSeparator = \(decimalSeparator)")
        
        let kg52o1Str = "52\(decimalSeparator)1"
        if let lbsStr = UnitsUtility.convertKgToLbs(kg52o1Str) {
            print(" \(kg52o1Str) kg  --> \(lbsStr) lbs")
            XCTAssert(lbsStr == "114\(decimalSeparator)9")
        } else {
            XCTFail("UnitsUtility.convertKgToLbs(…) returned nil")
        }
        
        let lbs128o8Str = "128\(decimalSeparator)9"
        if let kgStr = UnitsUtility.convertLbsToKg(lbs128o8Str) {
            print("\(lbs128o8Str) lbs -->  \(kgStr) kg")
            XCTAssert(kgStr == "58\(decimalSeparator)5")
        } else {
            XCTFail("UnitsUtility.convertLbsToKg(…) returned nil")
        }
    }
    
    func testWeightNormalization() throws {
        print("\n::: testWeightNormalization :::")
        let currentLocale = Locale.current
        print("currentLocal=\(currentLocale.identifier)")
        let decimalSeparator = currentLocale.decimalSeparator!
        print("decimalSeparator = \(decimalSeparator)")
        
        let w120o2LbsText = "120\(decimalSeparator)2"
        if let normalizedA = UnitsUtility.normalizedKgWeight(
            from: w120o2LbsText,
            fromUnits: .imperial
        ) {
            print(" '\(w120o2LbsText)' lbs --> \(normalizedA) kg (normalized Double)")
        } else {
            XCTFail("Failed: normalizedKgWeight \(w120o2LbsText)")
        }
        
        let w50o8KgText = "50\(decimalSeparator)8"
        if let normalizedB = UnitsUtility.normalizedKgWeight(
            from: w50o8KgText,
            fromUnits: .metric
        ) {
            print("  '\(w50o8KgText)' kg  --> \(normalizedB) kg (normalized Double)")
        } else {
            XCTFail("Failed: normalizedKgWeight \(w50o8KgText)")
        }
    }
    
    let localizedLangcodes = ["bg", "ca", "cs", "de", "en", "es", "fr", "he", "it", "pl", "pt-BR", "pt-PT", "ro", "ru", "sk"]
    
    let localizedStringsKeys = ["faq_scaling_response", "faq_supplements_response"]
    
    func doLocalizedString(key: String, langcode: String) -> String? {
        let path = Bundle.main.path(forResource: langcode, ofType: "lproj")
        guard let path = path else { return nil }
        guard let languageBundle = Bundle(path: path) else { return nil }
        return languageBundle.localizedString(forKey: key, value: "", table: nil)
    }
    
    func doParseLinkedString(key: String, langcode: String) -> NSAttributedString {
        print("@ TEST: \(key) \(langcode)")
        guard let s = doLocalizedString(key: key, langcode: langcode), !s.isEmpty else {
            print("@ FAIL: \(key)•\(langcode) not found")
            return NSAttributedString()
        }
        
        let regex = "([^\\[]*)\\[([^\\[]*)\\]\\(([^\\)]*)\\)(.*)"
        let parts = s.regexSearch(pattern: regex)
        guard parts.count == 5 else { 
            print("@ FAIL: \(key)•\(langcode) regex failed")
            return NSAttributedString(string: s)
        }
        let pre = parts[1]
        let linkname = parts[2]
        let linkurl = parts[3]
        let post = parts[4]
        
        let atStr = NSMutableAttributedString(string: pre, attributes: [:])
        let atLink = NSMutableAttributedString(string: linkname, attributes: [NSAttributedString.Key.link: linkurl])
        atStr.append(atLink)
        let atPost = NSMutableAttributedString(string: post, attributes: [:])
        atStr.append(atPost)

        print("@ PASS: \(key)•\(langcode)•\(linkname)•\(linkurl)")
        return atStr
    }
    
    func testHyperlinkRegex() {
        let s = "preamble [linkname](http://host/path) postscript"
        let regex = "([^\\[]*)\\[([^\\[]*)\\]\\(([^\\)]*)\\)(.*)"
        let parts = s.regexSearch(pattern: regex)
        print(":PART: \(parts)")
        
        guard parts.count == 5 else {
            print(":FAIL: testHyperlinkRegex count=\(parts.count)")
            return
        }
        
        let pre = parts[1]
        let linkname = parts[2]
        let linkpath = parts[3]
        guard let linkurl = URL(string: linkpath) else {
            print(":PASS: testHyperlinkRegex invalid linkpath=\(linkpath)")
            return
        }
        let post = parts[4]
        
        let atStr = NSMutableAttributedString(string: pre, attributes: [:])
        let atLink = NSMutableAttributedString(string: linkname, attributes: [NSAttributedString.Key.link: linkurl])
        atStr.append(atLink)
        let atPost = NSMutableAttributedString(string: post, attributes: [:])
        atStr.append(atPost)
        
        print(":PASS: testHyperlinkRegex count=\(parts.count) \(atStr.string)")
    }
    
    func testHyperlinks() {
        for key in localizedStringsKeys {
            for langcode in localizedLangcodes {
                let fls = doParseLinkedString(key: key, langcode: langcode)
                print("\(key) \(langcode) \(fls.length)")
            }
        }
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
