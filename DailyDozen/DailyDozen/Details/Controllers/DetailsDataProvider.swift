//
//  DetailsDataProvider.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 31.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DetailsDataProvider: NSObject, UITableViewDataSource {

    // MARK: - Nested
    private struct Keys {
        static let imageID = "detailsImageCell"
        static let sizesID = "detailsSizesCell"
        static let typesID = "detailsTypesCell"
    }

    var viewModel: DetailViewModel!

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = SectionType(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return sectionType.title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            return 1
        case .sizes:
            return viewModel.sizesCount
        case .types:
            return viewModel.typesCount
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.imageID, for: indexPath)
            cell.imageView?.image = viewModel.image
            return cell
        case .sizes:
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.sizesID, for: indexPath)
            cell.textLabel?.text = viewModel.sizeDescription(for: indexPath.row)
            return cell
        case .types:
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.typesID, for: indexPath)
            cell.textLabel?.text = viewModel.typeData(for: indexPath.row).name
            cell.detailTextLabel?.isHidden = viewModel.typeData(for: indexPath.row).link == ""
            return cell
        }
    }
}
