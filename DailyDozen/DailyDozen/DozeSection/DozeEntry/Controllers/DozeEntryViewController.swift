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
    private let dozeDailyStateCountMaximum = 24
    
    /// Number of 'checked' states for the viewed date.
    private var dozeDailyStateCount = 0 {
        didSet {
            countLabel.text = statesCountString
            if dozeDailyStateCount == dozeDailyStateCountMaximum {
                starImage.popIn() // Show daily achievement star
                // Ask the user for ratings and reviews in the App Store
                SKStoreReviewController.requestReview()
            } else {
                starImage.popOut() // Hide daily achievement star
            }
        }
    }
    private var statesCountString: String {
        return "\(dozeDailyStateCount) / \(dozeDailyStateCountMaximum)"
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewModel(date: DateManager.currentDatetime())
        
        tableView.dataSource = dataProvider
        tableView.delegate = self
        tableView.estimatedRowHeight = DozeEntrySections.main.dozeEstimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension // dynamic height
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return 
        }
        appDelegate.realmDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewModel(date: dataProvider.viewModel.trackerDate)
    }
    
    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(date: Date) {
        dataProvider.viewModel = DozeEntryViewModel(tracker: realm.getDailyTracker(date: date))
        
        // Update N/MAX daily checked items count
        dozeDailyStateCount = 0
        let mainItemCount = dataProvider.viewModel.count - DozeEntrySections.supplementsCount
        for i in 0 ..< mainItemCount {
            let itemStates: [Bool] = dataProvider.viewModel.dozeItemStates(rowIndex: i)
            for state in itemStates where state {
                dozeDailyStateCount += 1 
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    /// DozeEntryRow itemInfoButton
    @IBAction private func dozeInfoPressed(_ sender: UIButton) {
        let itemInfo = dataProvider.viewModel.itemInfo(rowIndex: sender.tag)
        
        guard !itemInfo.isSupplemental else {
            let url = dataProvider.viewModel.topicURL(itemTypeKey: itemInfo.itemType.typeKey)
            UIApplication.shared
                .open(url,
                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                      completionHandler: nil)
            return
        }
        let viewController = DozeDetailViewController.newInstance(itemTypeKey: itemInfo.itemType.typeKey)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// DozeEntryRow itemCalendarButton
    @IBAction private func dozeCalendarPressed(_ sender: UIButton) {
        let heading = dataProvider.viewModel.itemInfo(rowIndex: sender.tag).itemType.headingDisplay
        let itemType = dataProvider.viewModel.itemType(rowIndex: sender.tag)
        let viewController = ItemHistoryViewController.newInstance(heading: heading, itemType: itemType)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func supplementsHeaderInfoBtnPressed(_ sender: UIButton) {
        let alert = AlertBuilder.newInstance(for: .dietarySupplement)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func dozeHistoryPressed(_ sender: UIButton) {
        let viewController = DozeHistoryViewController.newInstance()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Servings UITableViewDelegate

extension DozeEntryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let dozeEntryRow = cell as? DozeEntryRow else { return }
        dozeEntryRow.itemStateCollection.delegate = self
        dozeEntryRow.itemStateCollection.dataSource = dataProvider
        dozeEntryRow.itemStateCollection.reloadData()
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
        var checkmarkStates = dataProvider.viewModel.dozeItemStates(rowIndex: rowIndex)
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
                
        guard let cell = collectionView.cellForItem(at: indexPath) as? DozeItemStateCheckbox else {
            fatalError("There should be a cell")
        }
        cell.configure(with: checkmarkStates[indexPath.row])
        
        // Update Tracker Count
        let countNow = checkmarkStates.filter { $0 }.count
        realm.saveCount(countNow, date: itemDate, countType: itemType)
        
        tableView.reloadData()
        
        guard !dataProvider.viewModel.itemInfo(rowIndex: rowIndex).isSupplemental else {
            return
        }
        
        let stateTrueCounterNew = stateNew ? checkmarkIndex+1 : checkmarkIndex

        dozeDailyStateCount += stateTrueCounterNew - stateTrueCounterOld
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
