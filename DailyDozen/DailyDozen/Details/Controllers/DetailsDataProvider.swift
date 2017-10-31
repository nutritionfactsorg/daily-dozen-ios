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

    private enum SectionTypes: Int {
        case image, sizes, types
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = SectionTypes(rawValue: section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            return nil
        case .sizes:
            return "Serving Sizes"
        case .types:
            return "Types"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SectionTypes(rawValue: section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            return 1
        case .sizes:
            return 2
        case .types:
            return 10
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = SectionTypes(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            return tableView.dequeueReusableCell(withIdentifier: Keys.imageID, for: indexPath)
        case .sizes:
            return tableView.dequeueReusableCell(withIdentifier: Keys.sizesID, for: indexPath)
        case .types:
            return tableView.dequeueReusableCell(withIdentifier: Keys.typesID, for: indexPath)
        }
    }
}
