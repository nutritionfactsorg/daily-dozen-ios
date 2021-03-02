//
//  DozeDetailViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DozeDetailViewController: UIViewController {
    
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Parameter itemTypeKey: An item type key string.
    /// - Returns: The initial view controller in the storyboard.
    static func newInstance(itemTypeKey: String) -> DozeDetailViewController {
        
        let storyboard = UIStoryboard(name: "DozeDetailLayout", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateInitialViewController() as? DozeDetailViewController
            else { fatalError("Did not instantiate `DozeDetailViewController`") }
        
        viewController.setViewModel(itemTypeKey: itemTypeKey)
        
        return viewController
    }

    // MARK: - Nested
    private struct Strings {
        static let videos = NSLocalizedString("videos.link.label", comment: "VIDEOS")
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dataProvider: DozeDetailDataProvider!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsImageView: UIImageView!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        tableView.dataSource = dataProvider
        tableView.delegate = self
        tableView.estimatedRowHeight = DozeDetailSections.amount.estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension // dynamic height
        
        if let dataCountType = dataProvider.dataCountType {
            if dataCountType.typeKey.prefix(4) == "doze" {
                let topicUrl = dataProvider.viewModel.topicURL
                // "urlSegment.base"="https://nutritionfacts.org/";
                if topicUrl.path != "/" {
                    // DozeDetailViewController add "VIDEOS" navigation
                    navigationItem.rightBarButtonItem = UIBarButtonItem(
                        title: Strings.videos,
                        style: .done,
                        target: self,
                        action: #selector(barItemPressed)
                    )
                }
            }
        }
        
        detailsImageView.image = dataProvider.viewModel.detailsImage
        titleLabel.text = dataProvider.viewModel.itemTitle
    }
    
    // MARK: - Methods
    /// Sets a view model for the current item.
    ///
    /// - Parameter item: The current item name.
    func setViewModel(itemTypeKey: String) {
        dataProvider.dataCountType = DataCountType(itemTypeKey: itemTypeKey)
        dataProvider.viewModel = DozeTextsProvider.shared.getDetails(itemTypeKey: itemTypeKey)
    }
    
    /// Opens the main topic url in the browser.
    @objc private func barItemPressed() {
        UIApplication.shared
            .open(dataProvider.viewModel.topicURL,
                  options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                  completionHandler: nil)
    }
    
    // MARK: - Actions
    /// Updates the tableView for the current unit type.
    ///
    /// - Parameter sender: The button.
    @IBAction private func unitsChanged(_ sender: UIButton) {
        let sectionIndex = DozeDetailSections.amount.rawValue
        guard
            let unitsTypePrefStr = UserDefaults.standard.string(forKey: SettingsKeys.unitsTypePref),
            let currentUnitsType = UnitsType(rawValue: unitsTypePrefStr),
            let indexPaths = tableView.indexPathsForRows(in: tableView.rect(forSection: sectionIndex))
            else { return }
        
        let newUnitsType: UnitsType = currentUnitsType.toggledType
        UserDefaults.standard.set(newUnitsType.rawValue, forKey: SettingsKeys.unitsTypePref)
        let title = newUnitsType.title
        sender.setTitle(title, for: .normal)
        dataProvider.viewModel.unitsType = newUnitsType
        tableView.reloadRows(at: indexPaths, with: .fade)
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "NoticeChangedUnitsType"),
            object: SettingsManager.isImperial(),
            userInfo: nil)
    }
    
    /// Opens the type topic url in the browser.
    ///
    /// - Parameter sender: The button.
    @IBAction private func linkButtonPressed(_ sender: UIButton) {
        guard let url = dataProvider.viewModel.typeTopicURL(index: sender.tag) else { return }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
}

// MARK: - UITableViewDelegate
extension DozeDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = DozeDetailSections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return sectionType.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = DozeDetailSections(rawValue: section) else {
            fatalError("There should be a doze section type")
        }
        if let dataCountType = dataProvider.dataCountType {
            if dataCountType.typeKey.prefix(5) == "tweak" {
                return sectionType.headerView
            }
        }
        return sectionType.headerView
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
