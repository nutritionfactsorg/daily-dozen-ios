//
//  InfoMenuAboutTableVC.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 11.12.2017.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

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
    
    // Localized outlets
    @IBOutlet weak var infoAppAboutAppName: UILabel!
    @IBOutlet weak var infoAppAboutCreatedBy: UILabel!
    @IBOutlet weak var infoAppAboutOssCredits: UILabel!
    @IBOutlet weak var infoAppAboutOverview: UILabel!
    @IBOutlet weak var infoAppAboutVersion: UILabel!
    @IBOutlet weak var infoAppAboutWelcome: UILabel!
    
    // MARK: - UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = ColorManager.style.mainMedium
        navigationController?.navigationBar.tintColor = UIColor.white

        let barItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        barItem.tintColor = UIColor.white
        navigationItem.setLeftBarButton(barItem, animated: false)
        
        infoAppAboutAppName.text = NSLocalizedString("info_app_about_app_name", comment: "")
        infoAppAboutCreatedBy.text = NSLocalizedString("info_app_about_created_by", comment: "")
        infoAppAboutOssCredits.text = NSLocalizedString("info_app_about_oss_credits", comment: "")
        infoAppAboutOverview.text = NSLocalizedString("info_app_about_overview", comment: "")
        infoAppAboutVersion.text = NSLocalizedString("info_app_about_version", comment: "")
        infoAppAboutWelcome.text = NSLocalizedString("info_app_about_welcome", comment: "")
    }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
