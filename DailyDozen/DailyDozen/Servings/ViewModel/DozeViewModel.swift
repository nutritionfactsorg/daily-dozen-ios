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
    
    /// Returns a doze date.
    var dozeDate: Date {
        return doze.date
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
    func itemInfo(for index: Int) -> (name: String, isSupplemental: Bool) {
        let name = doze.items[index].name
        let isSupplemental = name.contains("Vitamin") 
            || name.contains("Omega")
        return (name, isSupplemental)
    }
    
    /// Returns an item streak count for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The streak count.
    func itemStreak(for index: Int) -> Int {
        return doze.items[index].streak
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
    func itemStates(index: Int) -> [Bool] {
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
    /// - Note: A `Servings` image filename is derived from the
    ///  `Item.name` property as defined in `RealmConfig`.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The image name.
    func imageName(for index: Int) -> String {
        let basename = itemInfo(for: index).name
            .lowercased()
            .replacingOccurrences(of: "_&_", with: "_")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "_")
        let filename = "ic_\(basename)"
        return filename
    }
}
