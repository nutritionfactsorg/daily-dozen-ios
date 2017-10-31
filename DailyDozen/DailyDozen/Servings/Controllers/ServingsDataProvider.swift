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
        static let servingsCell = "servingsCell"
        static let doseCell = "doseCell"
    }

    var viewModel: DozeViewModel!

    // MARK: - Servings UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.servingsCell) as? ServingsCell else {
            fatalError("There should be a cell")
        }
        let index = indexPath.row
        cell.configure(
            with: viewModel.itemName(for: index),
            tag: index,
            imageName: viewModel.imageName(for: index))

        return cell
    }
}

// MARK: - States UICollectionViewDataSource
extension ServingsDataProvider: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemStates(for: collectionView.tag).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: Keys.doseCell, for: indexPath) as? StateCell else {
                    fatalError("There should be a cell")

        }
        cell.configure(with: viewModel.itemStates(for: collectionView.tag)[indexPath.row])
        return cell
    }
}
