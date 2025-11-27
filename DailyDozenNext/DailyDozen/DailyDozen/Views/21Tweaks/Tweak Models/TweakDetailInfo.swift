//
//  TweakDetailInfo.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

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
        
        static let example = Item(heading: "", activity: DailyDozen.TweakDetailInfo.Item.Activity(imperial: "¼ cup ", metric: "1/4 g"), explanation: "", topic: "")
    }
    
    var itemsDict: [String: Item]
}
