//
//  DetailsBuilder.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 07.11.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DetailsBuilder {

    // MARK: - Nested
    struct Keys {
        static let storyboard = "Details"
    }

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Parameter item: An item name.
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController(with item: String) -> DetailsViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? DetailsViewController
            else { fatalError("There should be a controller") }

        viewController.title = item
        viewController.setViewModel(for: item)

        return viewController
    }
}
