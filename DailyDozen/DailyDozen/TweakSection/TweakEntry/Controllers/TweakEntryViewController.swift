//
//  TweakEntryViewController.swift
//  DailyDozen
//
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import UIKit
import HealthKit
import StoreKit  // Used to request app store reivew by user.

class TweakEntryViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: TweakEntryDataProvider!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var starImage: UIImageView!
    
    // MARK: - Properties
    private let realm = RealmProvider()
    private let tweaksStateCountMaximum = 37
    
    private var tweaksStateCount = 0 {
        didSet {
            countLabel.text = statesCountString
            if tweaksStateCount == tweaksStateCountMaximum {
                starImage.popIn()
                SKStoreReviewController.requestReview()
            } else {
                starImage.popOut()
            }
        }
    }
    private var statesCountString: String {
        return "\(tweaksStateCount) / \(tweaksStateCountMaximum)"
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewModel(for: Date())
        
        tableView.dataSource = dataProvider
        tableView.delegate = self
        tableView.estimatedRowHeight = TweakEntrySections.main.tweakEstimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension // dynamic height
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return 
        }
        appDelegate.realmDelegate = self
        
        // :HealthKit:
        if HKHealthStore.isHealthDataAvailable() {
            // add code to use HealthKit here...
            //print("Yes, HealthKit is Available")
            let healthManager = HealthManager()
            healthManager.requestPermissions()
        } else {
            //print("There is a problem accessing HealthKit")
        }
        
    }
    
    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(for date: Date) {
        dataProvider.viewModel = TweakEntryViewModel(tracker: realm.getDailyTracker(date: date))
        tweaksStateCount = 0
        let mainItemCount = dataProvider.viewModel.count
        for i in 0 ..< mainItemCount {
            let itemStates: [Bool] = dataProvider.viewModel.itemStates(rowIndex: i)
            for state in itemStates where state {
                tweaksStateCount += 1
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    /// TweakEntryTableViewCell infoButton
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
        let viewController = TweakDetailBuilder.instantiateController(itemTypeKey: itemInfo.itemType.typeKey)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// TweakEntryTableViewCell calendarButton
    @IBAction private func calendarPressed(_ sender: UIButton) {
        let heading = dataProvider.viewModel.itemInfo(rowIndex: sender.tag).itemType.headingDisplay
        let dataCountType = dataProvider.viewModel.itemType(rowIndex: sender.tag)
        
        var viewController = ItemHistoryBuilder.instantiateController(heading: heading, itemType: dataCountType)
        if dataCountType == .tweakWeightTwice {
            viewController = WeightHistoryBuilder.instantiateController()
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func supplementsHeaderInfoBtnPressed(_ sender: UIButton) {
        let alert = AlertBuilder.instantiateController(for: .dietarySupplement)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func historyPressed(_ sender: UIButton) {
        let viewController = TweakHistoryBuilder.instantiateController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Tweaks UITableViewDelegate

extension TweakEntryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tweaksTableViewCell = cell as? TweakEntryTableViewCell else { return }
        tweaksTableViewCell.stateCollection.delegate = self
        tweaksTableViewCell.stateCollection.dataSource = dataProvider
        tweaksTableViewCell.stateCollection.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let tweaksSection = TweakEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return tweaksSection.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TweakEntrySections.main.footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tweaksSection = TweakEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return tweaksSection.headerView
    }
}

// MARK: - States UICollectionViewDelegate
extension TweakEntryViewController: UICollectionViewDelegate {
    
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
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TweakEntryStateCell else {
            fatalError("There should be a cell")
        }
        cell.configure(with: checkmarkStates[indexPath.row])
        let dataCountType = dataProvider.viewModel.itemType(rowIndex: rowIndex)
        
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
            if let yesterdayStreak = yesterdayTracker.itemsDict[dataCountType]?.streak {
                streak += yesterdayStreak
            }
        }
        
        realm.updateStreak(streak, pid: itemPid)
        
        tableView.reloadData()
        
        guard !dataProvider.viewModel.itemInfo(rowIndex: rowIndex).isSupplemental else {
            return
        }
        
        let stateTrueCounterNew = stateNew ? checkmarkIndex+1 : checkmarkIndex
        
        tweaksStateCount += stateTrueCounterNew - stateTrueCounterOld
        
        // If state was toggled on then go to weight editor
        if stateNew && HealthManager.shared.isAuthorized() {
            let dataCountType = dataProvider.viewModel.itemType(rowIndex: rowIndex)
            if dataCountType == .tweakWeightTwice {
                let viewController = WeightEntryPagerBuilder.instantiateController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension TweakEntryViewController: RealmDelegate {
    
    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
