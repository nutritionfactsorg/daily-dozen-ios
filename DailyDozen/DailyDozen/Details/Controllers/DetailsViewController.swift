//
//  DetailsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 31.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dataProvider: DetailsDataProvider!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataProvider
        tableView.delegate = self
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

    // MARK: - Methods
    /// Sets a view model for the current item.
    ///
    /// - Parameter item: The current item name.
    func setViewModel(for item: String) {
        let textProvider = TextsProvider()
        dataProvider.viewModel = textProvider.loadDetail(for: item)
    }
}
