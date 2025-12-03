//
//  DozeDetailInfo.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//
// swiftlint:disable nesting

import Foundation

struct DozeDetailInfo: Codable {
    
    struct Item: Codable {
                
        struct Serving: Codable { // Display Subheading: Size
            var imperial: String
            var metric: String
        }
        
        struct Variety: Codable { // Display Subheading: Type
            var text: String
            var topic: String // URL path fragment
        }
        
        var heading: String
        var servings: [Serving] // AKA size
        var varieties: [Variety] // AKA type
        var topic: String // item level URL path fragment
     
        static let example = Item(heading: "Beans", servings: [DailyDozen.DozeDetailInfo.Item.Serving(imperial: "¼ cup hummus or bean dip", metric: "60 g hummus or bean dip"), DailyDozen.DozeDetailInfo.Item.Serving(imperial: "½ cup cooked beans, split peas, or lentils", metric: "90 g cooked beans, split peas, or lentils")], varieties: [DailyDozen.DozeDetailInfo.Item.Variety(text: "Black beans", topic: "topics/black-beans"), DailyDozen.DozeDetailInfo.Item.Variety(text: "Black-eyed peas", topic: ""), DailyDozen.DozeDetailInfo.Item.Variety(text: "Butter beans", topic: ""), DailyDozen.DozeDetailInfo.Item.Variety(text: "Cannellini beans", topic: "")], topic: "topics/beans")
    }
//        init(Item: Item ) {
//            self.Item = Item
//        }
    
    var itemsDict: [String: Item]
}
