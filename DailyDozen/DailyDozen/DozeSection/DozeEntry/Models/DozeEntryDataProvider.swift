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
        static let dozeEntryRowSid = "DozeEntryRowSid"
        static let dozeItemStateCheckboxSid = "DozeItemStateCheckboxSid"
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
        guard let dozeEntryRow = tableView.dequeueReusableCell(
            withIdentifier: Strings.dozeEntryRowSid
        ) as? DozeEntryRow else {
            fatalError("Expected `DozeEntryRow`")
        }
        guard let servingsSection = DozeEntrySections(rawValue: indexPath.section) else {
            fatalError("Expected `servingsSection`")
        }
        var rowIndex = indexPath.row
        if servingsSection == .supplements {
            rowIndex += tableView.numberOfRows(inSection: 0)
        }
        let itemType: DataCountType = viewModel.itemType(rowIndex: rowIndex)
        
        // Determine Tracker Streak value for this itemType
        let states: [Bool] = viewModel.dozeItemStates(rowIndex: rowIndex)
        let countNow = states.filter { $0 }.count // count `true`
        var streak = states.count == countNow ? 1 : 0
        if streak > 0 {
            streak = viewModel.itemStreak(rowIndex: rowIndex)
        }
        
        dozeEntryRow.configure(itemType: itemType, tag: rowIndex, streak: streak)
        return dozeEntryRow
    }
}

// MARK: - States UICollectionViewDataSource
extension DozeEntryDataProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemInfo(rowIndex: collectionView.tag).itemType.maxServings
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Strings.dozeItemStateCheckboxSid,
            for: indexPath)
        guard let stateCell = cell as? DozeItemStateCheckbox else {
            fatalError("There should be a cell")
        }
        
        let states: [Bool] = viewModel.dozeItemStates(rowIndex: collectionView.tag)
        stateCell.configure(with: states[indexPath.row])
        return stateCell // individual checkbox
    }
}
