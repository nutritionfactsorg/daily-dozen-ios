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
    private struct Keys {
        static let details = "Details"
        static let sizes = "Sizes"
        static let metric = "Metric"
        static let imperial = "Imperial"
        static let types = "Types"
    }

    func loadDetails(for itemName: String) -> DetailViewModel {
        guard
            let path = Bundle.main.path(
            forResource: Keys.details, ofType: "plist")
            else {  fatalError("There should be a settings file") }

        guard
            let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any],
            let item = dictionary[itemName] as? [String: Any]
            else { fatalError("There should be an item") }

        guard
            let sizes = item[Keys.sizes] as? [String: Any],
            let metric = sizes[Keys.metric] as? [String],
            let imperial = sizes[Keys.imperial] as? [String]
            else { fatalError("There should be sizes") }

        guard
            let types = item[Keys.types] as? [[String: String]]
            else { fatalError("There should be types")  }

        return DetailViewModel(itemName: itemName, metricSizes: metric, imperialSizes: imperial, types: types)
    }
}
