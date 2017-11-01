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

    var sizes: [String]!
    var types: [(name: String, link: String)]!

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = SectionType(rawValue: section) else {
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
        guard let sectionType = SectionType(rawValue: section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            return 1
        case .sizes:
            return sizes.count
        case .types:
            return types.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            fatalError("There should be a section type")
        }
        switch sectionType {
        case .image:
            return tableView.dequeueReusableCell(withIdentifier: Keys.imageID, for: indexPath)
        case .sizes:
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.sizesID, for: indexPath)
            cell.textLabel?.text = sizes[indexPath.row]
            return cell
        case .types:
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.typesID, for: indexPath)
            cell.textLabel?.text = types[indexPath.row].name
            cell.detailTextLabel?.isHidden = types[indexPath.row].link == ""
            return cell
        }
    }

    func loadTexts(for itemName: String) {
        guard let path = Bundle.main.path(
            forResource: "Details",
            ofType: "plist") else {
                fatalError("There should be a settings file")
        }

        guard
            let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any],
            let item = dictionary[itemName] as? [String: Any]
            else { fatalError("There should be an item") }

        guard
            let sizes = item["Sizes"] as? [String: Any],
            let metric = sizes["Metric"] as? [String]
            else { fatalError("There should be sizes") }

        self.sizes = metric

        guard
            let types = item["Types"] as? [[String: String]]
            else { fatalError("There should be types")  }

        self.types = types.flatMap { $0.flatMap { $0 } }
    }
}
