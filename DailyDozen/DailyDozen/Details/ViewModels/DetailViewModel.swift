//
//  DetailViewModel.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 07.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

struct DetailViewModel {
    
    // MARK: - Properties
    private let details: Detail
    private let itemHeading: String
    private let itemTypeKey: String
    private let topic: String
    
    var unitsType: UnitsType
    
    /// Returns the main topic url.
    var topicURL: URL {
        return LinksService.shared.link(forTopic: topic)
    }
    
    /// Returns the number of items in the metric sizes.
    var sizesCount: Int {
        return details.metricSizes.count
    }
    
    /// Returns the number of items in the types.
    var typesCount: Int {
        return details.types.count
    }
    /// Returns the item name.
    var itemTitle: String {
        return itemHeading
    }
    
    /// Returns an image of the item.
    var detailsImage: UIImage? {
        return UIImage(named: "detail_\(itemTypeKey)")
    }
    
    // MARK: - Inits
    init(itemHeading: String, 
         itemTypeKey: String,
         topic: String,
         metricSizes: [String],
         imperialSizes: [String],
         types: [[String: String]]) {
        details = Detail(metricSizes: metricSizes, imperialSizes: imperialSizes, types: types)
        self.itemHeading = itemHeading
        self.itemTypeKey = itemTypeKey
        self.topic = topic
        
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
        return unitsType == .metric ? details.metricSizes[index] : details.imperialSizes[index]
    }
    
    /// Returns a tuple of the type name and type link state for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: A tuple of the type name and type link.
    func typeData(index: Int) -> (name: String, hasLink: Bool) {
        let name = details.types[index].keys.first ?? ""
        let hasLink = details.types[index].values.first == ""
        return (name, hasLink)
    }
    
    /// Returns the type topic for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The type toipic url.
    func typeTopicURL(index: Int) -> URL? {
        guard let topic = details.types[index].values.first else { return nil }
        return LinksService.shared.link(forTopic: topic)
    }
}
