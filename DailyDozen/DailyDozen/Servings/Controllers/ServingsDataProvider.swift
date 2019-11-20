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
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let servingsSection = ServingsSection(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return servingsSection.numberOfRowsInSection(with: viewModel.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = RealmProviderVersion02()
        guard
            let cell = tableView
                .dequeueReusableCell(withIdentifier: Keys.servingsCell) as? ServingsCell,
            let servingsSection = ServingsSection(rawValue: indexPath.section) else {
                fatalError("There should settings")
        }
        var index = indexPath.row
        if servingsSection == .supplements {
            index += tableView.numberOfRows(inSection: 0)
        }

        var streak = viewModel.itemStates(index: index).count == viewModel.itemStates(index: index).filter { $0 }.count ? 1 : 0

        if streak > 0 {
            let date = viewModel.dozeDate.adding(.day, value: -1)!
            streak += realm.getDoze(for: date)
                .items[index].streak
        }

        cell.configure(
            with: viewModel.itemInfo(for: index).name,
            tag: index,
            imageName: viewModel.imageName(for: index),
            streak: streak)

        let id = viewModel.itemID(for: index)
        realm.updateStreak(streak, with: id)

        return cell
    }
}

// MARK: - States UICollectionViewDataSource
extension ServingsDataProvider: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let states = viewModel.itemStates(index: collectionView.tag)
        return states.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: Keys.doseCell, for: indexPath) as? StateCell else {
                    fatalError("There should be a cell")

        }
        cell.configure(with: viewModel.itemStates(index: collectionView.tag)[indexPath.row])
        return cell
    }
}
