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
    @IBOutlet weak var header21Tweaks: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var starImage: UIImageView!
    
    // MARK: - Properties
    private let realm = RealmProvider.primary
    private let tweakDailyStateCountMaximum = 37
    
    /// Number of 'checked' states for the viewed date.
    private var tweakDailyStateCount = 0 {
        didSet {
            countLabel.text = statesCountString
            if tweakDailyStateCount == tweakDailyStateCountMaximum {
                starImage.popIn() // Show show achievement star
                // Ask the user for ratings and reviews in the App Store
                SKStoreReviewController.requestReviewInCurrentScene()
            } else {
                starImage.popOut() // Hide daily achievement star
            }
        }
    }
    
    // entry.stats.completed
    // Android key `out_of` uses 'out of' which does not fit on smaller Apple screens
    private var statesCountString: String {
        let nf = NumberFormatter()
        
        if let countStr = nf.string(from: tweakDailyStateCount as NSNumber),
           let maxStr = nf.string(from: tweakDailyStateCountMaximum as NSNumber) {
            return("\(countStr) / \(maxStr)")
        } else {
            return "\(tweakDailyStateCount) / \(tweakDailyStateCountMaximum)"
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        header21Tweaks.text = NSLocalizedString("tweak_entry_header", comment: "21 Tweaks")
        setViewModel(date: DateManager.currentDatetime())
        
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
            // logit.debug("Yes, HealthKit is Available")
            let healthManager = HealthManager()
            healthManager.requestPermissions()
        } else {
            // logit.debug("There is a problem accessing HealthKit")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changedWeight(notification:)),
            name: Notification.Name(rawValue: "NoticeChangedWeight"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        logit.debug("TweakEntryViewController viewWillAppear")
        super.viewWillAppear(animated)
        setViewModel(date: dataProvider.viewModel.trackerDate)
    }
    
    // MARK: - Methods
    
    /// Updates the view model for the current date.
    @objc func changedWeight(notification: Notification) {
        guard let dateChanged = notification.object as? Date else { return }
        let dateViewed = dataProvider.viewModel.trackerDate
        if dateChanged.datestampKey == dateViewed.datestampKey {
            setViewModel(date: dateViewed)            
        }
    }
    
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(date: Date) {
        logit.debug("@DATE \(date.datestampKey) TweakEntryViewController setViewModel")
        dataProvider.viewModel = TweakEntryViewModel(tracker: realm.getDailyTracker(date: date))
        
        // Update N/MAX daily checked items count 
        tweakDailyStateCount = 0
        let mainItemCount = dataProvider.viewModel.count
        for i in 0 ..< mainItemCount {
            let itemStates: [Bool] = dataProvider.viewModel.tweakItemStates(rowIndex: i)
            for state in itemStates where state {
                tweakDailyStateCount += 1
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    /// TweakEntryRow itemInfoButton
    @IBAction private func tweakInfoPressed(_ sender: UIButton) {
        let itemInfo = dataProvider.viewModel.itemInfo(rowIndex: sender.tag)
        
        let viewController = TweakDetailViewController.newInstance(itemTypeKey: itemInfo.typeKey)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// TweakEntryRow itemCalendarButton
    @IBAction private func tweakCalendarPressed(_ sender: UIButton) {
        let itemHeading = dataProvider.viewModel
            .itemInfo(rowIndex: sender.tag)
            .headingDisplay
        let itemType = dataProvider.viewModel
            .itemType(rowIndex: sender.tag)
        
        var viewController = ItemHistoryViewController.newInstance(heading: itemHeading, itemType: itemType)
        if itemType == .tweakWeightTwice {
            viewController = WeightHistoryViewController.newInstance()
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func tweakHistoryPressed(_ sender: UIButton) {
        let viewController = TweakHistoryViewController.newInstance()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Tweaks UITableViewDelegate

extension TweakEntryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tweakEntryRow = cell as? TweakEntryRow else { return }
        tweakEntryRow.itemStateCollection.delegate = self
        tweakEntryRow.itemStateCollection.dataSource = dataProvider
        tweakEntryRow.itemStateCollection.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let tweakSection = TweakEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return tweakSection.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TweakEntrySections.main.footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tweakSection = TweakEntrySections(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return tweakSection.headerView
    }
}

// MARK: - States UICollectionViewDelegate
extension TweakEntryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rowIndex = collectionView.tag // which item
        let checkmarkIndex = indexPath.row // which checkmark
        var checkmarkStates = dataProvider.viewModel.tweakItemStates(rowIndex: rowIndex)
        let itemDate = dataProvider.viewModel.trackerDate 
        let itemType = dataProvider.viewModel.itemType(rowIndex: rowIndex)
        
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
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TweakItemStateCheckbox else {
            fatalError("There should be a cell")
        }
        cell.configure(with: checkmarkStates[indexPath.row])
        let dataCountType = dataProvider.viewModel.itemType(rowIndex: rowIndex)
        
        // Update Tracker Count
        let countNow = checkmarkStates.filter { $0 }.count
        realm.saveCount(countNow, date: itemDate, countType: itemType)
        
        tableView.reloadData()
        
        let stateTrueCounterNew = stateNew ? checkmarkIndex+1 : checkmarkIndex
        
        tweakDailyStateCount += stateTrueCounterNew - stateTrueCounterOld
        
        // Weight Editor
        if dataCountType == .tweakWeightTwice { 
            // Go to the weight editor
            let date = dataProvider.viewModel.trackerDate
            let viewController = WeightEntryPagerViewController.newInstance(date: date)
            if let navigationController = navigationController {
                navigationController.pushViewController(viewController, animated: true)
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
