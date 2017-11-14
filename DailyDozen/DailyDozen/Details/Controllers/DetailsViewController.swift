//
//  DetailsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 31.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate {

    // MARK: - Nested
    private struct Keys {
        static let videos = "VIDEOS"
    }

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dataProvider: DetailsDataProvider!

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
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        return sectionType.rowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = SectionType(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return sectionType.headerHeigh
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = SectionType(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return sectionType.headerView
    }

    // MARK: - Actions
    /// Updates the tableView for the current unit type.
    ///
    /// - Parameter sender: The button.
    @IBAction private func unitsChanged(_ sender: UIButton) {
        let sectionIndex = SectionType.sizes.rawValue
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

    // MARK: - Methods
    /// Sets a view model for the current item.
    ///
    /// - Parameter item: The current item name.
    func setViewModel(for item: String) {
        let textProvider = TextsProvider()
        dataProvider.viewModel = textProvider.loadDetail(for: item)
    }

    /// Opens the main topic url in the browser.
    @objc private func barItemPressed() {
        UIApplication.shared
            .open(dataProvider.viewModel.topicURL,
                  options: [:],
                  completionHandler: nil)
    }
}
