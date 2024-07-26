//
//  DozeEntryViewController.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import StoreKit // Used to request app store reivew by user.
import SwiftUI

class DozeEntryViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: DozeEntryDataProvider!
    @IBOutlet weak var headerServings: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var starImage: UIImageView!
    
    // MARK: - Properties
    //private let realm = RealmProvider.primary
    private let dozeDailyStateCountMaximum = 24
    
    /// Number of 'checked' states for the viewed date.
    private var dozeDailyStateCount = 0 {
        didSet {
            countLabel.text = statesCountString
            if dozeDailyStateCount == dozeDailyStateCountMaximum {
                starImage.popIn() // Show daily achievement star
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
        
        if let countStr = nf.string(from: dozeDailyStateCount as NSNumber),
           let maxStr = nf.string(from: dozeDailyStateCountMaximum as NSNumber) {
            return("\(countStr) / \(maxStr)")
        } else {
            return "\(dozeDailyStateCount) / \(dozeDailyStateCountMaximum)"
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        headerServings.text = NSLocalizedString("doze_entry_header", comment: "Servings")
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
        //dataProvider.viewModel = DozeEntryViewModel(tracker: realm.getDailyTracker(date: date))
        dataProvider.viewModel = DozeEntryViewModel(tracker: RealmProvider.primary.getDailyTracker(date: date))
        
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
    
    // Function to segue to SwiftUI View
    //@IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
    //    print("•• segue")
    //    // :GTD:  Change to false in production version
    //    return UIHostingController(coder: coder, rootView: DozeEventCalendarView().environmentObject(DozeEventStore(preview: true)))
    //}
    
    /// DozeEntryRow itemCalendarButton
    @IBAction private func dozeCalendarPressed(_ sender: UIButton) {
        let itemHeading = dataProvider.viewModel
            .itemInfo(rowIndex: sender.tag)
            .itemType.headingDisplay
        let itemType = dataProvider.viewModel
            .itemType(rowIndex: sender.tag)
        
        if #available(iOS 16.0, *) { //*** iOS 16+ embedded SwiftUI View
            // :GTD:TDB: Use instance instead of singleton?
            GetDataForCalendar.doit.getData(itemType: itemType)
            let vc = UIHostingController(rootView: DozeEventCalendarView()
                .environmentObject(DozeEventStore(preview: false)))
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let viewController = ItemHistoryViewController
                .newInstance(heading: itemHeading, itemType: itemType)
            navigationController?.pushViewController(viewController, animated: true)
        }
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
        let itemDate: Date = dataProvider.viewModel.trackerDate
        let itemType: DataCountType = dataProvider.viewModel.itemType(rowIndex: rowIndex)
        
        // States: before toggle update
        var stateTrueCounterBefore = 0
        for state in checkmarkStates where state {
            stateTrueCounterBefore += 1 
        }
        
        // States: after toggle update
        let stateAfter: Bool = !checkmarkStates[checkmarkIndex] // toggle state
        checkmarkStates[checkmarkIndex] = stateAfter
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
        let countAfter = checkmarkStates.filter { $0 }.count
        
        let busyAlert = AlertActivityBar()
        busyAlert.setText("Updating progress") // :NYI:LOCALIZE:
        
        //realm.saveCount(countAfter, date: itemDate, countType: itemType)
        RealmProvider.primary.saveCount(countAfter, date: itemDate, countType: itemType)
        tableView.reloadData()
        
        guard !dataProvider.viewModel.itemInfo(rowIndex: rowIndex).isSupplemental else {
            return
        }
        
        let stateTrueCounterAfter = stateAfter ? checkmarkIndex+1 : checkmarkIndex
        
        dozeDailyStateCount += stateTrueCounterAfter - stateTrueCounterBefore
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
