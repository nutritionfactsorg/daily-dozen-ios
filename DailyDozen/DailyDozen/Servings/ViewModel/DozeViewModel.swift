//
//  DozeViewModel.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 24.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation

class DozeViewModel {

    // MARK: - Properties
    private let doze: Doze

    /// Returns the number of items in the doze.
    var count: Int {
        return doze.items.count
    }

    // MARK: - Inits
    init(doze: Doze) {
        self.doze = doze
    }

    // MARK: - Methods
    /// Returns an item name and type in the doze for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: A tuple with the item name and type.
    func itemInfo(for index: Int) -> (name: String, isVitamin: Bool) {
        let name = doze.items[index].name
        return (name, name.contains("Vitamin"))
    }

    /// Returns a url for the current item name.
    ///
    /// - Parameter itemName: The item name.
    /// - Returns: A url.
    func topicURL(for itemName: String) -> URL {
        let topic = TextsProvider.shared.getTopic(for: itemName)
        return LinksService.shared.link(forTopic: topic)
    }

    /// Returns item states in the doze for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The states array.
    func itemStates(for index: Int) -> [Bool] {
        return Array(doze.items[index].states)
    }

    /// Returns an item ID in the doze for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The item id.
    func itemID(for index: Int) -> String {
        return doze.items[index].id
    }

    /// Returns an image name for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The image name.
    func imageName(for index: Int) -> String {
        let name = "ic_\(itemInfo(for: index).name.lowercased().replacingOccurrences(of: " ", with: "_"))"
        return name
    }
}
