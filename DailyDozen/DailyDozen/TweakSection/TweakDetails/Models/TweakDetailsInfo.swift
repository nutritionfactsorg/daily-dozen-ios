//
//  TweakDetailsInfo.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable nesting

import Foundation

struct TweakDetailsInfo: Codable {
    
    struct Item: Codable {
                
        struct Activity: Codable { // Display Subheading
            var imperial: String
            var metric: String
        }
        
        var heading: String
        var activity: Activity // like doze size
        var description: [String] // like doze type
        var topic: String // item level URL path fragment
    }
    
    var itemsDict: [String: Item]
}
