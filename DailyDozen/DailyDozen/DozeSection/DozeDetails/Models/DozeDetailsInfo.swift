//
//  DozeDetailsInfo.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable nesting

import Foundation

struct DozeDetailsInfo: Codable {
    
    struct Item: Codable {
                
        struct Serving: Codable { // Display Subheading: Size
            var imperial: String
            var metric: String
        }
        
        struct Variety: Codable { // Display Subheading: Type
            var text: String
            var topic: String // example level URL path fragment
        }
        
        var heading: String
        var servings: [Serving] // AKA size
        var varieties: [Variety] // AKA type
        var topic: String // item level URL path fragment
    }
    
    var itemsDict: [String: Item]
}
