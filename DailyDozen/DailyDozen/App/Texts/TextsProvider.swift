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
        static let details = "Details"
        static let sizes = "Sizes"
        static let metric = "Metric"
        static let imperial = "Imperial"
        static let types = "Types"
        static let topic = "Topic"
        static let plist = "plist"
    }

    /// Returns the shared TextsProvider object.
    static let shared: TextsProvider = {
        guard
            // See RealmConfigLegacy initialDoze(…) for keynames in Details.plist
            let path = Bundle.main.path(
                forResource: Strings.details, ofType: Strings.plist)
            else {  fatalError("There should be a settings file") }

        guard
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any]
            else {  fatalError("There should be a dictionary") }

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
    func loadDetail(for itemName: String) -> DetailViewModel {
        guard
            let item = dictionary[itemName] as? [String: Any]
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
            else { fatalError("There should be a topic") }

        return DetailViewModel(itemName: itemName, topic: topic, metricSizes: metric, imperialSizes: imperial, types: types)
    }

    /// Returns the topic for the current item name.
    ///
    /// - Parameter itemName: The current item name.
    /// - Returns: The topic.
    func getTopic(for itemName: String) -> String {
        guard
            let item = dictionary[itemName] as? [String: Any]
            else { fatalError("There should be an item") }

        guard
            let topic = item[Strings.topic] as? String
            else { fatalError("There should be a topic") }

        return topic
    }
}
