//
//  ReminderViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 12.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - Builder
class ReminderBuilder {

    // MARK: - Nested
    private struct Keys {
        static let storyboard = "Reminder"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> ReminderViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ReminderViewController
            else { fatalError("There should be a controller") }
        viewController.title = "Daily Reminder Settings"

        return viewController
    }
}

// MARK: - Controller
class ReminderViewController: UIViewController {
}
