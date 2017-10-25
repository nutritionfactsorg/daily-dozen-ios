//
//  ServingsDataProvider.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 23.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsDataProvider: NSObject, UITableViewDataSource {

    // MARK: - Nested
    private struct Keys {
        static let cellID = "Cell"
    }

    var viewModel: DozeViewModel!

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.cellID) as? ServingsCell else {
            fatalError("There should be a cell")
        }
        let index = indexPath.row
        cell.configure(with: viewModel.itemName(for: index), states: viewModel.itemStates(for: index))
        return cell
    }
}
