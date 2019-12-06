//
//  TweaksDataProvider.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit

class TweaksDataProvider: NSObject, UITableViewDataSource {
    
    // MARK: - Nested
    private struct Strings {
        static let tweaksCell = "tweaksCell"
        static let tweaksStateCell = "tweaksStateCell" // :WAS: doseCell
    }
    
    var viewModel: DailyTweaksViewModel!
    
    // MARK: - Tweaks UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tweaksSection = TweaksSection(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return tweaksSection.numberOfRowsInSection(with: viewModel.count)
    }
    
    // Row Cell At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = RealmProvider()
        guard
            let tweaksCell = tableView
                .dequeueReusableCell(withIdentifier: Strings.tweaksCell) as? TweaksCell else {
                fatalError("Expected `TweaksCell`")
        }
        guard
            let tweaksSection = TweaksSection(rawValue: indexPath.section) else {
                fatalError("Expected `TweaksSection`")
        }
        var rowIndex = indexPath.row
        if tweaksSection == .supplements {
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
        tweaksCell.configure(
            heading: itemType.headingDisplay,
            tag: rowIndex,
            imageName: itemType.imageName,
            streak: streak)
        
        // viewModel: DailyTweaksViewModel tracker
        // tracker: DailyTracker getPid
        
        let itemPid = viewModel.itemPid(rowIndex: rowIndex)
        realm.updateStreak(streak, pid: itemPid)
        
        return tweaksCell
    }
}

// MARK: - States UICollectionViewDataSource
extension TweaksDataProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let states = viewModel.itemStates(rowIndex: collectionView.tag)
        return states.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Strings.tweaksStateCell,
            for: indexPath)
        guard let stateCell = cell as? TweaksStateCell else {
            fatalError("There should be a cell")
        }
        
        let states = viewModel.itemStates(rowIndex: collectionView.tag)
        stateCell.configure(with: states[indexPath.row])
        return stateCell // individual checkbox
    }
}
