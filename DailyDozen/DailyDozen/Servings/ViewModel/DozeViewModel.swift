//
//  DozeViewModel.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 24.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import Foundation
import RealmSwift

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

    /// Returns item doses in the doze for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The doses array.
    func itemDoses(for index: Int) -> [Bool] {
        return Array(doze.items[index].doses)
    }
}
