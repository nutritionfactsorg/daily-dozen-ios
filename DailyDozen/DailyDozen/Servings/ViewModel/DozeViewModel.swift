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

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter
    }()

    /// Returns the number of items in the doze.
    var count: Int {
        return doze.items.count
    }

    /// Returns the doze name from the doze date.
    var name: String {
        return dateFormatter.string(from: doze.date)
    }

    // MARK: - Inits
    init(doze: Doze) {
        self.doze = doze
    }

    // MARK: - Methods
    /// Returns an item name in the doze for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: A name.
    func itemName(for index: Int) -> String {
        return doze.items[index].name
    }

    /// Returns item states in the doze for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The states array.
    func itemStates(for index: Int) -> [Bool] {
        return Array(doze.items[index].states)
    }

    /// Returns item ID in the doze for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The item id.
    func itemID(for index: Int) -> String {
        return doze.items[index].id
    }

    func imageName(for index: Int) -> String {
        let name = "ic_\(itemName(for: index).lowercased().replacingOccurrences(of: " ", with: "_"))"
        return name
    }
}
