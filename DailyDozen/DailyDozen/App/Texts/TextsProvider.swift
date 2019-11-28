//
//  TextsProvider.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 07.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

class TextsProvider {
    
    // MARK: - Nested
    private struct Strings {
        static let sizes = "Sizes"
        static let metric = "Metric" // Sizes.Metric
        static let imperial = "Imperial" // Sizes.Imperial
        static let types = "Types" // Servings Examples
        static let topic = "Topic"
    }
    
    /// Returns the shared TextsProvider object.
    static let shared: TextsProvider = {
        // See RealmConfigLegacy initialDoze(…) for keynames in Details.plist
        guard
            let path = Bundle.main.path(forResource: "Details", ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any]
            else { fatalError("TextsProvider failed to load 'Details.plist'") }
        
        return TextsProvider(dictionary: dictionary)
    }()
    
    private let dictionary: [String: Any]
    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }
    
    /// Loads static texts for the current item.
    ///
    /// - Parameter itemName: The current item name.
    /// - Returns: A detail view model for static texts.
    func getDetails(itemTypeKey: String) -> DetailViewModel {
        guard
            let item = dictionary[itemTypeKey] as? [String: Any]
            else { fatalError("There should be an item") }
        
        guard
            let sizes = item[Strings.sizes] as? [String: Any],
            let metric = sizes[Strings.metric] as? [String],
            let imperial = sizes[Strings.imperial] as? [String]
            else { fatalError("There should be sizes") }
        
        guard
            let types = item[Strings.types] as? [[String: String]]
            else { fatalError("There should be types") }
        
        guard
            let topic = item[Strings.topic] as? String
            else { fatalError("URL Topic not found for \(itemTypeKey)") }
        
        var itemHeading = ""
        if let dataCountType = DataCountType(typeKey: itemTypeKey) {
            itemHeading = dataCountType.headingDisplay
        }
        return DetailViewModel(itemHeading: itemHeading, itemTypeKey: itemTypeKey, topic: topic, metricSizes: metric, imperialSizes: imperial, types: types)
    }
    
    /// Returns the URL topic for the current item name.
    ///
    /// Use:
    ///
    /// ```
    /// https://nutritionfacts.org/topics/TOPIC/
    /// ```
    ///
    /// - Parameter itemName: The current item name.
    /// - Returns: URL path TOPIC component.
    func getTopic(itemTypeKey: String) -> String {
        guard
            let item = dictionary[itemTypeKey] as? [String: Any],
            let topic = item[Strings.topic] as? String
            else { fatalError("URL Topic not found for \(itemTypeKey)") }
        
        return topic
    }
}
