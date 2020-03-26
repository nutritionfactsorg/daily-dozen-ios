//
//  DozeEntryViewController.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import StoreKit // Used to request app store reivew by user.

class DozeEntryViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: DozeEntryDataProvider!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var starImage: UIImageView!
    
    // MARK: - Properties
    private let realm = RealmProvider()
    private let servingsStateCountMaximum = 24
    
    private var servingsStateCount = 0 {
        didSet {
            countLabel.text = statesCountString
            if servingsStateCount == servingsStateCountMaximum {
                starImage.popIn()
                SKStoreReviewController.requestReview()
            } else {
                starImage.popOut()
            }
        }
    }
    private var statesCountString: String {
        return "\(servingsStateCount) / \(servingsStateCountMaximum)"
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewModel(for: Date())
        
        tableView.dataSource = dataProvider
        tableView.delegate = self
        tableView.estimatedRowHeight = DozeEntrySections.main.dozeEstimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension // dynamic height
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return 
        }
        appDelegate.realmDelegate = self
    }
    
    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(for date: Date) {
        dataProvider.viewModel = DozeEntryViewModel(tracker: realm.getDailyTracker(date: date))
        servingsStateCount = 0
        let mainItemCount = dataProvider.viewModel.count - DozeEntrySections.supplementsCount
        for i in 0 ..< mainItemCount {
            let itemStates: [Bool] = dataProvider.viewModel.itemStates(rowIndex: i)
            for state in itemStates where state {
                servingsStateCount += 1 
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    /// DozeEntryTableViewCell infoButton
    @IBAction private func infoPressed(_ sender: UIButton) {
        let itemInfo = dataProvider.viewModel.itemInfo(rowIndex: sender.tag)
        
        guard !itemInfo.isSupplemental else {
            let url = dataProvider.viewModel.topicURL(itemTypeKey: itemInfo.itemType.typeKey)
            UIApplication.shared
                .open(url,
                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                      completionHandler: nil)
            return
        }
        let viewController = DozeDetailBuilder.instantiateController(itemTypeKey: itemInfo.itemType.typeKey)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// DozeEntryTableViewCell calendarButton
    @IBAction private func calendarPressed(_ sender: UIButton) {
        let heading = dataProvider.viewModel.itemInfo(rowIndex: sender.tag).itemType.headingDisplay
        let itemType = dataProvider.viewModel.itemType(rowIndex: sender.tag)
        let viewController = ItemHistoryBuilder.instantiateController(heading: heading, itemType: itemType)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func supplementsHeaderInfoBtnPressed(_ sender: UIButton) {
        let alert = AlertBuilder.instantiateController(for: .dietarySupplement)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func historyPressed(_ sender: UIButton) {
        let viewController = DozeHistoryBuilder.instantiateController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Servings UITableViewDelegate

extension DozeEntryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let dozeTableViewCell = cell as? DozeEntryTableViewCell else { return }
        dozeTableViewCell.stateCollection.delegate = self
        dozeTableViewCell.stateCollection.dataSource = dataProvider
        dozeTableViewCell.stateCollection.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let servingsSection = DozeEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return servingsSection.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return DozeEntrySections.main.footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let servingsSection = DozeEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return servingsSection.headerView
    }
}

// MARK: - States UICollectionViewDelegate
extension DozeEntryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rowIndex = collectionView.tag // which item
        let checkmarkIndex = indexPath.row // which checkmark
        var checkmarkStates = dataProvider.viewModel.itemStates(rowIndex: rowIndex)
        let itemPid = dataProvider.viewModel.itemPid(rowIndex: rowIndex)
        
        var stateTrueCounterOld = 0
        for state in checkmarkStates where state {
            stateTrueCounterOld += 1 
        }
        
        // Update States
        let stateNew = !checkmarkStates[checkmarkIndex] // toggle state
        checkmarkStates[checkmarkIndex] = stateNew
        // 0 is the rightmost item checkbox
        // fill true to the right. 
        for index in 0 ..< checkmarkIndex {
            checkmarkStates[index] = true
        }
        // fill false to the left.
        for index in checkmarkIndex+1 ..< checkmarkStates.count {
            checkmarkStates[index] = false
        }
                
        guard let cell = collectionView.cellForItem(at: indexPath) as? DozeEntryStateCell else {
            fatalError("There should be a cell")
        }
        cell.configure(with: checkmarkStates[indexPath.row])
        let itemType = dataProvider.viewModel.itemType(rowIndex: rowIndex)
        
        // Update Streak
        let countMax = checkmarkStates.count
        let countNow = checkmarkStates.filter { $0 }.count
        var streak = countMax == countNow ? 1 : 0
        realm.saveCount(countNow, pid: itemPid)

        // :!!!: streak needs to include more than today+yesterday
        if streak > 0 {
            let yesterday = dataProvider.viewModel.trackerDate.adding(.day, value: -1)!
            // previous day's streak +1
            let yesterdayTracker = realm.getDailyTracker(date: yesterday)
            if let yesterdayStreak = yesterdayTracker.itemsDict[itemType]?.streak {
                streak += yesterdayStreak
            }
        }
        
        realm.updateStreak(streak, pid: itemPid)
        
        tableView.reloadData()
        
        guard !dataProvider.viewModel.itemInfo(rowIndex: rowIndex).isSupplemental else {
            return
        }
        
        let stateTrueCounterNew = stateNew ? checkmarkIndex+1 : checkmarkIndex

        servingsStateCount += stateTrueCounterNew - stateTrueCounterOld
    }
}

extension DozeEntryViewController: RealmDelegate {
    
    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
