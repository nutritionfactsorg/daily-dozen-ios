//
//  DetailsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 31.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

// MARK: - Builder
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

        viewController.setViewModel(for: item)

        return viewController
    }
}

// MARK: - Controller
class DetailsViewController: UIViewController {

    // MARK: - Nested
    private struct Keys {
        static let videos = "VIDEOS"
    }

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dataProvider: DetailsDataProvider!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataProvider
        tableView.delegate = self

        navigationItem
            .rightBarButtonItem = UIBarButtonItem(title: Keys.videos,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(barItemPressed))

        imageView.image = dataProvider.viewModel.image
        titleLabel.text = dataProvider.viewModel.itemTitle
    }

    // MARK: - Methods
    /// Sets a view model for the current item.
    ///
    /// - Parameter item: The current item name.
    func setViewModel(for item: String) {
        dataProvider.viewModel = TextsProvider.shared.loadDetail(for: item)
    }

    /// Opens the main topic url in the browser.
    @objc private func barItemPressed() {
        UIApplication.shared
            .open(dataProvider.viewModel.topicURL,
                  options: [:],
                  completionHandler: nil)
    }

    // MARK: - Actions
    /// Updates the tableView for the current unit type.
    ///
    /// - Parameter sender: The button.
    @IBAction private func unitsChanged(_ sender: UIButton) {
        let sectionIndex = DetailsSection.sizes.rawValue
        guard
            let text = sender.titleLabel?.text?.lowercased(),
            let currentUnitsType = UnitsType(rawValue: text),
            let indexPaths = tableView.indexPathsForRows(in: tableView.rect(forSection: sectionIndex))
            else { return }

        let newUnitsType = currentUnitsType.toggledType
        let title = newUnitsType.title
        sender.setTitle(title, for: .normal)
        dataProvider.viewModel.unitsType = newUnitsType
        tableView.reloadRows(at: indexPaths, with: .fade)
    }

    /// Opens the type topic url in the browser.
    ///
    /// - Parameter sender: The button.
    @IBAction private func linkButtonPressed(_ sender: UIButton) {
        guard let url = dataProvider.viewModel.typeTopicURL(for: sender.tag) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - UITableViewDelegate
extension DetailsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = DetailsSection(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        return sectionType.rowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = DetailsSection(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return sectionType.headerHeigh
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = DetailsSection(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return sectionType.headerView
    }
}
