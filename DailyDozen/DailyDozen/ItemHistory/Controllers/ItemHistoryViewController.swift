//
//  ItemHistoryViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 16.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import FSCalendar

class ItemHistoryBuilder {

    // MARK: - Nested
    struct Keys {
        static let storyboard = "ItemHistory"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Parameter title: An item name.
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController(with title: String, itemId: Int) -> UIViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ItemHistoryViewController
            else { fatalError("There should be a controller") }
        viewController.title = title
        viewController.itemId = itemId

        return viewController
    }
}

class ItemHistoryViewController: UIViewController {
    private let realm = RealmProvider()
    var itemId = 0
}

extension ItemHistoryViewController: FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let doze = realm.getDoze(for: date)
        let item = doze.items[itemId]
        let hasStates = item.states.filter { $0 }
        return hasStates.count
    }
}
