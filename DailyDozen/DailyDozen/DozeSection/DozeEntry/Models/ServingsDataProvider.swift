//
//  ServingsDataProvider.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsDataProvider: NSObject, UITableViewDataSource {
    
    // MARK: - Nested
    private struct Strings {
        static let servingsCell = "servingsCell"
        static let servingsStateCell = "servingsStateCell" // "WAS: doseCell
    }
    
    var viewModel: DailyDozenViewModel!
    
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
    
    // Row Cell At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = RealmProvider()
        guard
            let servingsCell = tableView
                .dequeueReusableCell(withIdentifier: Strings.servingsCell) as? ServingsCell else {
                fatalError("Expected `tweaksCell`")
        }
        guard
            let servingsSection = ServingsSection(rawValue: indexPath.section) else {
                fatalError("Expected `servingsSection`")
        }
        var rowIndex = indexPath.row
        if servingsSection == .supplements {
            rowIndex += tableView.numberOfRows(inSection: 0)
        }
        
        let countMax = viewModel.itemStates(rowIndex: rowIndex).count
        let countNow = viewModel.itemStates(rowIndex: rowIndex).filter { $0 }.count
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
        servingsCell.configure(
            heading: itemType.headingDisplay,
            tag: rowIndex,
            imageName: itemType.imageName,
            streak: streak)
        
        // viewModel: DailyDozenViewModel tracker
        // tracker: DailyTracker getPid
        
        let itemPid = viewModel.itemPid(rowIndex: rowIndex)
        realm.updateStreak(streak, pid: itemPid)
        
        return servingsCell
    }
}

// MARK: - States UICollectionViewDataSource
extension ServingsDataProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let states = viewModel.itemStates(rowIndex: collectionView.tag)
        return states.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Strings.servingsStateCell,
            for: indexPath)
        guard let stateCell = cell as? ServingsStateCell else {
            fatalError("There should be a cell")
        }
        
        let states = viewModel.itemStates(rowIndex: collectionView.tag)
        stateCell.configure(with: states[indexPath.row])
        return stateCell // individual checkbox
    }
}
