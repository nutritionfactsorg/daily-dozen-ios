//
//  DozeDetailViewModel.swift
//  DailyDozen
//
//  Copyright © 2020 Nutritionfacts.org. All rights reserved.
//

import UIKit

struct DozeDetailViewModel {
    
    // MARK: - Properties
    private let info: DozeDetailInfo.Item
    private let detailItemTypeKey: String
    
    var unitsType: UnitsType
    
    /// Returns the main topic url.
    var topicURL: URL {
        return LinksService.shared.link(forTopic: info.topic)
    }
    
    /// Returns the number of items in the metric amount (aka Serving Sizes).
    var amountCount: Int {
        return info.servings.count
    }
    
    /// Returns the number of items in the example (aka Serving Types).
    var exampleCount: Int {
        return info.varieties.count
    }
    /// Returns the item name.
    var itemTitle: String {
        return info.heading
    }
    
    /// Returns an image of the item.
    var detailsImage: UIImage? {
        return UIImage(named: "detail_\(detailItemTypeKey)")
    }
    
    // MARK: - Inits
    init(itemTypeKey: String, info: DozeDetailInfo.Item) {
        self.detailItemTypeKey = itemTypeKey
        self.info = info
        
        if let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let unitsTypePref = UnitsType(rawValue: unitsTypePrefStr) {
            self.unitsType = unitsTypePref
        } else {
            // :NYI:ToBeLocalized: set initial default based on device language
            self.unitsType = UnitsType.imperial
            UserDefaults.standard.set(self.unitsType.rawValue, forKey: SettingsKeys.unitsTypePref)
        }
    }
    
    // MARK: - Methods
    /// Returns a size description for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: A description string.
    func sizeDescription(index: Int) -> String {
        if unitsType == .metric {
            return info.servings[index].metric
        } else {
            return info.servings[index].imperial
        }
    }
    
    /// Returns a tuple of the type name and type link state for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: A tuple of the type name and type link.
    func typeData(index: Int) -> (name: String, hasLink: Bool) {
        let name = info.varieties[index].text 
        let hasLink = info.varieties[index].topic == "" // :???:!!!: correct logic?
        return (name, hasLink)
    }
    
    /// Returns the type topic for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The type toipic url.
    func typeTopicURL(index: Int) -> URL? {
        if info.varieties[index].topic.isEmpty { // :???:!!!: review logic
            return nil
        }
        let topic =  info.varieties[index].topic
        return LinksService.shared.link(forTopic: topic)
    }
    
}
