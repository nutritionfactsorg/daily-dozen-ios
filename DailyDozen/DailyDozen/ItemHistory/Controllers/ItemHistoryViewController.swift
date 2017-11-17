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
    static func instantiateController(with title: String) -> UIViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController()
            else { fatalError("There should be a controller") }
        viewController.title = title

        return viewController
    }
}

class ItemHistoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ItemHistoryViewController: FSCalendarDelegate {
}

extension ItemHistoryViewController: FSCalendarDataSource {
}
