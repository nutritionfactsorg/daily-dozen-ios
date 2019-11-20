//
//  ServingsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import StoreKit

class ServingsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: ServingsDataProvider!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var starImage: UIImageView!
    
    // MARK: - Properties
    private let realm = RealmProviderVersion02()
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
        return "\(servingsStateCount) out of \(servingsStateCountMaximum)"
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewModel(for: Date())
        
        tableView.dataSource = dataProvider
        tableView.delegate = self
        
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
        dataProvider.viewModel = DozeViewModel(doze: realm.getDoze(for: date))
        servingsStateCount = 0
        let mainItemCount = dataProvider.viewModel.count - ServingsSection.supplementsCount
        for i in 0 ..< mainItemCount {
            let itemStates: [Bool] = dataProvider.viewModel.itemStates(index: i)
            for state in itemStates where state {
                servingsStateCount += 1 
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction private func infoPressed(_ sender: UIButton) {
        let itemInfo = dataProvider.viewModel.itemInfo(for: sender.tag)
        
        guard !itemInfo.isSupplemental else {
            let url = dataProvider.viewModel.topicURL(for: itemInfo.name)
            UIApplication.shared
                .open(url,
                      options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                      completionHandler: nil)
            return
        }
        let viewController = DetailsBuilder.instantiateController(with: itemInfo.name)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func calendarPressed(_ sender: UIButton) {
        let name = dataProvider.viewModel.itemInfo(for: sender.tag).name
        let viewController = ItemHistoryBuilder.instantiateController(with: name, itemId: sender.tag)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func supplementsHeaderInfoBtnPressed(_ sender: UIButton) {
        let alert = AlertBuilder.instantiateController(for: .dietarySupplement)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func historyPressed(_ sender: UIButton) {
        let viewController = ServingsHistoryBuilder.instantiateController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Servings UITableViewDelegate

extension ServingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ServingsSection.main.rowHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let servingsCell = cell as? ServingsCell else { return }
        servingsCell.stateCollection.delegate = self
        servingsCell.stateCollection.dataSource = dataProvider
        servingsCell.stateCollection.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let servingsSection = ServingsSection(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return servingsSection.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ServingsSection.main.footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let servingsSection = ServingsSection(rawValue: section) else {
            fatalError("There should be a section type")
        }
        return servingsSection.headerView
    }
}

// MARK: - States UICollectionViewDelegate
extension ServingsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemCheckboxIndex = indexPath.row
        let itemIndex = collectionView.tag
        var itemStates = dataProvider.viewModel.itemStates(index: itemIndex)
        
        var stateTrueCounterOld = 0
        for state in itemStates where state { 
            stateTrueCounterOld += 1 
        }
        
        let stateNew = !itemStates[itemCheckboxIndex] // toggle state
        itemStates[itemCheckboxIndex] = stateNew
        // 0 is the rightmost item checkbox
        // fill true to the right. 
        for index in 0 ..< itemCheckboxIndex {
            itemStates[index] = true
        }
        // fill false to the left.
        for index in itemCheckboxIndex+1 ..< itemStates.count {
            itemStates[index] = false
        }
                
        guard let cell = collectionView.cellForItem(at: indexPath) as? StateCell else {
            fatalError("There should be a cell")
        }
        cell.configure(with: itemStates[indexPath.row])
        let id = dataProvider.viewModel.itemID(for: itemIndex)
        realm.saveStates(itemStates, with: id)
        
        var streak = itemStates.count == itemStates.filter { $0 }.count ? 1 : 0
        
        if streak > 0 {
            let date = dataProvider.viewModel.dozeDate.adding(.day, value: -1)!
            streak += realm
                .getDoze(for: date)
                .items[itemIndex].streak
        }
        
        realm.updateStreak(streak, with: id)
        
        tableView.reloadData()
        
        guard !dataProvider.viewModel.itemInfo(for: itemIndex).isSupplemental else {
            return
        }
        
        let stateTrueCounterNew = stateNew ? itemCheckboxIndex+1 : itemCheckboxIndex

        servingsStateCount += stateTrueCounterNew - stateTrueCounterOld
    }
}

extension ServingsViewController: RealmDelegateVersion02 {
    
    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
