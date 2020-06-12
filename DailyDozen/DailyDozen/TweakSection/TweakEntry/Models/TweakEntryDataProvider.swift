//
//  TweakEntryDataProvider.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TweakEntryDataProvider: NSObject, UITableViewDataSource {
    
    // MARK: - Nested
    private struct Strings {
        static let tweakTableViewCell = "tweakTableViewCell"
        static let tweakStateCell = "tweakStateCell"
    }
    
    var viewModel: TweakEntryViewModel!
    
    // MARK: - Tweaks UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tweakSection = TweakEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return tweakSection.numberOfRowsInSection(with: viewModel.count)
    }
    
    // Row Cell At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = RealmProvider()
        guard
            let tweakTableViewCell = tableView
                .dequeueReusableCell(withIdentifier: Strings.tweakTableViewCell) as? TweakEntryTableViewCell else {
                fatalError("Expected `TweakEntryTableViewCell`")
        }

        let rowIndex = indexPath.row
        let itemType = viewModel.itemType(rowIndex: rowIndex)
        
        // Determine Tracker Streak value for this itemType
        let states = viewModel.tweakItemStates(rowIndex: rowIndex)
        let countNow = states.filter { $0 }.count
        var streak = states.count == countNow ? 1 : 0
        if streak > 0 {
            let yesterday = viewModel.trackerDate.adding(.day, value: -1)!
            // previous streak +1
            // :NYI: just read the streak for item from Realm given PID
            let yesterdayItems = realm.getDailyTracker(date: yesterday).itemsDict
            if let yesterdayStreak = yesterdayItems[itemType]?.streak {
                streak += yesterdayStreak
            }
        }
        
        tweakTableViewCell.configure(
            heading: itemType.headingDisplay,
            tag: rowIndex,
            imageName: itemType.imageName,
            streak: streak)
        
        let itemPid = viewModel.itemPid(rowIndex: rowIndex)
        realm.updateStreak(streak, pid: itemPid)
        
        return tweakTableViewCell
    }
}

// MARK: - States UICollectionViewDataSource
extension TweakEntryDataProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemInfo(rowIndex: collectionView.tag).maxServings
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Strings.tweakStateCell,
            for: indexPath)
        guard let stateCell = cell as? TweakEntryStateCell else {
            fatalError("There should be a cell")
        }
        
        let states = viewModel.tweakItemStates(rowIndex: collectionView.tag)
        stateCell.configure(with: states[indexPath.row])
        return stateCell // individual checkbox
    }
}
