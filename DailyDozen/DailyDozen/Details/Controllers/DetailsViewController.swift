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
    @IBOutlet weak var dataProvider: DetailsDataProvider!

    var itemName = "Beans"

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataProvider
        tableView.delegate = self
        dataProvider.loadTexts(for: itemName)
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            return 200
        case .sizes:
            return 75
        case .types:
            return 75
        }
    }
}
