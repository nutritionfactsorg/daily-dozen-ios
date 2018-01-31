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
    static func instantiateController() -> UIViewController {
        let storyboard = UIStoryboard(name: Keys.storyboard, bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController()
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
        static let site = "\\sNutritionFacts.org\\b"
        static let christi = "\\sChristi Richards\\b"
        static let const = "\\sKonstantin Khokhlov\\b"
        static let elements = "\\sSketch Elements\\b"
    }

    // MARK: - Outlets
    @IBOutlet private weak var messageLabel: ActiveLabel!
    @IBOutlet private weak var infoLabel: ActiveLabel!
    @IBOutlet private weak var designLabel: ActiveLabel!

    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        let bookType = ActiveType.custom(pattern: Regex.book)
        messageLabel.enabledTypes.append(bookType)

        messageLabel.customize { label in
            label.customColor[bookType] = UIColor.greenColor
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
            label.customColor[siteType] = UIColor.greenColor
            label.handleCustomTap(for: siteType) { _ in
                UIApplication.shared
                    .open(LinksService.shared.team,
                          options: [:],
                          completionHandler: nil)
            }
        }

        let aboutChristi = ActiveType.custom(pattern: Regex.christi)
        infoLabel.enabledTypes.append(aboutChristi)

        if let christiLink = LinksService.shared.aboutChristi {
            infoLabel.customize { label in
                label.customColor[aboutChristi] = UIColor.greenColor
                label.handleCustomTap(for: aboutChristi) { _ in
                    UIApplication.shared
                        .open(christiLink,
                              options: [:],
                              completionHandler: nil)
                }
            }
        }

        let aboutConst = ActiveType.custom(pattern: Regex.const)
        infoLabel.enabledTypes.append(aboutConst)

        if let constLink = LinksService.shared.aboutConst {
            infoLabel.customize { label in
                label.customColor[aboutConst] = UIColor.greenColor
                label.handleCustomTap(for: aboutConst) { _ in
                    UIApplication.shared
                        .open(constLink,
                              options: [:],
                              completionHandler: nil)
                }
            }
        }

        let aboutElements = ActiveType.custom(pattern: Regex.elements)
        designLabel.enabledTypes.append(aboutElements)

        if let elementsLink = LinksService.shared.aboutElements {
            designLabel.customize { label in
                label.customColor[aboutElements] = UIColor.greenColor
                label.handleCustomTap(for: aboutElements) { _ in
                    UIApplication.shared
                        .open(elementsLink,
                              options: [:],
                              completionHandler: nil)
                }
            }
        }
    }
}
