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
    private let detail: Detail
    private let itemName: String

    /// Returns the number of items in the metric sizes.
    var sizesCount: Int {
        return detail.metricSizes.count
    }

    /// Returns the number of items in the types.
    var typesCount: Int {
        return detail.types.count
    }

    /// Returns an image of the item.
    var image: UIImage? {
        return UIImage(named: itemName.lowercased().replacingOccurrences(of: " ", with: "_"))
    }

    // MARK: - Inits
    init(itemName: String, metricSizes: [String], imperialSizes: [String], types: [[String: String]]) {
        detail = Detail(metricSizes: metricSizes, imperialSizes: imperialSizes, types: types)
        self.itemName = itemName
    }

    // MARK: - Methods
    /// Returns a size description for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: A description string.
    func sizeDescription(for index: Int) -> String {
        return detail.metricSizes[index]
    }

    /// Returns a tuple of the type name and type link for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: A tuple of the type name and type link.
    func typeData(for index: Int) -> (name: String, link: String) {
        let name = detail.types[index].keys.first ?? ""
        let link = detail.types[index].values.first ?? ""
        return (name, link)
    }

}
