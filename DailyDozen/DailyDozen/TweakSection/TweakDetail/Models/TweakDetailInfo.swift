//
//  TweakDetailInfo.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable nesting

import Foundation

struct TweakDetailInfo: Codable {
    
    struct Item: Codable {
                
        struct Activity: Codable { // Display Subheading
            var imperial: String
            var metric: String
        }
        
        var heading: String
        var activity: Activity // like doze size
        var explanation: String // replaces doze type list
        var topic: String // item level URL path fragment
    }
    
    var itemsDict: [String: Item]
}
