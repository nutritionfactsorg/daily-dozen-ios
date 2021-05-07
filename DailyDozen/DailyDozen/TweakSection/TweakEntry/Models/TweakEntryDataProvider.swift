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
        static let tweakEntryRowSid = "TweakEntryRowSid"
        static let tweakItemStateCheckboxSid = "TweakItemStateCheckboxSid"
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
        guard let tweakEntryRow = tableView.dequeueReusableCell(
            withIdentifier: Strings.tweakEntryRowSid
        ) as? TweakEntryRow else {
            fatalError("Expected `TweakEntryRow`")
        }

        let rowIndex = indexPath.row
        let itemType = viewModel.itemType(rowIndex: rowIndex)
        
        // Determine Tracker Streak value for this itemType
        let states: [Bool] = viewModel.tweakItemStates(rowIndex: rowIndex)
        let countNow = states.filter { $0 }.count // count `true`
        var streak = states.count == countNow ? 1 : 0
        if streak > 0 {
            streak = viewModel.itemStreak(rowIndex: rowIndex)
        }
        
        tweakEntryRow.configure(itemType: itemType, tag: rowIndex, streak: streak)
        return tweakEntryRow
    }
}

// MARK: - States UICollectionViewDataSource
extension TweakEntryDataProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemInfo(rowIndex: collectionView.tag).maxServings
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Strings.tweakItemStateCheckboxSid,
            for: indexPath)
        guard let stateCell = cell as? TweakItemStateCheckbox else {
            fatalError("There should be a cell")
        }
        
        let states = viewModel.tweakItemStates(rowIndex: collectionView.tag)
        stateCell.configure(with: states[indexPath.row])
        return stateCell // individual checkbox
    }
}
