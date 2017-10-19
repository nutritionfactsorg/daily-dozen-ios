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
    /// - Parameter storyboardName: A storyboard name.
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController(with title: String) -> ServingsViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? ServingsViewController
            else { fatalError("There should be a controller") }

        viewController.view.backgroundColor = generateRandomColor()
        viewController.title = title

        return viewController
    }

    static func generateRandomColor() -> UIColor {
        let hue = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
