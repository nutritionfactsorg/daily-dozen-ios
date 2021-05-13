//
//  InfoMenuAboutTableVC.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 11.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import ActiveLabel

class InfoMenuAboutTableVC: UITableViewController {

    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance() -> UIViewController {
        let storyboard = UIStoryboard(name: "InfoMenuAboutLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateInitialViewController()
            else { fatalError("Did not instantiate `InfoMenuAboutTableVC`") }
        viewController.title = NSLocalizedString("info.about.title", comment: "About this app")

        return viewController
    }

    // MARK: - Nested
    private struct Regex {
        static let bookHowNotToDie = "\\sHow Not to Die\\b"
        static let bookHowNotToDiet = "\\sHow Not to Diet\\b"
        static let site = "\\sNutritionFacts.org\\b"
        static let christi = "\\sChristi Richards\\b"
        static let const = "\\sKonstantin Khokhlov\\b"
        static let marc = "\\sMarc Campbell\\b"
        static let elements = "\\sSketch Elements\\b"
    }

    // MARK: - Outlets
    @IBOutlet private weak var messageLabel: ActiveLabel!
    @IBOutlet private weak var infoLabel: ActiveLabel!
    @IBOutlet private weak var designLabel: ActiveLabel!

    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white

        let barItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        barItem.tintColor = UIColor.white
        navigationItem.setLeftBarButton(barItem, animated: false)

        let bookType = ActiveType.custom(pattern: Regex.bookHowNotToDie)
        messageLabel.enabledTypes.append(bookType)

        messageLabel.customize { label in
            label.customColor[bookType] = ColorManager.style.mainMedium
            label.handleCustomTap(for: bookType) { _ in
                UIApplication.shared
                    .open(LinksService.shared.siteBook,
                          options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                          completionHandler: nil)
            }
        }

        provide(link: LinksService.shared.team, for: Regex.site, in: infoLabel)
        provide(link: LinksService.shared.aboutChristi, for: Regex.christi, in: infoLabel)
        provide(link: LinksService.shared.aboutConst, for: Regex.const, in: infoLabel)
        provide(link: LinksService.shared.aboutMarc, for: Regex.marc, in: infoLabel)
        // provide(link: LinksService.shared.aboutElements, for: Regex.elements, in: designLabel)
    }

    /// Provides a link for the current regex in the label.
    ///
    /// - Parameters:
    ///   - link: The link.
    ///   - pattern: The regex.
    ///   - label: The label.
    private func provide(link: URL?, for pattern: String, in label: ActiveLabel) {
        let about = ActiveType.custom(pattern: pattern)
        label.enabledTypes.append(about)

        if let aboutLink = link {
            label.customize { label in
                label.customColor[about] = ColorManager.style.mainMedium
                label.handleCustomTap(for: about) { _ in
                    UIApplication.shared
                        .open(aboutLink,
                              options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                              completionHandler: nil)
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
