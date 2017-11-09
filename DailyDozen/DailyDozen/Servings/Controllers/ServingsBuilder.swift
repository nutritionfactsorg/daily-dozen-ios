//
//  ServingsBuilder.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 19.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsBuilder {

    // MARK: - Nested
    struct Keys {
        static let storyboard = "Servings"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Parameter title: A view title.
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController(with title: String) -> ServingsViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ServingsViewController
            else { fatalError("There should be a controller") }

        viewController.title = title

        return viewController
    }
}
