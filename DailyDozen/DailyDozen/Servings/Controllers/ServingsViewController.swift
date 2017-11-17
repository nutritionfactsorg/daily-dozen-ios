//
//  ServingsViewController.swift
//  DailyDozen
//
//  Created by Konstantin Khokhlov on 18.10.17.
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit

class ServingsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var dataProvider: ServingsDataProvider!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties
    private let realm = RealmProvider()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewModel(for: Date())

        tableView.dataSource = dataProvider
        tableView.delegate = self
    }

    // MARK: - Methods
    /// Sets a view model for the current date.
    ///
    /// - Parameter item: The current date.
    func setViewModel(for date: Date) {
        dataProvider.viewModel = DozeViewModel(doze: realm.getDoze(for: date))
        tableView.reloadData()
    }

    /// Applies a blurring effect to the parent view layer.
    private func blurBackground() {
        guard let parent = parent else { return }
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.9
        blurEffectView.frame = parent.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        parent.view.addSubview(blurEffectView)
    }

    /// Removes a blurring effect from the parent view layer.
    private func unblurBackground() {
        guard let parent = parent else { return }
        for view in parent.view.subviews {
            if let blurView = view as? UIVisualEffectView, blurView.tag == 100 {
                blurView.removeFromSuperview()
            }
        }
    }

    // MARK: - Actions
    @IBAction private func infoPressed(_ sender: UIButton) {
        let itemInfo = dataProvider.viewModel.itemInfo(for: sender.tag)

        guard !itemInfo.isVitamin else {
            let url = dataProvider.viewModel.topicURL(for: itemInfo.name)
            UIApplication.shared
                .open(url,
                      options: [:],
                      completionHandler: nil)
            return
        }
        let viewController = DetailsBuilder.instantiateController(with: itemInfo.name)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func calendarPressed(_ sender: UIButton) {
        let name = dataProvider.viewModel.itemInfo(for: sender.tag).name
        let viewController = ItemHistoryBuilder.instantiateController(with: name)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction private func vitaminHeaderPressed(_ sender: UIButton) {
        let viewController = VitaminsBuilder.instantiateController()
        viewController.tapDelegate = self

        present(viewController, animated: true)
        blurBackground()
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
        states[indexPath.row] = !states[indexPath.row]
        guard let cell = collectionView.cellForItem(at: indexPath) as? StateCell else {
            fatalError("There should be a cell")
        }
        cell.configure(with: states[indexPath.row])
        let id = dataProvider.viewModel.itemID(for: collectionView.tag)
        realm.saveStates(states, with: id)
    }

}

// MARK: - Interactable
extension ServingsViewController: Interactable {

    func viewDidTap() {
        unblurBackground()
    }
}
