//
//  DozeEntryDataProvider.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class DozeEntryDataProvider: NSObject, UITableViewDataSource {
    
    // MARK: - Nested
    private struct Strings {
        static let dozeTableViewCell = "dozeTableViewCell"
        static let dozeStateCell = "dozeStateCell"
    }
    
    var viewModel: DozeEntryViewModel!
    
    // MARK: - Servings UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let servingsSection = DozeEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return servingsSection.numberOfRowsInSection(with: viewModel.count)
    }
    
    // Row Cell At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = RealmProvider()
        guard
            let dozeTableViewCell = tableView
                .dequeueReusableCell(withIdentifier: Strings.dozeTableViewCell) as? DozeEntryTableViewCell else {
                fatalError("Expected `DozeEntryTableViewCell`")
        }
        guard
            let servingsSection = DozeEntrySections(rawValue: indexPath.section) else {
                fatalError("Expected `servingsSection`")
        }
        var rowIndex = indexPath.row
        if servingsSection == .supplements {
            rowIndex += tableView.numberOfRows(inSection: 0)
        }
        
        let states = viewModel.dozeItemStates(rowIndex: rowIndex)
        let countMax = states.count
        let countNow = states.filter { $0 }.count
        var streak = countMax == countNow ? 1 : 0
        
        if streak > 0 {
            let yesterday = viewModel.trackerDate.adding(.day, value: -1)!
            // previous streak +1
            let yesterdayItems = realm.getDailyTracker(date: yesterday).itemsDict
            let itemType = viewModel.itemType(rowIndex: rowIndex)
            if let yesterdayStreak = yesterdayItems[itemType]?.streak {
                streak += yesterdayStreak
            }
        }
        
        let itemType = viewModel.itemInfo(rowIndex: rowIndex).itemType
        dozeTableViewCell.configure(
            heading: itemType.headingDisplay,
            tag: rowIndex,
            imageName: itemType.imageName,
            streak: streak)
        
        // viewModel: DozeEntryViewModel tracker
        // tracker: DailyTracker getPid
        
        let itemPid = viewModel.itemPid(rowIndex: rowIndex)
        realm.updateStreak(streak, pid: itemPid)
        
        return dozeTableViewCell
    }
}

// MARK: - States UICollectionViewDataSource
extension DozeEntryDataProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemInfo(rowIndex: collectionView.tag).itemType.maxServings
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Strings.dozeStateCell,
            for: indexPath)
        guard let stateCell = cell as? DozeEntryStateCell else {
            fatalError("There should be a cell")
        }
        
        let states = viewModel.dozeItemStates(rowIndex: collectionView.tag)
        stateCell.configure(with: states[indexPath.row])
        return stateCell // individual checkbox
    }
}
