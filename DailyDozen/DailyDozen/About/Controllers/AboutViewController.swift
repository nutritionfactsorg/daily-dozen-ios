//
//  AboutViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 11.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class AboutBuilder {

    // MARK: - Nested
    private struct Keys {
        static let storyboard = "About"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> AboutViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? AboutViewController
            else { fatalError("There should be a controller") }
        viewController.title = "About this app"

        return viewController
    }
}

class AboutViewController: UITableViewController {
}
