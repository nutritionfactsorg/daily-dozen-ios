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

    // MARK: - Nested
    private struct Keys {
        static let countMaximum = 24
    }

    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: ServingsDataProvider!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var starImage: UIImageView!

    // MARK: - Properties
    private let realm = RealmProvider()

    private var statesCount = 0 {
        didSet {
            countLabel.text = statesCountString
            if statesCount == Keys.countMaximum {
                starImage.popIn()
                SKStoreReviewController.requestReview()
            } else {
                starImage.popOut()
            }
        }
    }
    private var statesCountString: String {
        return "\(statesCount) out of \(Keys.countMaximum)"
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewModel(for: Date())

        tableView.dataSource = dataProvider
        tableView.delegate = self

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.realmDelegate = self
    }

    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(for date: Date) {
        dataProvider.viewModel = DozeViewModel(doze: realm.getDoze(for: date))
        statesCount = 0
        let selectedStates = (0 ... dataProvider.viewModel.count - 3)
            .map { dataProvider.viewModel.itemStates(for: $0) }
            .map { $0.filter { $0 }.count }
        statesCount = selectedStates.reduce(0) { $0 + $1 }
        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction private func infoPressed(_ sender: UIButton) {
        let itemInfo = dataProvider.viewModel.itemInfo(for: sender.tag)

        guard !itemInfo.isVitamin else {
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

    @IBAction private func vitaminHeaderPressed(_ sender: UIButton) {
        let alert = AlertBuilder.instantiateController(for: .vitamin)
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
        var states = dataProvider.viewModel.itemStates(for: collectionView.tag)
        let newState = !states[indexPath.row]
        states[indexPath.row] = newState
        guard let cell = collectionView.cellForItem(at: indexPath) as? StateCell else {
            fatalError("There should be a cell")
        }
        cell.configure(with: states[indexPath.row])
        let id = dataProvider.viewModel.itemID(for: collectionView.tag)
        realm.saveStates(states, with: id)

        var streak = states.count == states.filter { $0 }.count ? 1 : 0

        if streak > 0 {
            streak += realm
                .getDoze(for: dataProvider.viewModel.dozeDate.adding(.day, value: -1)!)
                .items[collectionView.tag].streak
        }

        realm.updateStreak(streak, with: id)

        tableView.reloadData()

        guard !dataProvider.viewModel.itemInfo(for: collectionView.tag).isVitamin else { return }

        if newState {
            statesCount += 1
        } else {
            statesCount -= 1
        }
    }
}

extension ServingsViewController: RealmDelegate {

    func didUpdateFile() {
        navigationController?.popViewController(animated: false)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
