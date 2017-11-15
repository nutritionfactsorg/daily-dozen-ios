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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = DetailsSection(rawValue: section) else {
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
        guard let sectionType = DetailsSection(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {

        case .image:
            guard
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: Keys.imageID) as? ImageCell
                else { return UITableViewCell() }

            cell.configure(image: viewModel.image)
            return cell

        case .sizes:
            guard
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: Keys.sizesID) as? SizesCell
                else { return UITableViewCell() }

            cell
                .configure(title: viewModel.sizeDescription(for: indexPath.row))
            return cell

        case .types:
            guard
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: Keys.typesID) as? TypesCell
                else { return UITableViewCell() }

            cell
                .configure(title: viewModel.typeData(for: indexPath.row).name,
                           useLink: viewModel.typeData(for: indexPath.row).hasLink,
                           tag: indexPath.row)
            return cell
        }
    }
}
