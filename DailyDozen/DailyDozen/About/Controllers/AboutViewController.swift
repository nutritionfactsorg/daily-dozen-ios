//
//  AboutViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 11.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import ActiveLabel

// MARK: - Builder
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

// MARK: - Controller
class AboutViewController: UITableViewController {

    // MARK: - Nested
    private struct Regex {
        static let book = "\\sHow Not to Die\\b"
        static let site = "\\sNutritionFacts\\b"
    }

    // MARK: - Outlets
    @IBOutlet private weak var messageLabel: ActiveLabel!
    @IBOutlet private weak var infoLabel: ActiveLabel!

    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        let bookType = ActiveType.custom(pattern: Regex.book)
        messageLabel.enabledTypes.append(bookType)

        messageLabel.customize { label in
            label.customColor[bookType] = label.mentionColor
            label.handleCustomTap(for: bookType) { _ in
                UIApplication.shared
                    .open(LinksService.shared.siteBook,
                          options: [:],
                          completionHandler: nil)
            }
        }

        let siteType = ActiveType.custom(pattern: Regex.site)
        infoLabel.enabledTypes.append(siteType)

        infoLabel.customize { label in
            label.customColor[siteType] = label.mentionColor
            label.handleCustomTap(for: siteType) { _ in
                UIApplication.shared
                    .open(LinksService.shared.siteMain,
                          options: [:],
                          completionHandler: nil)
            }
        }
    }
}
